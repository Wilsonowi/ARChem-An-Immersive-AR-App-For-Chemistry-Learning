import 'package:flutter/material.dart';

/// One scheduled study session within a day.
///
/// [id] is never persisted - it is derived client-side as
/// `dayKey_index` when a day's block list is parsed, purely so the UI
/// has a stable key for list/animation widgets within that single day.
class StudyBlock {
  final String id;
  final int chapterNumber;
  final String chapterTitle;
  final String subtopic;
  final String startTime; // "HH:mm", 24h
  final String endTime; // "HH:mm", 24h

  const StudyBlock({
    required this.id,
    required this.chapterNumber,
    required this.chapterTitle,
    required this.subtopic,
    required this.startTime,
    required this.endTime,
  });

  factory StudyBlock.fromJson(Map<String, dynamic> json, {required String id}) {
    return StudyBlock(
      id: id,
      chapterNumber: _readInt(json['chapterNumber']),
      chapterTitle: json['chapterTitle'] as String? ?? '',
      subtopic: json['subtopic'] as String? ?? '',
      startTime: json['startTime'] as String? ?? '00:00',
      endTime: json['endTime'] as String? ?? '00:00',
    );
  }

  Map<String, dynamic> toJson() => {
    'chapterNumber': chapterNumber,
    'chapterTitle': chapterTitle,
    'subtopic': subtopic,
    'startTime': startTime,
    'endTime': endTime,
  };

  static int _readInt(dynamic raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw) ?? 1;
    return 1;
  }

  TimeOfDay get start => _parseTime(startTime);
  TimeOfDay get end => _parseTime(endTime);

  static TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    final hour = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
    return TimeOfDay(hour: hour.clamp(0, 23), minute: minute.clamp(0, 59));
  }

  /// Minutes since midnight, used only for sorting blocks within a day.
  int get startMinutes => start.hour * 60 + start.minute;

  /// "7:00 PM" style display, hand-rolled since this project has no `intl`
  /// dependency and doesn't need one just for this.
  String get timeRangeLabel => '${_format12h(start)} - ${_format12h(end)}';

  static String _format12h(TimeOfDay time) {
    final hour12 = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour12:$minute $period';
  }
}

/// Result of an adjustment request: which day(s) changed and a short
/// confirmation message to show the student.
class AdjustmentResult {
  final Map<String, List<StudyBlock>> changedDays;
  final String message;

  const AdjustmentResult({required this.changedDays, required this.message});
}

/// A student's full study schedule for one Monday-Sunday week.
///
/// This is a fully separate system from the legacy stage-based
/// StudyPlanModel/StudyPlanStage (lib/models/study_plan_model.dart,
/// lib/models/study_plan_stage.dart) - it does not read or write that data
/// at all, by design.
class WeeklyStudyPlan {
  static const List<String> weekdayKeys = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  final DateTime weekStartDate; // Monday, time-of-day zeroed
  final Map<String, List<StudyBlock>> days; // always has all 7 keys
  final DateTime generatedAt;
  final DateTime updatedAt;

  const WeeklyStudyPlan({
    required this.weekStartDate,
    required this.days,
    required this.generatedAt,
    required this.updatedAt,
  });

  /// Builds a plan from a raw `weekly_study_plans` row (as returned by
  /// Supabase) rather than from the Gemini response shape directly - see
  /// [fromGeneratedDaysJson] for parsing a bare `{"days": {...}}` payload.
  factory WeeklyStudyPlan.fromRow(Map<String, dynamic> row) {
    final rawDays = (row['plan'] as Map?)?['days'] as Map<String, dynamic>? ?? const {};
    return WeeklyStudyPlan(
      weekStartDate: DateTime.parse(row['week_start_date'] as String),
      days: _parseDays(rawDays),
      generatedAt:
          DateTime.tryParse(row['generated_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse(row['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  /// Builds a fresh plan from a `{"days": {...}}` payload (either Gemini's
  /// generation response or the deterministic fallback), stamping both
  /// timestamps to now.
  factory WeeklyStudyPlan.fromGeneratedDaysJson(
    Map<String, dynamic> daysJson, {
    required DateTime weekStartDate,
  }) {
    final now = DateTime.now();
    return WeeklyStudyPlan(
      weekStartDate: weekStartDate,
      days: _parseDays(daysJson['days'] as Map<String, dynamic>? ?? const {}),
      generatedAt: now,
      updatedAt: now,
    );
  }

  static Map<String, List<StudyBlock>> _parseDays(Map<String, dynamic> raw) {
    final result = <String, List<StudyBlock>>{};
    for (final key in weekdayKeys) {
      final rawBlocks = raw[key] as List<dynamic>? ?? const [];
      result[key] = rawBlocks
          .whereType<Map<String, dynamic>>()
          .toList()
          .asMap()
          .entries
          .map((e) => StudyBlock.fromJson(e.value, id: '${key}_${e.key}'))
          .toList();
    }
    return result;
  }

  Map<String, dynamic> toRow({required String userId}) => {
    'user_id': userId,
    'week_start_date':
        '${weekStartDate.year.toString().padLeft(4, '0')}-'
        '${weekStartDate.month.toString().padLeft(2, '0')}-'
        '${weekStartDate.day.toString().padLeft(2, '0')}',
    'plan': {
      'days': {
        for (final key in weekdayKeys)
          key: (days[key] ?? const []).map((b) => b.toJson()).toList(),
      },
    },
    'generated_at': generatedAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  List<StudyBlock> blocksFor(String dayKey) {
    final blocks = List<StudyBlock>.of(days[dayKey] ?? const []);
    blocks.sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
    return blocks;
  }

  /// Returns a copy with only [changedDays]'s keys replaced - every other
  /// day's block list is the exact same object, untouched. This is the
  /// whole mechanism behind "adjust only the affected day(s)".
  WeeklyStudyPlan withMergedDays(Map<String, List<StudyBlock>> changedDays) {
    final merged = Map<String, List<StudyBlock>>.of(days);
    changedDays.forEach((key, blocks) {
      if (weekdayKeys.contains(key)) merged[key] = blocks;
    });
    return WeeklyStudyPlan(
      weekStartDate: weekStartDate,
      days: merged,
      generatedAt: generatedAt,
      updatedAt: DateTime.now(),
    );
  }
}
