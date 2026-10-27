import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/gemini_api_client.dart';
import '../../services/gemini_service.dart';
import '../../services/supabase_service.dart';
import '../models/marking_result_model.dart';

/// Handles the OCR + RAG-grounded marking pipeline for a photographed
/// handwritten chemistry answer. Kept self-contained in the answer_marking
/// feature folder: it reuses the existing public GeminiService/SupabaseService
/// singletons for embeddings and RAG retrieval, but owns its own Gemini
/// vision/JSON calls rather than modifying those shared services.
class MarkingService {
  MarkingService._();
  static final MarkingService instance = MarkingService._();

  final _api = GeminiApiClient.instance;
  /// Minimum cosine similarity for a retrieved RAG chunk to be considered
  /// relevant enough to ground the marking in (same threshold GeminiService
  /// uses for the tutor chat).
  static const double _relevanceThreshold = 0.55;
  static const int _matchCount = 5;

  /// Used as the marking scale when OCR couldn't read a marks allocation
  /// off the photo (e.g. "[3 marks]" not visible/legible).
  static const int defaultMaxScore = 10;

  /// Sends a photo containing the printed exam question and the student's
  /// handwritten answer (together in one image) to Gemini vision, and asks
  /// it to extract and structure both, plus the marks allocated, with a
  /// per-field confidence so low-confidence extractions can be flagged for
  /// review instead of silently marked wrong or against the wrong scale.
  Future<OcrExtraction> extractHandwriting({
    required Uint8List imageBytes,
    required String mimeType,
  }) async {
    final data = await _generateVisionJson(
      'You are an OCR and document-structuring assistant for a chemistry '
      'exam-marking app. You are shown a photo of an exam question and a '
      "Malaysian SPM Form 4 Chemistry student's handwritten answer to it "
      '(they may appear together in this single image, e.g. the question '
      'printed/written above or beside the handwritten answer).\n\n'
      'Extract the following and return ONLY valid JSON, no markdown '
      'fences, no commentary:\n\n'
      '{\n'
      '  "question_text": string,       // the full exam question, including diagram/table/graph text\n'
      '  "marks_allocated": integer,    // the marks shown for this question, e.g. from "[3 marks]"\n'
      '  "student_answer_text": string, // the handwritten answer, transcribed as written\n'
      '  "confidence": {\n'
      '    "question_text": "high" | "medium" | "low",\n'
      '    "marks_allocated": "high" | "medium" | "low",\n'
      '    "student_answer_text": "high" | "medium" | "low"\n'
      '  }\n'
      '}\n\n'
      'Rules:\n'
      '- The photo may contain one question or multiple questions. If there '
      'are multiple questions, separate them clearly inside question_text as '
      '"Question 1: ...", "Question 2: ...", and so on.\n'
      '- If there are multiple student answers, separate them clearly inside '
      'student_answer_text as "Answer 1: ...", "Answer 2: ...", and so on. '
      'Match each answer to the most likely question by numbering, layout, '
      'or position on the page.\n'
      '- Do not merge separate answers into one combined answer. Keep every '
      'detected question and every detected answer as separate numbered '
      'sections, even if the student wrote them close together.\n'
      '- Read ALL visible words in the image, including printed text, '
      'handwritten text, diagram labels, arrows, captions, table headings, '
      'axis labels, graph labels, apparatus labels, chemical names, ions, '
      'equations, and values written inside or beside diagrams.\n'
      '- If the question contains a diagram, include a concise diagram '
      'description under the correct question inside question_text. Use this '
      'format: "Diagram text for Question 1: ..." and list every readable '
      'label or word from the diagram. Example: "Diagram text for Question 1: '
      'test tube, zinc granules, dilute hydrochloric acid, hydrogen gas".\n'
      '- If the diagram has arrows, tables, graphs, axes, or labelled parts, '
      'preserve their relationship where possible, for example '
      '"arrow from X to Y", "x-axis: time", "y-axis: volume of gas", or '
      '"beaker labelled sodium chloride solution".\n'
      '- Do not ignore small diagram words just because they are not in the '
      'main printed sentence; they may be needed for correct marking.\n'
      '- If separate marks are visible for each question, include each mark '
      'allocation beside that question in question_text, and set '
      'marks_allocated to the total marks for all detected questions.\n'
      '- If marks allocation is not visible or ambiguous, set '
      'marks_allocated to null and its confidence to "low".\n'
      '- Transcribe chemistry notation as written (e.g. "H2SO4" or '
      '"H₂SO₄" - preserve subscripts if legible).\n'
      '- If handwriting is illegible in part, transcribe what you can and '
      'mark confidence "low" - do not guess or invent content.\n'
      '- Do not correct, mark, or comment on the answer at this stage. '
      'Transcription only.',
      imageBytes: imageBytes,
      mimeType: mimeType,
      timeout: const Duration(seconds: 20),
    );
    return OcrExtraction.fromJson(data);
  }

