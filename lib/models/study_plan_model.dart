import 'study_plan_stage.dart';

/// The full personalised study plan for a student.
///
/// The plan is self-paced and stage-based: one stage per chapter, completed
/// in order (finish the lecture and quiz to unlock the next stage) rather
/// than tied to fixed calendar days.
class StudyPlanModel {
  final String id;
  final String userId;
  final int examReadinessPercent;
  final List<String> weakChapters;
  final List<String> strongChapters;
  final List<StudyPlanStage> stages;
  final List<String> weeklyGoals;
  final String motivationalMessage;
  final DateTime generatedAt;
  final DateTime updatedAt;

  const StudyPlanModel({
    required this.id,
    required this.userId,
    required this.examReadinessPercent,
    required this.weakChapters,
    required this.strongChapters,
    required this.stages,
    required this.weeklyGoals,
    required this.motivationalMessage,
    required this.generatedAt,
    required this.updatedAt,
  });

  factory StudyPlanModel.fromJson(Map<String, dynamic> json) {
    final plan = json['plan'] as Map<String, dynamic>? ?? {};
    final normalizedPlan = StudyPlanStage.normalizePlan(plan);

    final rawStages = normalizedPlan['stages'] as List<dynamic>? ?? [];
    final stages = rawStages
        .whereType<Map<String, dynamic>>()
        .map(StudyPlanStage.fromJson)
        .toList();

    final rawGoals = normalizedPlan['weekly_goals'] as List<dynamic>? ?? [];
    final weeklyGoals = rawGoals.map((g) => g.toString()).toList();

    final rawWeak = json['weak_chapters'] as List<dynamic>? ?? [];
    final rawStrong = json['strong_chapters'] as List<dynamic>? ?? [];

    return StudyPlanModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      examReadinessPercent: json['exam_readiness_percent'] as int? ?? 0,
      weakChapters: rawWeak.map((w) => w.toString()).toList(),
      strongChapters: rawStrong.map((s) => s.toString()).toList(),
      stages: stages,
      weeklyGoals: weeklyGoals,
      motivationalMessage:
          normalizedPlan['motivational_message'] as String? ?? '',
      generatedAt:
          DateTime.tryParse(json['generated_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  bool get hasData => stages.isNotEmpty;

  /// The stage the student should work on next: the first incomplete
  /// stage, or the last stage if everything is done.
  StudyPlanStage? get currentStage {
    if (stages.isEmpty) return null;
    final index = stages.indexWhere((stage) => !stage.completed);
    return index < 0 ? stages.last : stages[index];
  }

  int get completedStages => stages.where((s) => s.completed).length;

  int get totalStages => stages.length;
}
