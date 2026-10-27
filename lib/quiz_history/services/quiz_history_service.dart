import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/gemini_api_client.dart';
import '../../services/supabase_service.dart';
import '../models/quiz_history_model.dart';

/// Reads past MCQ + subjective quiz attempts and generates an AI weakness
/// analysis from them. Kept self-contained in this feature folder (same
/// pattern as MarkingService/SubjectiveQuizService): reuses the existing
/// public SupabaseService singleton for the user id, but owns its own
/// Supabase table reads and Gemini call rather than modifying
/// SupabaseService or GeminiService.
class QuizHistoryService {
  QuizHistoryService._();
  static final QuizHistoryService instance = QuizHistoryService._();

  final _api = GeminiApiClient.instance;

  /// Fetches every `quiz_history` row for the current user and groups them
  /// into attempts: rows saved by the same `saveQuizQuestions` batch share
  /// the same chapter and the same `created_at` (Postgres's now() is
  /// stable within one insert statement), so that pair is used as the
  /// grouping key.
  Future<List<McqAttempt>> fetchMcqAttempts() async {
    final uid = SupabaseService.instance.userId;
    if (uid == null) return [];

    final rows = await Supabase.instance.client
        .from('quiz_history')
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: false);

    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final row in List<Map<String, dynamic>>.from(rows)) {
      final key = '${row['chapter_number']}_${row['created_at']}';
      grouped.putIfAbsent(key, () => []).add(row);
    }

    return grouped.values.map((groupRows) {
      final first = groupRows.first;
      return McqAttempt(
        chapter: first['chapter'] as String? ?? '',
        chapterNumber: (first['chapter_number'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.tryParse(first['created_at'] as String? ?? '') ??
            DateTime.now(),
        questions: groupRows.map(McqHistoryQuestion.fromRow).toList(),
      );
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<SubjectiveAttempt>> fetchSubjectiveAttempts() async {
    final uid = SupabaseService.instance.userId;
    if (uid == null) return [];

    final rows = await Supabase.instance.client
        .from('subjective_attempts')
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(
      rows,
    ).map(SubjectiveAttempt.fromRow).toList();
  }

  /// Aggregates per-chapter accuracy from both quiz types (computed here in
  /// Dart, not by Gemini) and asks Gemini to turn those numbers into a
  /// short diagnostic: an overall summary plus specific weak topics. No RAG
  /// retrieval needed - this analyzes the student's own performance data,
  /// not chemistry content.
  Future<WeaknessAnalysis> analyzeWeaknesses({
    required List<McqAttempt> mcqAttempts,
    required List<SubjectiveAttempt> subjectiveAttempts,
  }) async {
    final summary = _buildPerformanceSummary(mcqAttempts, subjectiveAttempts);

    final prompt =
        'You are analysing a Malaysian SPM Form 4 Chemistry student\'s quiz '
        'history to identify their weak topics. Below is their per-chapter '
        'performance across multiple-choice and subjective (structured-'
        'response) quizzes.\n\n'
        '$summary\n\n'
        'Write a short (2-3 sentence) overall summary of their performance, '
        'then list the specific topics/chapters they are weakest in '
        '(lowest accuracy, or chapters not yet attempted are not weaknesses '
        '- only comment on chapters with actual attempts), with a brief '
        'reason for each grounded in the numbers above. List at most 4 weak '
        'topics; if performance is strong everywhere, say so and return an '
        'empty list.\n\n'
        'Return only valid JSON, no markdown fences, no commentary, with '
        'exactly this schema: {"overall_summary":"...","weak_topics":'
        '[{"topic":"...","chapter_number":0,"reason":"..."}]}.';

    final data = await _generateJson(prompt, timeout: const Duration(seconds: 30));
    return WeaknessAnalysis.fromJson(data);
  }

  String _buildPerformanceSummary(
    List<McqAttempt> mcqAttempts,
    List<SubjectiveAttempt> subjectiveAttempts,
  ) {
    if (mcqAttempts.isEmpty && subjectiveAttempts.isEmpty) {
      return 'The student has not attempted any quizzes yet.';
    }

    final byChapter = <int, _ChapterStats>{};
    for (final attempt in mcqAttempts) {
      final stats = byChapter.putIfAbsent(
        attempt.chapterNumber,
        () => _ChapterStats(attempt.chapter),
      );
      stats.mcqCorrect += attempt.score;
      stats.mcqTotal += attempt.total;
    }
    for (final attempt in subjectiveAttempts) {
      final stats = byChapter.putIfAbsent(
        attempt.chapterNumber,
        () => _ChapterStats(attempt.chapter),
      );
      stats.subjectiveAwarded += attempt.totalAwarded;
      stats.subjectivePossible += attempt.totalPossible;
    }

    final lines = byChapter.entries.map((entry) {
      final n = entry.key;
      final s = entry.value;
      final parts = <String>[];
      if (s.mcqTotal > 0) {
        final pct = (s.mcqCorrect / s.mcqTotal * 100).round();
        parts.add('MCQ: ${s.mcqCorrect}/${s.mcqTotal} ($pct%)');
      }
      if (s.subjectivePossible > 0) {
        final pct = (s.subjectiveAwarded / s.subjectivePossible * 100).round();
        parts.add(
          'Subjective: ${s.subjectiveAwarded}/${s.subjectivePossible} ($pct%)',
        );
      }
      return 'Chapter $n (${s.chapter}): ${parts.join(', ')}';
    });

    return lines.join('\n');
  }

  Future<Map<String, dynamic>> _generateJson(
    String prompt, {
    required Duration timeout,
  }) async {
    return _api.generateJson(prompt: prompt, timeout: timeout);
  }
}

class _ChapterStats {
  final String chapter;
  int mcqCorrect = 0;
  int mcqTotal = 0;
  int subjectiveAwarded = 0;
  int subjectivePossible = 0;

  _ChapterStats(this.chapter);
}
