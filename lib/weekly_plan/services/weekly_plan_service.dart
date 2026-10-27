import 'package:supabase_flutter/supabase_flutter.dart';

import '../../chapters/chapters_data.dart';
import '../../models/question_model.dart';
import '../../services/gemini_api_client.dart';
import '../../services/supabase_service.dart';
import '../weekly_plan_prompts.dart';
import '../models/weekly_study_plan_model.dart';

/// Handles generation, adjustment, and persistence for the weekly study
/// plan feature. Kept self-contained in this feature folder (same pattern
/// as SubjectiveQuizService and MarkingService): reuses the existing public
/// SupabaseService singleton for reading progress, but owns its own Gemini
/// calls and its own Supabase table access rather than modifying
/// GeminiService or SupabaseService.
///
/// This is a fully separate system from the legacy stage-based study plan
/// (lib/study_plan/, table `study_plans`) - it never reads or writes that
/// table, by design.
class WeeklyPlanService {
  WeeklyPlanService._();
  static final WeeklyPlanService instance = WeeklyPlanService._();

  final _api = GeminiApiClient.instance;
  static const String _table = 'weekly_study_plans';

  Future<WeeklyStudyPlan?> fetchPlan({required DateTime weekStartDate}) async {
    final uid = SupabaseService.instance.userId;
    if (uid == null) return null;

    final row = await Supabase.instance.client
        .from(_table)
        .select()
        .eq('user_id', uid)
        .eq('week_start_date', _isoDate(weekStartDate))
        .maybeSingle();

    if (row == null) return null;
    return WeeklyStudyPlan.fromRow(row);
  }

  /// Builds a new week's plan from the student's current per-chapter quiz
  /// performance and saves it. Deliberately does NOT look at the previous
  /// week's `weekly_study_plans` row at all - chapters/subtopics not
  /// studied by the end of a week are simply dropped, not carried over,
  /// per an intentional simplification (flag for revisit if this app ever
  /// wants unfinished work to roll into the following week).
  Future<WeeklyStudyPlan> generatePlan({
    required DateTime weekStartDate,
  }) async {
    final scores = await _currentScores();
    return generatePlanFromScores(weekStartDate: weekStartDate, scores: scores);
  }

  Future<WeeklyStudyPlan> generatePlanFromScores({
    required DateTime weekStartDate,
    required List<ChapterDiagnosticScore> scores,
  }) async {
    Map<String, dynamic> daysJson;
    try {
      daysJson = await _generateJson(
        WeeklyPlanPrompts.generationPrompt(
          weekStartDate: weekStartDate,
          scores: scores,
        ),
        timeout: const Duration(seconds: 30),
      );
      final plan = WeeklyStudyPlan.fromGeneratedDaysJson(
        daysJson,
        weekStartDate: weekStartDate,
      );
      if (plan.days.values.every((blocks) => blocks.isEmpty)) {
        throw const FormatException('Gemini returned an entirely empty week');
      }
      return savePlan(plan);
    } catch (_) {
      return savePlan(
        _fallbackPlan(weekStartDate: weekStartDate, scores: scores),
      );
    }
  }

  Future<WeeklyStudyPlan> savePlan(WeeklyStudyPlan plan) async {
    final uid = SupabaseService.instance.userId;
    if (uid == null) return plan;

    // The table's primary key is `id`, not (user_id, week_start_date) - an
    // explicit onConflict is required or upsert() would insert a duplicate
    // row instead of updating this week's existing one.
    await Supabase.instance.client
        .from(_table)
        .upsert(plan.toRow(userId: uid), onConflict: 'user_id,week_start_date');

    return plan;
  }

  /// Asks Gemini to interpret a free-text adjustment request. Unlike
  /// [generatePlan], this has NO local fallback - any failure is rethrown
  /// so the adjustment dialog can show an explicit error + retry, per the
  /// feature spec (a silent guess here would be worse than asking the
  /// student to just try again).
  Future<AdjustmentResult> requestAdjustment({
    required String userRequest,
    required String selectedDayKey,
    required DateTime selectedDayDate,
    required DateTime deviceNow,
    required WeeklyStudyPlan currentPlan,
  }) async {
    final data = await _generateJson(
      WeeklyPlanPrompts.adjustmentPrompt(
        userRequest: userRequest,
        selectedDayKey: selectedDayKey,
        selectedDayDate: selectedDayDate,
        deviceNow: deviceNow,
        selectedDayBlocks: currentPlan.blocksFor(selectedDayKey),
        restOfWeekBlocks: currentPlan.days,
      ),
      timeout: const Duration(seconds: 20),
    );

    final rawChangedDays = _readMap(
      data['changed_days'] ?? data['changedDays'] ?? data['days'],
    );
    final changedDays = <String, List<StudyBlock>>{};
    rawChangedDays.forEach((key, value) {
      final dayKey = _normaliseDayKey(key, deviceNow: deviceNow);
      if (dayKey == null) return;
      final rawBlocks = value as List<dynamic>? ?? const [];
      changedDays[dayKey] = rawBlocks
          .whereType<Map<String, dynamic>>()
          .toList()
          .asMap()
          .entries
          .map((e) => StudyBlock.fromJson(e.value, id: '${dayKey}_${e.key}'))
          .toList();
    });

    if (changedDays.isEmpty) {
      final message = data['message'] as String?;
      if (message != null && message.trim().isNotEmpty) {
        return AdjustmentResult(
          changedDays: {selectedDayKey: currentPlan.blocksFor(selectedDayKey)},
          message: message,
        );
      }
      throw const FormatException(
        'Gemini could not decide which day to update. Try mentioning the day and time.',
      );
    }

    final message = data['message'] as String? ?? 'Plan updated.';
    return AdjustmentResult(changedDays: changedDays, message: message);
  }