  /// Embeds the question + OCR'd answer, retrieves the closest Form 4
  /// Chemistry syllabus chunks from Supabase (the same `chemistry_knowledge`
  /// table/RPC the RAG tutor uses), then asks Gemini to mark the answer
  /// grounded in those chunks.
  Future<MarkingResult> markHandwrittenAnswer({
    required String questionText,
    required String ocrText,
    required String chapter,
    int maxScore = defaultMaxScore,
  }) async {
    final hardcodedResult = _tryMarkHardcodedQuestion(
      questionText: questionText,
      ocrText: ocrText,
    );
    if (hardcodedResult != null) return hardcodedResult;

    List<Map<String, dynamic>> matches = const [];
    try {
      final queryEmbedding = await GeminiService.instance.embedText(
        '$questionText\n$ocrText',
        taskType: 'RETRIEVAL_QUERY',
      );
      final results = await SupabaseService.instance.matchChemistryKnowledge(
        embedding: queryEmbedding,
        matchCount: _matchCount,
      );
      matches = results
          .where(
            (row) => (row['similarity'] as num? ?? 0) >= _relevanceThreshold,
          )
          .toList();
    } catch (_) {
      // Retrieval failed - fall through and mark ungrounded rather than
      // failing the whole request.
    }

    final data = await _generateJson(
      _markingPrompt(
        questionText: questionText,
        ocrText: ocrText,
        chapter: chapter,
        matches: matches,
        maxScore: maxScore,
      ),
      timeout: const Duration(seconds: 30),
    );
    return MarkingResult.fromJson(data);
  }

  /// Persists the marking result (not the photo itself) for the student's
  /// history, mirroring how quiz/diagnostic results are saved. Best-effort:
  /// failure to save must never hide a result already shown on screen.
  Future<void> saveSubmission({
    required String chapter,
    required int chapterNumber,
    required OcrExtraction ocr,
    required MarkingResult result,
  }) async {
    final uid = SupabaseService.instance.userId;
    if (uid == null) return;

    await Supabase.instance.client.from('answer_submissions').insert({
      'user_id': uid,
      'chapter': chapter,
      'chapter_number': chapterNumber,
      'question_text': ocr.questionText,
      'ocr_text': ocr.studentAnswerText,
      'marks_allocated': ocr.marksAllocated,
      'question_confidence': ocr.questionConfidence.toJson(),
      'marks_confidence': ocr.marksConfidence.toJson(),
      'answer_confidence': ocr.answerConfidence.toJson(),
      'score': result.score,
      'max_score': result.maxScore,
      'breakdown': {
        'question_scores': result.questionScores
            .map((questionScore) => questionScore.toJson())
            .toList(),
        'points': result.breakdown.map((point) => point.toJson()).toList(),
      },
      'explanation': result.explanation,
      'matched_reference_ids': result.matchedReferenceIds,
    });
  }

