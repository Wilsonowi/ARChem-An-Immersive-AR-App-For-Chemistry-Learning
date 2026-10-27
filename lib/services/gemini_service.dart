import 'dart:convert';

import '../chapters/chapters_data.dart';
import '../data/diagnostic_questions.dart';
import '../data/hardcoded_questions.dart';
import '../models/question_model.dart';
import 'gemini_api_client.dart';
import 'supabase_service.dart';

class GeminiService {
  GeminiService._();
  static final GeminiService instance = GeminiService._();

  final _api = GeminiApiClient.instance;

  /// Minimum cosine similarity for a retrieved chunk to be considered
  /// relevant enough to ground the answer in.
  static const double _relevanceThreshold = 0.48;

  static const Map<int, int> _diagnosticDistribution = {
    1: 2,
    2: 4,
    3: 4,
    4: 4,
    5: 5,
    6: 10,
    7: 5,
    8: 3,
  };

  Future<List<QuestionModel>> generateDiagnosticQuestions() async {
    final batches = await Future.wait(
      kChapters.map((chapter) async {
        final count = _diagnosticDistribution[chapter.number] ?? 0;
        if (count == 0) return <QuestionModel>[];

        try {
          final data = await _api.generateJson(
            prompt: _quizPrompt(
              chapter: chapter.title,
              chapterNumber: chapter.number,
              subtopic: null,
              count: count,
              diagnostic: true,
            ),
            timeout: const Duration(seconds: 30),
            generationConfig: {
              'temperature': 0.35,
              'topP': 0.9,
              'maxOutputTokens': count >= 8 ? 7000 : 4000,
              'responseMimeType': 'application/json',
            },
          );
          final generated = _parseQuestions(
            data,
            chapter: chapter.title,
            chapterNumber: chapter.number,
          );
          return _fillQuestionBatch(
            generated: generated,
            fallback: _diagnosticFallback(chapter.number),
            count: count,
          );
        } catch (_) {
          return _diagnosticFallback(chapter.number).take(count).toList();
        }
      }),
    );

    return batches.expand((batch) => batch).toList();
  }

  Future<List<QuestionModel>> generateQuizQuestions({
    required String chapter,
    required int chapterNumber,
    String? subtopic,
    int count = 5,
  }) async {
    try {
      final data = await _api.generateJson(
        prompt: _quizPrompt(
          chapter: chapter,
          chapterNumber: chapterNumber,
          subtopic: subtopic,
          count: count,
        ),
        timeout: const Duration(seconds: 8),
        generationConfig: const {
          'temperature': 0.35,
          'topP': 0.9,
          'maxOutputTokens': 4000,
          'responseMimeType': 'application/json',
        },
      );
      final questions = _parseQuestions(
        data,
        chapter: chapter,
        chapterNumber: chapterNumber,
        subtopic: subtopic,
      );
      if (questions.isEmpty) throw const FormatException('Empty quiz');
      return _fillQuestionBatch(
        generated: questions,
        fallback: hardcodedQuestionsForChapter(chapterNumber, count: count),
        count: count,
      );
    } catch (_) {
      return hardcodedQuestionsForChapter(chapterNumber, count: count);
    }
  }

  Future<Map<String, dynamic>> generateStudyPlan({
    required List<ChapterDiagnosticScore> scores,
  }) async {
    try {
      final data = await _generateJson(
        _studyPlanPrompt(scores),
        timeout: const Duration(seconds: 30),
      );
      return data;
    } catch (_) {
      return _fallbackStudyPlan(scores);
    }
  }

  Future<String> getAIHint({
    required String question,
    required String wrongAnswer,
    required String correctAnswer,
    required String chapter,
  }) async {
    try {
      final text = await _generateText(
        'You are helping a Malaysian SPM Form 4 Chemistry student. '
        'In exactly two short sentences, explain why "$wrongAnswer" is wrong '
        'and why "$correctAnswer" is correct. Chapter: $chapter. '
        'Question: $question',
        timeout: const Duration(seconds: 15),
      );
      return text.trim().isEmpty
          ? 'Review the key concept first, then compare it with the correct answer.'
          : text.trim();
    } catch (_) {
      return 'Review the explanation above and focus on the keyword in the correct answer.';
    }
  }