  Future<WeeklyStudyPlan> saveMergedPlan(
    WeeklyStudyPlan plan,
    Map<String, List<StudyBlock>> changedDays,
  ) {
    return savePlan(plan.withMergedDays(changedDays));
  }

  /// Deterministic, no-network fallback used when Gemini generation fails.
  /// Ranks chapters by ascending score percentage (an unattempted chapter
  /// counts as 0%, i.e. weakest) and round-robins one block per weekday,
  /// plus a couple of weekend reinforcement blocks for the two weakest
  /// chapters.
  WeeklyStudyPlan _fallbackPlan({
    required DateTime weekStartDate,
    required List<ChapterDiagnosticScore> scores,
  }) {
    final byChapter = {for (final s in scores) s.chapterNumber: s.percentage};
    final ranked = List.of(kChapters)
      ..sort(
        (a, b) =>
            (byChapter[a.number] ?? 0.0).compareTo(byChapter[b.number] ?? 0.0),
      );

    List<StudyBlock> weekdayBlock(int index) {
      final chapter = ranked[index % ranked.length];
      final subtopic = chapter.subtopics[index % chapter.subtopics.length];
      return [
        StudyBlock(
          id: 'fallback_$index',
          chapterNumber: chapter.number,
          chapterTitle: chapter.title,
          subtopic: subtopic,
          startTime: '19:00',
          endTime: '20:00',
        ),
      ];
    }

    List<StudyBlock> weekendBlock(int rankIndex, int subtopicOffset) {
      final chapter = ranked[rankIndex % ranked.length];
      final subtopic =
          chapter.subtopics[subtopicOffset % chapter.subtopics.length];
      return [
        StudyBlock(
          id: 'fallback_weekend_$rankIndex',
          chapterNumber: chapter.number,
          chapterTitle: chapter.title,
          subtopic: subtopic,
          startTime: '10:00',
          endTime: '11:00',
        ),
      ];
    }

    final days = {
      'monday': weekdayBlock(0),
      'tuesday': weekdayBlock(1),
      'wednesday': weekdayBlock(2),
      'thursday': weekdayBlock(3),
      'friday': weekdayBlock(4),
      'saturday': weekendBlock(0, 5),
      'sunday': weekendBlock(1, 5),
    };

    final now = DateTime.now();
    return WeeklyStudyPlan(
      weekStartDate: weekStartDate,
      days: days,
      generatedAt: now,
      updatedAt: now,
    );
  }

  Future<List<ChapterDiagnosticScore>> _currentScores() async {
    final progress = await SupabaseService.instance.fetchProgress();
    final byChapter = {
      for (final row in progress) row['chapter_number'] as int: row,
    };

    return kChapters.map((chapter) {
      final row = byChapter[chapter.number];
      final score = row?['quiz_score'] as int? ?? 0;
      final maxScore = row?['max_score'] as int? ?? 1;
      return ChapterDiagnosticScore(
        chapter: chapter.title,
        chapterNumber: chapter.number,
        score: score,
        maxScore: maxScore,
      );
    }).toList();
  }

  Future<Map<String, dynamic>> _generateJson(
    String prompt, {
    required Duration timeout,
  }) async {
    return _api.generateJson(
      prompt: prompt,
      timeout: timeout,
      generationConfig: const {
        'responseMimeType': 'application/json',
        'temperature': 0.35,
      },
    );
  }

  Map<String, dynamic> _readMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return const {};
  }

  String? _normaliseDayKey(String raw, {required DateTime deviceNow}) {
    final cleaned = raw.trim().toLowerCase();
    for (final key in WeeklyStudyPlan.weekdayKeys) {
      if (cleaned == key) return key;
    }
    if (cleaned == 'today') {
      return WeeklyStudyPlan.weekdayKeys[deviceNow.weekday - DateTime.monday];
    }
    if (cleaned == 'tomorrow') {
      final tomorrow = deviceNow.add(const Duration(days: 1));
      return WeeklyStudyPlan.weekdayKeys[tomorrow.weekday - DateTime.monday];
    }
    return null;
  }

  String _isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