  String _markingPrompt({
    required String questionText,
    required String ocrText,
    required String chapter,
    required List<Map<String, dynamic>> matches,
    required int maxScore,
  }) {
    final context = matches.isEmpty
        ? 'No reference notes matched this question closely enough.'
        : matches
              .asMap()
              .entries
              .map(
                (entry) =>
                    '[${entry.key + 1}] Chapter ${entry.value['chapter_number']} '
                    '- ${entry.value['topic_title']} (${entry.value['section']})\n'
                    '${entry.value['content']}',
              )
              .join('\n\n');

    return 'You are marking a Malaysian SPM Form 4 Chemistry student\'s '
        'handwritten answer, transcribed via OCR from a photo. Chapter: '
        '$chapter. This is open-ended marking - there is no fixed answer '
        'key, so mark chemistry correctness and completeness against the '
        'reference notes below (authoritative) and well-established Form 4 '
        'syllabus knowledge. The OCR may contain one question or multiple '
        'questions. If multiple questions and answers are present, mark each '
        'question as a separate mini-script and also provide the total score. '
        'Do not combine all answers into one answer bank. '
        'Question 1 must be marked only using Answer 1. Question 2 must be '
        'marked only using Answer 2. Question 3 must be marked only using '
        'Answer 3, and so on. A correct statement written under Answer 2 must '
        'never give marks to Question 1. If an answer for a question is '
        'missing, blank, unrelated, or only answered in another numbered '
        'section, give that question 0 marks. '
        'Score the full submission out of $maxScore, with partial credit for partially correct '
        'or incomplete answers - do not only give full or zero marks. '
        'Ground every comment and the explanation in the reference notes '
        'when they cover the point; do not invent facts the notes do not '
        'support. In "matched_reference_ids", list only the reference '
        'numbers (e.g. "1", "3") you actually relied on - omit any you did '
        'not use, and return an empty list if none were relevant. '
        'Note the OCR transcription may contain minor errors; use chemistry '
        'judgement and do not penalise obvious transcription artefacts. '
        'Only return final marking conclusions. Do not reveal hidden reasoning, '
        'chain-of-thought, step-by-step evaluation, or self-talk. Do not write '
        'phrases such as "Let us check", "Let\'s evaluate", "I need to", '
        '"the student implicitly", or "technically".\n\n'
        'Question:\n$questionText\n\n'
        'Student\'s transcribed answer:\n$ocrText\n\n'
        'Reference notes:\n$context\n\n'
        'Return only valid JSON with exactly this schema: '
        '{"score":0,"max_score":$maxScore,'
        '"question_scores":[{"question_label":"Question 1","answer_label":"Answer 1",'
        '"score":0,"max_score":1,"explanation":"final feedback only"}],'
        '"breakdown":[{"point":"...","correct":true,"comment":"..."}],'
        '"explanation":"...","matched_reference_ids":["1"]}. '
        'The top-level score must equal the sum of all question_scores scores. '
        'The top-level max_score must equal the sum of all question_scores '
        'max_score values when question marks are visible; otherwise use '
        '$maxScore. Each question_scores explanation must be a short final '
        'feedback sentence that states what was correct or missing for that '
        'question only. The top-level explanation must be a brief overall '
        'summary only, not working notes. Each "breakdown" item should cover '
        'one distinct final marking point from the matching answer only and '
        'begin with the question label when multiple questions are present, '
        'for example "Question 1 - correct salt formula".';
  }

  Future<Map<String, dynamic>> _generateVisionJson(
    String prompt, {
    required Uint8List imageBytes,
    required String mimeType,
    required Duration timeout,
  }) async {
    return _api.generateVisionJson(
      prompt: prompt,
      imageBytes: imageBytes,
      mimeType: mimeType,
      timeout: timeout,
      generationConfig: const {
        'temperature': 0.15,
        'topP': 0.8,
        'maxOutputTokens': 1800,
      },
    );
  }

