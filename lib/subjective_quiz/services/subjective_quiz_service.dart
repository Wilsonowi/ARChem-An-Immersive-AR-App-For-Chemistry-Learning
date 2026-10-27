import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/gemini_api_client.dart';
import '../../services/gemini_service.dart';
import '../../services/supabase_service.dart';
import '../models/subjective_question_model.dart';
import '../subjective_quiz_prompts.dart';

/// Handles the generation + marking pipeline for SPM-style subjective quiz
/// questions. Kept self-contained in the subjective_quiz feature folder:
/// reuses the existing public GeminiService/SupabaseService singletons for
/// embeddings and RAG retrieval, but owns its own Gemini JSON calls rather
/// than modifying those shared services (same pattern as MarkingService in
/// lib/answer_marking).
class SubjectiveQuizService {
  SubjectiveQuizService._();
  static final SubjectiveQuizService instance = SubjectiveQuizService._();

  final _api = GeminiApiClient.instance;
  static const double _relevanceThreshold = 0.55;
  static const int _matchCount = 10;

  /// Embeds a synthetic query built from the chapter's title/subtopics,
  /// retrieves the closest Form 4 Chemistry syllabus chunks (the same
  /// `chemistry_knowledge` table/RPC the RAG tutor and answer marking use),
  /// then asks Gemini to generate 3 subjective questions with mark schemes,
  /// grounded in those chunks.
  Future<List<SubjectiveQuestion>> generateQuestions({
    required int chapterNumber,
    required String chapter,
    required List<String> subtopics,
  }) async {
    List<Map<String, dynamic>> matches = const [];
    try {
      final queryEmbedding = await GeminiService.instance.embedText(
        '$chapter: ${subtopics.join(', ')}',
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
      // Retrieval failed - fall through and generate ungrounded rather than
      // failing the whole request.
    }

    final context = matches.isEmpty
        ? 'No reference notes matched this chapter closely enough.'
        : matches
              .map(
                (row) =>
                    '- ${row['topic_title']} (${row['section']}): '
                    '${row['content']}',
              )
              .join('\n\n');

    final data = await _generateJson(
      SubjectiveQuizPrompts.generationPrompt(
        chapter: chapter,
        referenceContext: context,
      ),
      timeout: const Duration(seconds: 30),
    );

    final rawQuestions = data['questions'] as List<dynamic>? ?? const [];
    final questions = rawQuestions
        .whereType<Map<String, dynamic>>()
        .map(SubjectiveQuestion.fromJson)
        .where((q) => q.questionText.isNotEmpty)
        .toList();

    if (questions.length != SubjectiveQuizPrompts.questionCount) {
      throw const FormatException(
        'Gemini did not return the expected number of questions',
      );
    }
    return questions;
  }

  /// Sends all 3 (question, mark scheme, student answer) triples to Gemini
  /// in one call and returns the marked result for each, in order.
  Future<List<SubjectiveQuestionResult>> markAnswers({
    required List<SubjectiveQuestion> questions,
    required List<String> answers,
  }) async {
    final data = await _generateJson(
      SubjectiveQuizPrompts.markingPrompt(
        questions: questions,
        answers: answers,
      ),
      timeout: const Duration(seconds: 30),
    );

    final rawResults = data['results'] as List<dynamic>? ?? const [];
    final results = rawResults
        .whereType<Map<String, dynamic>>()
        .map(SubjectiveQuestionResult.fromJson)
        .toList();

    if (results.length != questions.length) {
      throw const FormatException(
        'Gemini did not return a result for every question',
      );
    }
    return results;
  }

  /// Persists the marked attempt for the student's history. Best-effort:
  /// failure to save must never hide a result already shown on screen.
  Future<void> saveAttempt({
    required String chapter,
    required int chapterNumber,
    required List<SubjectiveQuestion> questions,
    required List<String> answers,
    required List<SubjectiveQuestionResult> results,
  }) async {
    final uid = SupabaseService.instance.userId;
    if (uid == null) return;

    var totalAwarded = 0;
    var totalPossible = 0;
    final questionRows = <Map<String, dynamic>>[];
    for (var i = 0; i < questions.length; i++) {
      final q = questions[i];
      final r = results[i];
      totalAwarded += r.marksAwarded;
      totalPossible += r.marksPossible;
      questionRows.add({
        'question': q.questionText,
        'marks': q.marks,
        'student_answer': i < answers.length ? answers[i] : '',
        'marks_awarded': r.marksAwarded,
        'explanation': r.explanation,
      });
    }

    await Supabase.instance.client.from('subjective_attempts').insert({
      'user_id': uid,
      'chapter': chapter,
      'chapter_number': chapterNumber,
      'questions': questionRows,
      'total_awarded': totalAwarded,
      'total_possible': totalPossible,
    });
  }

  Future<Map<String, dynamic>> _generateJson(
    String prompt, {
    required Duration timeout,
  }) async {
    return _api.generateJson(
      prompt: prompt,
      timeout: timeout,
      cleanJsonText: (text) => _escapeStrayLatexBackslashes(
        _api.cleanMarkdownJson(text),
      ),
    );
  }

  /// Safety net for when Gemini writes a LaTeX command (e.g. "\text{cm}")
  /// as a literal single backslash despite being told not to
  /// (SubjectiveQuizPrompts). "\t" alone is valid JSON for a tab character,
  /// so jsonDecode doesn't error on it - it silently reads "\text{cm}" as a
  /// tab followed by the literal text "ext{cm}", corrupting the question
  /// with no visible failure. Doubling the backslash before a known LaTeX
  /// command word first makes jsonDecode treat it as a literal backslash
  /// instead, preserving the original (still-ugly, but at least intact)
  /// text rather than corrupting it.
  static final _strayLatexBackslash = RegExp(
    r'\\(?=(text|frac|times|cdot|sqrt|left|right|rightarrow|leftarrow|'
    r'Delta|delta|circ|ce|mathrm|ldots)\b)',
  );

  String _escapeStrayLatexBackslashes(String json) {
    return json.replaceAll(_strayLatexBackslash, r'\\');
  }
}
