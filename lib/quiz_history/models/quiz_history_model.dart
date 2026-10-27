/// One MCQ question within a past attempt.
class McqHistoryQuestion {
  final String questionText;
  final String? selectedAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final String? explanation;

  const McqHistoryQuestion({
    required this.questionText,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.explanation,
  });

  factory McqHistoryQuestion.fromRow(Map<String, dynamic> row) {
    return McqHistoryQuestion(
      questionText: row['question_text'] as String? ?? '',
      selectedAnswer: row['selected_answer'] as String?,
      correctAnswer: row['correct_answer'] as String? ?? '',
      isCorrect: row['is_correct'] as bool? ?? false,
      explanation: row['explanation'] as String?,
    );
  }
}

/// One past MCQ quiz attempt - a group of `quiz_history` rows saved
/// together in the same insert (same chapter + same `created_at`, since
/// QuizController.saveQuizQuestions batches one quiz's results into a
/// single insert call, and Postgres's now() is stable within one
/// statement).
class McqAttempt {
  final String chapter;
  final int chapterNumber;
  final DateTime createdAt;
  final List<McqHistoryQuestion> questions;

  const McqAttempt({
    required this.chapter,
    required this.chapterNumber,
    required this.createdAt,
    required this.questions,
  });

  int get score => questions.where((q) => q.isCorrect).length;
  int get total => questions.length;
}

/// One question within a past subjective attempt (unpacked from the
/// `questions` jsonb column on `subjective_attempts`).
class SubjectiveHistoryQuestion {
  final String question;
  final int marks;
  final String studentAnswer;
  final int marksAwarded;
  final String explanation;

  const SubjectiveHistoryQuestion({
    required this.question,
    required this.marks,
    required this.studentAnswer,
    required this.marksAwarded,
    required this.explanation,
  });

  factory SubjectiveHistoryQuestion.fromJson(Map<String, dynamic> json) {
    return SubjectiveHistoryQuestion(
      question: json['question'] as String? ?? '',
      marks: _readInt(json['marks']),
      studentAnswer: json['student_answer'] as String? ?? '',
      marksAwarded: _readInt(json['marks_awarded']),
      explanation: json['explanation'] as String? ?? '',
    );
  }

  static int _readInt(dynamic raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return 0;
  }
}

/// One past subjective quiz attempt - maps directly to one
/// `subjective_attempts` row.
class SubjectiveAttempt {
  final String chapter;
  final int chapterNumber;
  final DateTime createdAt;
  final int totalAwarded;
  final int totalPossible;
  final List<SubjectiveHistoryQuestion> questions;

  const SubjectiveAttempt({
    required this.chapter,
    required this.chapterNumber,
    required this.createdAt,
    required this.totalAwarded,
    required this.totalPossible,
    required this.questions,
  });

  factory SubjectiveAttempt.fromRow(Map<String, dynamic> row) {
    final rawQuestions = row['questions'] as List<dynamic>? ?? const [];
    return SubjectiveAttempt(
      chapter: row['chapter'] as String? ?? '',
      chapterNumber: (row['chapter_number'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ??
          DateTime.now(),
      totalAwarded: (row['total_awarded'] as num?)?.toInt() ?? 0,
      totalPossible: (row['total_possible'] as num?)?.toInt() ?? 0,
      questions: rawQuestions
          .whereType<Map<String, dynamic>>()
          .map(SubjectiveHistoryQuestion.fromJson)
          .toList(),
    );
  }
}

/// One weak topic identified by the AI analysis.
class WeakTopic {
  final String topic;
  final int? chapterNumber;
  final String reason;

  const WeakTopic({
    required this.topic,
    required this.chapterNumber,
    required this.reason,
  });

  factory WeakTopic.fromJson(Map<String, dynamic> json) {
    return WeakTopic(
      topic: json['topic'] as String? ?? '',
      chapterNumber: (json['chapter_number'] as num?)?.toInt(),
      reason: json['reason'] as String? ?? '',
    );
  }
}

/// AI-generated analysis of the student's weak topics, derived from their
/// aggregated MCQ + subjective quiz history.
class WeaknessAnalysis {
  final String overallSummary;
  final List<WeakTopic> weakTopics;

  const WeaknessAnalysis({
    required this.overallSummary,
    required this.weakTopics,
  });

  factory WeaknessAnalysis.fromJson(Map<String, dynamic> json) {
    final rawTopics = json['weak_topics'] as List<dynamic>? ?? const [];
    return WeaknessAnalysis(
      overallSummary: json['overall_summary'] as String? ?? '',
      weakTopics: rawTopics
          .whereType<Map<String, dynamic>>()
          .map(WeakTopic.fromJson)
          .toList(),
    );
  }
}