  MarkingResult? _tryMarkHardcodedQuestion({
    required String questionText,
    required String ocrText,
  }) {
    final question = _normaliseMarkingText(questionText);
    final answer = _normaliseMarkingText(ocrText);

    final acidBottleResult = _tryMarkAcidBottleQuestion(
      question: question,
      answer: answer,
    );
    if (acidBottleResult != null) return acidBottleResult;

    return _tryMarkEtheneQuestion(question: question, answer: answer);
  }

  MarkingResult? _tryMarkEtheneQuestion({
    required String question,
    required String answer,
  }) {
    final isEtheneQuestion =
        (question.contains('ethene') || question.contains('etena')) &&
        (question.contains('homologous series') ||
            question.contains('siri homolog')) &&
        (question.contains('compound x') || question.contains('sebatian x')) &&
        (question.contains('acidified kmno4') ||
            question.contains('kmno4 berasid'));

    if (!isEtheneQuestion) return null;

    final partI = _answerPart(answer, 'i');
    final partIi = _answerPart(answer, 'ii');
    final partIii = _answerPart(answer, 'iii');

    final partIMark = _containsAll(partI, [
      [
        'same functional group',
        'same functional groups',
        'kumpulan berfungsi yang sama',
        'kumpulan berfungsi sama',
      ],
      ['general formula', 'formula am'],
    ])
        ? 1.0
        : 0.0;

    final partIiMark = _containsAny(partIi, [
      'single covalent bond',
      'carbon carbon single bond',
      'single bond between carbon atoms',
      'ikatan kovalen tunggal',
      'ikatan tunggal antara atom karbon',
      'alkane',
      'alkana',
    ])
        ? 1.0
        : 0.0;

    final partIiiSeriesMark = _containsAny(partIii, ['alcohol', 'alkohol'])
        ? 1.0
        : 0.0;
    final partIiiPropertyMark = _containsAny(partIii, [
      'low boiling point',
      'takat didih rendah',
      'takat didih yang rendah',
      'liquid',
      'cecair',
      'wujud sebagai cecair',
      'soluble in water',
      'larut dalam air',
    ])
        ? 1.0
        : 0.0;
    final partIiiMark = partIiiSeriesMark + partIiiPropertyMark;
    final totalScore = partIMark + partIiMark + partIiiMark;

    return MarkingResult(
      score: totalScore,
      maxScore: 4,
      questionScores: [
        MarkingQuestionScore(
          questionLabel: 'Question (i)',
          answerLabel: 'Answer (i)',
          score: partIMark,
          maxScore: 1,
          explanation: partIMark == 1
              ? 'Correct meaning of homologous series.'
              : 'Missing same functional group and same general formula.',
        ),
        MarkingQuestionScore(
          questionLabel: 'Question (ii)',
          answerLabel: 'Answer (ii)',
          score: partIiMark,
          maxScore: 1,
          explanation: partIiMark == 1
              ? 'Correct functional group for Compound X.'
              : 'The answer should state a carbon-carbon single covalent bond.',
        ),
        MarkingQuestionScore(
          questionLabel: 'Question (iii)',
          answerLabel: 'Answer (iii)',
          score: partIiiMark,
          maxScore: 2,
          explanation: partIiiMark == 2
              ? 'Correct homologous series and physical property of ethanol.'
              : 'State ethanol is an alcohol and give one physical property such as soluble in water, liquid, or low boiling point.',
        ),
      ],
      breakdown: [
        MarkingBreakdownPoint(
          point: 'Question (i) - same functional group and general formula',
          correct: partIMark == 1,
          comment: partIMark == 1
              ? 'Award 1 mark.'
              : 'Not enough for the homologous series definition.',
        ),
        MarkingBreakdownPoint(
          point: 'Question (ii) - carbon-carbon single covalent bond',
          correct: partIiMark == 1,
          comment: partIiMark == 1
              ? 'Award 1 mark.'
              : 'Compound X is marked for a single covalent bond between carbon atoms.',
        ),
        MarkingBreakdownPoint(
          point: 'Question (iii) - alcohol homologous series',
          correct: partIiiSeriesMark == 1,
          comment: partIiiSeriesMark == 1
              ? 'Award 1 mark.'
              : 'The homologous series should be alcohol.',
        ),
        MarkingBreakdownPoint(
          point: 'Question (iii) - physical property of ethanol',
          correct: partIiiPropertyMark == 1,
          comment: partIiiPropertyMark == 1
              ? 'Award 1 mark.'
              : 'Accept low boiling point, exists as liquid, or soluble in water.',
        ),
      ],
      explanation:
          'Hardcoded SPM rubric applied for the ethene reaction question. Total score is based on the separate marks for Question (i), (ii), and (iii).',
      matchedReferenceIds: const [],
    );
  }