  Future<String> sendTutorMessage({
    required String message,
    required List<Map<String, String>> history,
  }) async {
    try {
      final text = await _generateText(
        _chatPrompt(message: message, history: history),
        timeout: const Duration(seconds: 15),
      );
      return text.trim().isEmpty
          ? _fallbackTutorReply(message)
          : _normalizeMathDelimiters(text.trim().replaceAll('```', '').trim());
    } catch (_) {
      return _fallbackTutorReply(message);
    }
  }

  /// RAG-grounded tutor reply: embeds the question, retrieves the closest
  /// syllabus chunks from Supabase, and asks Gemini to answer using them.
  /// Falls back to the plain (non-RAG) [sendTutorMessage] if embedding or
  /// retrieval fails for any reason (e.g. network/Supabase issue), and that
  /// in turn falls back to a canned reply if Gemini itself is unreachable.
  Future<String> sendRagTutorMessage({
    required String message,
    required List<Map<String, String>> history,
  }) async {
    List<Map<String, dynamic>> matches = const [];
    try {
      final retrievalHistory = history.length > 6
          ? history.sublist(history.length - 6)
          : history;
      final retrievalQuery = [
        ...retrievalHistory.map((turn) => '${turn['role']}: ${turn['text']}'),
        'user: $message',
      ].join('\n');
      final queryEmbedding = await embedText(
        retrievalQuery,
        taskType: 'RETRIEVAL_QUERY',
      );
      final results = await SupabaseService.instance.matchChemistryKnowledge(
        embedding: queryEmbedding,
        matchCount: 8,
      );
      matches = results
          .where(
            (row) => (row['similarity'] as num? ?? 0) >= _relevanceThreshold,
          )
          .toList();
    } catch (_) {
      // Retrieval failed - fall through and let Gemini answer without
      // grounding rather than failing the whole message.
    }

    try {
      final text = await _generateText(
        _ragChatPrompt(message: message, history: history, matches: matches),
        timeout: const Duration(seconds: 20),
      );
      return text.trim().isEmpty
          ? await sendTutorMessage(message: message, history: history)
          : _normalizeMathDelimiters(text.trim().replaceAll('```', '').trim());
    } catch (_) {
      return sendTutorMessage(message: message, history: history);
    }
  }

  /// Converts stray $...$ / $$...$$ LaTeX (Gemini's default habit) into the
  /// \( \) / \[ \] delimiters that the gpt_markdown renderer expects.
  String _normalizeMathDelimiters(String text) {
    final withBlockMath = text.replaceAllMapped(
      RegExp(r'\$\$([\s\S]+?)\$\$'),
      (match) => '\\[${match.group(1)}\\]',
    );
    return withBlockMath.replaceAllMapped(
      RegExp(r'\$([^\n\$]+?)\$'),
      (match) => '\\(${match.group(1)}\\)',
    );
  }

  /// Embed a piece of text with Gemini's text-embedding-004 model.
  /// Use taskType 'RETRIEVAL_QUERY' for user questions and
  /// 'RETRIEVAL_DOCUMENT' for corpus chunks being indexed.
  Future<List<double>> embedText(
    String text, {
    String taskType = 'RETRIEVAL_QUERY',
  }) async {
    return _api.embedText(text: text, taskType: taskType);
  }

