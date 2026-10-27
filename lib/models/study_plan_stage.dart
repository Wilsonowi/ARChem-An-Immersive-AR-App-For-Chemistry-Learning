import '../chapters/chapters_data.dart';
import 'chapter_model.dart';

class StudyPlanStage {
  final int stage;
  final String title;
  final int chapterNumber;
  final String chapter;
  final List<String> tasks;
  final bool lectureCompleted;
  final bool quizCompleted;
  final bool completed;

  const StudyPlanStage({
    required this.stage,
    required this.title,
    required this.chapterNumber,
    required this.chapter,
    this.tasks = const [],
    this.lectureCompleted = false,
    this.quizCompleted = false,
    this.completed = false,
  });

  factory StudyPlanStage.fromJson(Map<String, dynamic> json) {
    final chapterNumber =
        _asInt(json['chapterNumber'] ?? json['chapter_number']) ??
        _chapterNumberFromText(
          '${json['chapter'] ?? ''} ${json['chapterTitle'] ?? ''} ${json['chapter_title'] ?? ''}',
        ) ??
        1;
    final chapter = _chapterFor(chapterNumber);
    final rawTasks = json['tasks'] as List<dynamic>? ?? const [];
    final lectureDone =
        json['lectureCompleted'] as bool? ??
        json['lecture_completed'] as bool? ??
        false;
    final quizDone =
        json['quizCompleted'] as bool? ??
        json['quiz_completed'] as bool? ??
        false;
    final completed = json['completed'] as bool? ?? (lectureDone && quizDone);

    return StudyPlanStage(
      stage: _asInt(json['stage']) ?? 1,
      title:
          json['title'] as String? ??
          json['focus'] as String? ??
          json['chapter_title'] as String? ??
          chapter.title,
      chapterNumber: chapter.number,
      chapter: chapter.title,
      tasks: rawTasks.map((task) => task.toString()).toList(),
      lectureCompleted: lectureDone,
      quizCompleted: quizDone,
      completed: completed,
    );
  }

  Map<String, dynamic> toJson() => {
    'stage': stage,
    'title': title,
    'chapterNumber': chapterNumber,
    'chapter': chapter,
    'tasks': tasks,
    'lectureCompleted': lectureCompleted,
    'quizCompleted': quizCompleted,
    'completed': completed,
  };

  StudyPlanStage copyWith({
    int? stage,
    String? title,
    int? chapterNumber,
    String? chapter,
    List<String>? tasks,
    bool? lectureCompleted,
    bool? quizCompleted,
    bool? completed,
  }) {
    final nextLecture = lectureCompleted ?? this.lectureCompleted;
    final nextQuiz = quizCompleted ?? this.quizCompleted;
    return StudyPlanStage(
      stage: stage ?? this.stage,
      title: title ?? this.title,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      chapter: chapter ?? this.chapter,
      tasks: tasks ?? this.tasks,
      lectureCompleted: nextLecture,
      quizCompleted: nextQuiz,
      completed: completed ?? (nextLecture && nextQuiz),
    );
  }

  static Map<String, dynamic> normalizePlan(Map<String, dynamic> plan) {
    final normalized = Map<String, dynamic>.from(plan);
    final stages = _dedupeChapterStages(_readStages(normalized));
    normalized['stages'] = stages.map((stage) => stage.toJson()).toList();
    normalized['currentStageIndex'] = _currentStageIndex(stages);
    normalized['allStagesCompleted'] =
        stages.isNotEmpty && stages.every((s) => s.completed);
    return normalized;
  }

  static StudyPlanStage? currentFromPlan(Map<String, dynamic>? plan) {
    if (plan == null) return null;
    final normalized = normalizePlan(plan);
    final stages = _dedupeChapterStages(_readStages(normalized));
    if (stages.isEmpty) return null;
    final index =
        _asInt(normalized['currentStageIndex']) ?? _currentStageIndex(stages);
    return stages[index.clamp(0, stages.length - 1).toInt()];
  }

  static bool isComplete(Map<String, dynamic>? plan) {
    if (plan == null) return false;
    final normalized = normalizePlan(plan);
    return normalized['allStagesCompleted'] as bool? ?? false;
  }

  static Map<String, dynamic> markProgress({
    required Map<String, dynamic> plan,
    required int chapterNumber,
    bool lectureCompleted = false,
    bool quizCompleted = false,
  }) {
    final normalized = normalizePlan(plan);
    final stages = _dedupeChapterStages(_readStages(normalized));
    if (stages.isEmpty) return normalized;

    final index = stages.indexWhere((stage) {
      if (stage.completed || stage.chapterNumber != chapterNumber) return false;
      return true;
    });
    if (index < 0) return normalized;

    stages[index] = stages[index].copyWith(
      lectureCompleted: lectureCompleted ? true : null,
      quizCompleted: quizCompleted ? true : null,
    );
    normalized['stages'] = stages.map((stage) => stage.toJson()).toList();
    normalized['currentStageIndex'] = _currentStageIndex(stages);
    normalized['allStagesCompleted'] = stages.every((stage) => stage.completed);
    return normalized;
  }

  static List<StudyPlanStage> _readStages(Map<String, dynamic> plan) {
    final rawStages = plan['stages'];
    if (rawStages is List && rawStages.isNotEmpty) {
      return rawStages
          .whereType<Map<String, dynamic>>()
          .map(StudyPlanStage.fromJson)
          .toList();
    }

    return kChapters
        .map(
          (chapter) => StudyPlanStage(
            stage: chapter.number,
            title: chapter.title,
            chapterNumber: chapter.number,
            chapter: chapter.title,
            tasks: ['Finish the lecture', 'Complete the chapter quiz'],
          ),
        )
        .toList();
  }

  static int _currentStageIndex(List<StudyPlanStage> stages) {
    if (stages.isEmpty) return 0;
    final index = stages.indexWhere((stage) => !stage.completed);
    return index < 0 ? stages.length - 1 : index;
  }

  static List<StudyPlanStage> _dedupeChapterStages(
    List<StudyPlanStage> stages,
  ) {
    final seen = <int>{};
    final deduped = <StudyPlanStage>[];
    for (final stage in stages) {
      if (!seen.add(stage.chapterNumber)) continue;
      final chapter = _chapterFor(stage.chapterNumber);
      deduped.add(
        stage.copyWith(
          stage: deduped.length + 1,
          title: chapter.title,
          chapter: chapter.title,
        ),
      );
    }
    return deduped;
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static int? _chapterNumberFromText(String text) {
    final lower = text.toLowerCase();
    final match = RegExp(r'chapter\s*(\d+)').firstMatch(lower);
    if (match != null) return int.tryParse(match.group(1)!);
    for (final chapter in kChapters) {
      if (lower.contains(chapter.title.toLowerCase()) ||
          lower.contains(chapter.shortTitle.toLowerCase())) {
        return chapter.number;
      }
    }
    return null;
  }

  static ChapterModel _chapterFor(int number) {
    return kChapters.firstWhere(
      (chapter) => chapter.number == number,
      orElse: () => kChapters.first,
    );
  }
}