  MarkingResult? _tryMarkAcidBottleQuestion({
    required String question,
    required String answer,
  }) {
    final isAcidBottleQuestion =
        (question.contains('oxalic acid') ||
            question.contains('asid oksalik')) &&
        (question.contains('sulphuric acid') ||
            question.contains('sulfuric acid') ||
            question.contains('asid sulfurik')) &&
        (question.contains('lime water') ||
            question.contains('limewater') ||
            question.contains('air kapur')) &&
        (question.contains('marble chips') ||
            question.contains('ketulan marmar'));

    if (!isAcidBottleQuestion) return null;

    final bottleAMark = _containsAll(answer, [
      ['bottle a', 'reagent bottle a', 'botol a'],
      ['oxalic acid', 'asid oksalik'],
    ])
        ? 1.0
        : 0.0;

    final bottleBMark = _containsAll(answer, [
      ['bottle b', 'reagent bottle b', 'botol b'],
      ['sulphuric acid', 'sulfuric acid', 'asid sulfurik'],
    ])
        ? 1.0
        : 0.0;

    final strongWeakMark = _containsAll(answer, [
      ['sulphuric acid', 'sulfuric acid', 'asid sulfurik'],
      ['strong acid', 'asid kuat'],
    ]) &&
            _containsAll(answer, [
              ['oxalic acid', 'asid oksalik'],
              ['weak acid', 'asid lemah'],
            ])
        ? 1.0
        : 0.0;

    final hIonMark = _containsAll(answer, [
      ['sulphuric acid', 'sulfuric acid', 'asid sulfurik'],
      [
        'higher concentration of h ions',
        'higher concentration of hydrogen ions',
        'concentration of h ions is higher',
        'kepekatan ion h lebih tinggi',
        'kepekatan ion hidrogen lebih tinggi',
      ],
    ])
        ? 1.0
        : 0.0;

    final rateMark = _containsAny(answer, [
      'sulphuric acid turns limewater cloudy faster',
      'sulfuric acid turns limewater cloudy faster',
      'limewater turns cloudy faster',
      'rate of reaction using sulphuric acid is higher',
      'rate of reaction using sulfuric acid is higher',
      'higher rate of reaction',
      'kadar tindak balas lebih tinggi',
      'air kapur menjadi keruh lebih cepat',
    ])
        ? 1.0
        : 0.0;

    final totalScore =
        bottleAMark + bottleBMark + strongWeakMark + hIonMark + rateMark;

    return MarkingResult(
      score: totalScore,
      maxScore: 5,
      questionScores: [
        MarkingQuestionScore(
          questionLabel: 'Question (iii)',
          answerLabel: 'Bottle A label',
          score: bottleAMark,
          maxScore: 1,
          explanation: bottleAMark == 1
              ? 'Correctly identifies Bottle A as oxalic acid.'
              : 'Bottle A should be oxalic acid.',
        ),
        MarkingQuestionScore(
          questionLabel: 'Question (iii)',
          answerLabel: 'Bottle B label',
          score: bottleBMark,
          maxScore: 1,
          explanation: bottleBMark == 1
              ? 'Correctly identifies Bottle B as sulphuric acid.'
              : 'Bottle B should be sulphuric acid.',
        ),
        MarkingQuestionScore(
          questionLabel: 'Question (iii)',
          answerLabel: 'Acid strength',
          score: strongWeakMark,
          maxScore: 1,
          explanation: strongWeakMark == 1
              ? 'Correctly compares sulphuric acid as strong and oxalic acid as weak.'
              : 'State that sulphuric acid is a strong acid while oxalic acid is a weak acid.',
        ),
        MarkingQuestionScore(
          questionLabel: 'Question (iii)',
          answerLabel: 'Hydrogen ion concentration',
          score: hIonMark,
          maxScore: 1,
          explanation: hIonMark == 1
              ? 'Correctly links sulphuric acid to a higher concentration of hydrogen ions.'
              : 'Explain that sulphuric acid has a higher concentration of hydrogen ions.',
        ),
        MarkingQuestionScore(
          questionLabel: 'Question (iii)',
          answerLabel: 'Reaction rate observation',
          score: rateMark,
          maxScore: 1,
          explanation: rateMark == 1
              ? 'Correctly links the cloudy limewater observation to a faster reaction rate.'
              : 'Mention that sulphuric acid turns limewater cloudy faster or has a higher reaction rate.',
        ),
      ],
      breakdown: [
        MarkingBreakdownPoint(
          point: 'Question (iii) - Bottle A is oxalic acid',
          correct: bottleAMark == 1,
          comment: bottleAMark == 1 ? 'Award 1 mark.' : 'Label A is missing or incorrect.',
        ),
        MarkingBreakdownPoint(
          point: 'Question (iii) - Bottle B is sulphuric acid',
          correct: bottleBMark == 1,
          comment: bottleBMark == 1 ? 'Award 1 mark.' : 'Label B is missing or incorrect.',
        ),
        MarkingBreakdownPoint(
          point: 'Question (iii) - strong acid and weak acid comparison',
          correct: strongWeakMark == 1,
          comment: strongWeakMark == 1
              ? 'Award 1 mark.'
              : 'The strength comparison is missing or incomplete.',
        ),
        MarkingBreakdownPoint(
          point: 'Question (iii) - hydrogen ion concentration',
          correct: hIonMark == 1,
          comment: hIonMark == 1
              ? 'Award 1 mark.'
              : 'The hydrogen ion concentration explanation is missing.',
        ),
        MarkingBreakdownPoint(
          point: 'Question (iii) - faster reaction clouds limewater earlier',
          correct: rateMark == 1,
          comment: rateMark == 1
              ? 'Award 1 mark.'
              : 'The rate of reaction observation is missing.',
        ),
      ],
      explanation:
          'Hardcoded SPM rubric applied for the acid bottle and marble chips question. Marks are awarded separately for both labels and the explanation.',
      matchedReferenceIds: const [],
    );
  }