  Future<Map<String, dynamic>?> updateStudyPlan({
    required String chapter,
    required int chapterNumber,
    required int score,
    required int maxScore,
    Map<String, dynamic>? currentPlan,
  }) async {
    try {
      final data = await _generateJson(
        'Return only JSON. Update this study plan motivational message after a quiz. '
        'Chapter $chapterNumber: $chapter. Score: $score/$maxScore. '
        'Existing plan JSON: ${jsonEncode(currentPlan ?? {})}. '
        'Schema: {"motivational_message": "...", "next_focus": "..."}',
        timeout: const Duration(seconds: 30),
      );
      return data;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> _generateJson(
    String prompt, {
    required Duration timeout,
  }) async {
    final text = await _generateText(prompt, timeout: timeout);
    return _api.parseJsonText(text);
  }

  Future<String> _generateText(
    String prompt, {
    required Duration timeout,
  }) async {
    return _api.generateText(
      prompt: prompt,
      timeout: timeout,
      generationConfig: const {
        'temperature': 0.35,
        'topP': 0.9,
        'maxOutputTokens': 1600,
      },
    );
  }

  List<QuestionModel> _parseQuestions(
    Map<String, dynamic> data, {
    required String chapter,
    required int chapterNumber,
    String? subtopic,
  }) {
    final raw = data['questions'] as List<dynamic>? ?? const [];
    final questions = <QuestionModel>[];

    for (final item in raw.whereType<Map>()) {
      try {
        final normalized = Map<String, dynamic>.from(item)
          ..['chapter'] = chapter
          ..['chapterNumber'] = chapterNumber;
        if (subtopic != null && subtopic.trim().isNotEmpty) {
          normalized['subtopic'] = subtopic;
        }

        final question = QuestionModel.fromJson(normalized);
        final isValid =
            question.question.trim().isNotEmpty &&
            question.options.length == 4 &&
            question.options.every((option) => option.trim().isNotEmpty) &&
            question.options.toSet().length == 4 &&
            question.correctIndex >= 0 &&
            question.correctIndex < question.options.length;
        if (isValid) questions.add(question);
      } catch (_) {
        // Ignore one malformed AI item and fill the missing slot below.
      }
    }

    return questions;
  }

  List<QuestionModel> _fillQuestionBatch({
    required List<QuestionModel> generated,
    required List<QuestionModel> fallback,
    required int count,
  }) {
    final result = <QuestionModel>[];
    final seen = <String>{};

    for (final question in [...generated, ...fallback]) {
      final key = question.question.trim().toLowerCase();
      if (key.isEmpty || !seen.add(key)) continue;
      result.add(question);
      if (result.length == count) break;
    }
    return result;
  }

  List<QuestionModel> _diagnosticFallback(int chapterNumber) {
    return kDiagnosticQuestions
        .where((question) => question.chapterNumber == chapterNumber)
        .toList();
  }

  String _quizPrompt({
    required String chapter,
    required int chapterNumber,
    required String? subtopic,
    required int count,
    bool diagnostic = false,
  }) {
    return 'Return only valid JSON with key "questions". Generate $count Malaysian SPM Form 4 '
        'Chemistry multiple choice questions for Chapter $chapterNumber: $chapter'
        '${subtopic == null ? '' : ', subtopic: $subtopic'}. '
        '${diagnostic ? 'These questions are for a diagnostic assessment. Cover different important subtopics and use a balanced mix of recall, understanding, and application questions. ' : ''}'
        'Each object must follow exactly this schema: '
        '{"question":"...","options":["A text","B text","C text","D text"],'
        '"correctIndex":0,"feedbackCorrect":"...","feedbackWrong":"...",'
        '"shortLabel":"...","chapter":"$chapter","chapterNumber":$chapterNumber,'
        '"subtopic":"..."}. '
        'The options field is required and must contain exactly 4 distinct, non-empty answer choices. '
        'Use correctIndex values from 0 to 3. Include only one unambiguously correct answer. '
        'Make explanations concise and textbook-aligned. Do not repeat questions. Do not use markdown.';
  }

  String _studyPlanPrompt(List<ChapterDiagnosticScore> scores) {
    return 'Return only JSON for a personalised, self-paced SPM Form 4 Chemistry '
        'study plan made of stages - one stage per chapter, completed in order. '
        'Input scores: ${jsonEncode(scores.map((s) => s.toJson()).toList())}. '
        'Schema: {"stages":[{"stage":1,"title":"Chapter title","chapterNumber":1,'
        '"chapter":"Chapter title","tasks":["Finish lecture","Complete quiz"],'
        '"lectureCompleted":false,"quizCompleted":false,"completed":false}],'
        '"currentStageIndex":0,"allStagesCompleted":false,'
        '"weekly_goals":["..."],"motivational_message":"..."}. '
        'Each stage must focus on exactly one whole chapter, not a subtopic. '
        'Do not repeat a chapter in multiple stages. '
        'Stages should be ordered from weakest chapter to strongest chapter.';
  }

  String _chatPrompt({
    required String message,
    required List<Map<String, String>> history,
  }) {
    final recentHistory = history.length > 8
        ? history.sublist(history.length - 8)
        : history;

    return 'You are ARChem Tutor, a patient Malaysian SPM Form 4 Chemistry '
        'teacher inside a mobile learning app. Do not use RAG or mention a '
        'database. Answer using the Malaysian SPM Form 4 Chemistry syllabus '
        'whenever possible. Prioritise textbook-aligned explanations over '
        'general chemistry depth. If the student asks something outside Form 4, '
        'briefly say it is beyond the current syllabus, then give only the '
        'minimum useful context.\n\n'
        'Conversation handling:\n'
        '- Use the recent chat history to understand follow-up questions such '
        'as "why?", "how about this?", "explain more", or pronouns like '
        '"it" and "that".\n'
        '- If the follow-up is ambiguous, briefly state what you think the '
        'student is referring to before answering.\n\n'
        '${_chatAnswerFormat()}\n\n'
        'Tone: friendly, encouraging, precise, and exam-focused. Do not give '
        'unsafe or dishonest exam advice. Format the reply in markdown with '
        '**bold**, short headings, bullet lists, and tables only where helpful. '
        'For mathematical or chemical notation, use LaTeX wrapped in \\( ... \\) '
        'for inline expressions or \\[ ... \\] for standalone equations - never '
        'use dollar-sign (\$) delimiters for math. '
        'Chapters available: ${_chapterContext()}. '
        'Recent chat history JSON: ${jsonEncode(recentHistory)}. '
        'Student message: $message';
  }

  String _ragChatPrompt({
    required String message,
    required List<Map<String, String>> history,
    required List<Map<String, dynamic>> matches,
  }) {
    final recentHistory = history.length > 8
        ? history.sublist(history.length - 8)
        : history;

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

    return 'You are ARChem Tutor, a patient Malaysian SPM Form 4 Chemistry '
        'teacher inside a mobile learning app. Reference notes from the '
        'syllabus are given below. Use them as the main source whenever they '
        'are relevant, because they are authoritative for this app. If the '
        'notes do not cover the question or no notes matched, do not mention '
        'that to the student - answer naturally using Form 4 Chemistry '
        'knowledge. Never mention "RAG", "retrieval", "embeddings", '
        '"reference chunks", or "database" to the student.\n\n'
        'Conversation handling:\n'
        '- Use the recent chat history to understand follow-up questions such '
        'as "why?", "how about this?", "explain more", or pronouns like '
        '"it" and "that".\n'
        '- If the follow-up is ambiguous, briefly state what you think the '
        'student is referring to before answering.\n\n'
        '${_chatAnswerFormat()}\n\n'
        'Tone: friendly, encouraging, precise, and exam-focused. Do not give '
        'unsafe or dishonest exam advice. Format the reply in markdown with '
        '**bold**, short headings, bullet lists, and tables only where helpful. '
        'For mathematical or chemical notation, use LaTeX wrapped in \\( ... \\) '
        'for inline expressions or \\[ ... \\] for standalone equations - never '
        'use dollar-sign (\$) delimiters for math. '
        'Chapters available: ${_chapterContext()}.\n\n'
        'Reference notes:\n$context\n\n'
        'Recent chat history JSON: ${jsonEncode(recentHistory)}\n'
        'Student message: $message';
  }

  String _chapterContext() {
    return kChapters
        .map(
          (chapter) =>
              'Chapter ${chapter.number} ${chapter.title}: ${chapter.subtopics.join(', ')}',
        )
        .join(' | ');
  }

  String _chatAnswerFormat() {
    return 'Answer style rules:\n'
        '- First identify the student intent from the latest message and '
        'recent chat history: explanation, follow-up, examples, definition, '
        'quick fact, calculation, comparison, quiz request, or marking/help '
        'request.\n'
        '- Use the teaching format only when the latest student message '
        'starts with or clearly uses "what" or "explain". Do not use this '
        'format for "why", "how", follow-up, example-only, quiz, or quick '
        'fact requests unless the student also clearly says "explain".\n'
        '- For "what" or "explain" questions, reply with these markdown '
        'headings in this order:\n'
        '  **Answer**\n'
        '  Give 1-2 clear sentences that answer the question.\n'
        '  **Explanation**\n'
        '  Explain the idea step by step using simple SPM Form 4 language.\n'
        '  **Example**\n'
        '  Give one short Chemistry example, equation, or calculation. If '
        'the topic is conceptual, use a daily-life example.\n'
        '  **Quick check**\n'
        '  End with one small question for the student to try.\n'
        '- For follow-up questions, answer naturally based on the previous '
        'conversation. Do not restart the full format unless the follow-up '
        'uses "what" or "explain".\n'
        '- If the student asks for a quiz, such as "give me a quiz", '
        '"quiz me", or "ask me a question", provide exactly one MCQ question '
        'unless they ask for more. Include four options labelled A-D and put '
        'the answer after the options under **Answer**. Do not use the '
        'teaching format.\n'
        '- For "give examples" questions, give a short intro and a numbered '
        'or bulleted list of examples. Do not add Answer, Explanation, '
        'or Quick check headings unless needed.\n'
        '- For definition questions, give a concise definition and one simple '
        'example. Do not use the full teaching format.\n'
        '- For quick fact questions, answer directly in 1-3 sentences.\n'
        '- If the student made a misconception, include a short '
        '**Common mistake** note before the final sentence.\n'
        '- If the question involves calculation, show given values, formula, '
        'substitution, and final answer with units.\n'
        '- If the question involves comparison, use a compact table only when '
        'it improves clarity.\n'
        '- If the question involves equations, balance the equation and name '
        'the reaction type when useful.\n'
        '- Keep every reply short enough for a phone screen.';
  }

  Map<String, dynamic> _fallbackStudyPlan(List<ChapterDiagnosticScore> scores) {
    final weakest =
        (scores.isEmpty
                ? kChapters.map(
                    (chapter) => ChapterDiagnosticScore(
                      chapter: chapter.title,
                      chapterNumber: chapter.number,
                      score: 0,
                      maxScore: 1,
                    ),
                  )
                : scores)
            .toList()
          ..sort((a, b) => a.percentage.compareTo(b.percentage));
    final stages = List.generate(weakest.length, (index) {
      final score = weakest[index];
      return {
        'stage': index + 1,
        'title': score.chapter,
        'chapterNumber': score.chapterNumber,
        'chapter': score.chapter,
        'tasks': ['Finish the lecture', 'Complete the chapter quiz'],
        'lectureCompleted': false,
        'quizCompleted': false,
        'completed': false,
      };
    });

    return {
      'stages': stages,
      'currentStageIndex': 0,
      'allStagesCompleted': false,
      'weekly_goals': [
        'Improve weak chapters first',
        'Review mistakes after each quiz',
        'Complete at least one AR experiment',
      ],
      'motivational_message':
          'Small daily revision will make the full Form 4 syllabus feel manageable.',
    };
  }

  String _fallbackTutorReply(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('mole') || lower.contains('mol')) {
      return '**Mole concept**\n\n'
          'For mole questions, use \\( n = \\frac{mass}{molar\\ mass} \\). '
          'First identify the given mass, calculate the molar mass from the chemical formula, then substitute carefully with units.\n\n'
          '**Common mistake:** Students often forget to add all relative atomic masses in a compound before substituting into the formula.';
    }
    if (lower.contains('acid') ||
        lower.contains('alkali') ||
        lower.contains('base')) {
      return '**Acids and alkalis**\n\n'
          'Acids produce \\( H^+ \\) ions in water, while alkalis produce \\( OH^- \\) ions in water. '
          'For reactions, identify the reaction type first: neutralisation forms salt and water, while acid with metal forms salt and hydrogen gas.\n\n'
          '**Common mistake:** Do not call every base an alkali; an alkali is a base that dissolves in water.';
    }
    if (lower.contains('bond')) {
      return '**Chemical bonding**\n\n'
          'To identify the bond, ask whether electrons are transferred or shared. '
          'Electron transfer usually forms an ionic bond, while electron sharing forms a covalent bond.\n\n'
          '**Common mistake:** Ionic compounds form ions, but covalent compounds usually exist as molecules.';
    }
    return 'I cannot reach Gemini right now, but I can still help you revise. '
        'Try asking about a specific Form 4 Chemistry chapter, subtopic, equation, calculation step, or experiment observation.';
  }
}