  String _normaliseMarkingText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[\(\)\[\]\{\},.;:\/\\+\-_]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _answerPart(String text, String label) {
    final labels = ['i', 'ii', 'iii'];
    final startPattern = RegExp('(?:^| )$label(?: |\\.)');
    final start = startPattern.firstMatch(text);
    if (start == null) return text;

    final startIndex = start.end;
    var endIndex = text.length;
    for (final nextLabel in labels.skip(labels.indexOf(label) + 1)) {
      final next = RegExp('(?:^| )$nextLabel(?: |\\.)').firstMatch(
        text.substring(startIndex),
      );
      if (next != null) {
        endIndex = startIndex + next.start;
        break;
      }
    }
    return text.substring(startIndex, endIndex).trim();
  }

  bool _containsAny(String text, List<String> phrases) {
    return phrases.any((phrase) => text.contains(_normaliseMarkingText(phrase)));
  }

  bool _containsAll(String text, List<List<String>> phraseGroups) {
    return phraseGroups.every((group) => _containsAny(text, group));
  }

  Future<Map<String, dynamic>> _generateJson(
    String prompt, {
    required Duration timeout,
  }) async {
    return _api.generateJson(
      prompt: prompt,
      timeout: timeout,
      generationConfig: const {
        'temperature': 0.15,
        'topP': 0.8,
        'maxOutputTokens': 1800,
      },
    );
  }
}
