/// Per-field OCR confidence, as self-reported by the vision model.
enum ConfidenceLevel {
  high,
  medium,
  low;

  factory ConfidenceLevel.fromJson(dynamic raw) {
    switch (raw?.toString().trim().toLowerCase()) {
      case 'high':
        return ConfidenceLevel.high;
      case 'medium':
        return ConfidenceLevel.medium;
      default:
        return ConfidenceLevel.low;
    }
  }

  String toJson() => name;
}

class OcrExtraction {
  final String questionText;
  final int? marksAllocated;
  final String studentAnswerText;
  final ConfidenceLevel questionConfidence;
  final ConfidenceLevel marksConfidence;
  final ConfidenceLevel answerConfidence;

  const OcrExtraction({
    required this.questionText,
    required this.marksAllocated,
    required this.studentAnswerText,
    required this.questionConfidence,
    required this.marksConfidence,
    required this.answerConfidence,
  });

  OcrExtraction copyWith({
    String? questionText,
    int? marksAllocated,
    bool clearMarksAllocated = false,
    String? studentAnswerText,
  }) {
    return OcrExtraction(
      questionText: questionText ?? this.questionText,
      marksAllocated: clearMarksAllocated
          ? null
          : marksAllocated ?? this.marksAllocated,
      studentAnswerText: studentAnswerText ?? this.studentAnswerText,
      questionConfidence: questionConfidence,
      marksConfidence: marksConfidence,
      answerConfidence: answerConfidence,
    );
  }

  /// True if any field was extracted with low confidence - the UI warns the
  /// student to check/correct the relevant field(s) before marking rather
  /// than silently marking a possibly-wrong transcription.
  bool get hasLowConfidence =>
      questionConfidence == ConfidenceLevel.low ||
      marksConfidence == ConfidenceLevel.low ||
      answerConfidence == ConfidenceLevel.low;

  factory OcrExtraction.fromJson(Map<String, dynamic> json) {
    final confidence = json['confidence'] as Map<String, dynamic>? ?? const {};
    return OcrExtraction(
      questionText: (json['question_text'] as String? ?? '').trim(),
      marksAllocated: _readNullableInt(json['marks_allocated']),
      studentAnswerText: (json['student_answer_text'] as String? ?? '').trim(),
      questionConfidence: ConfidenceLevel.fromJson(confidence['question_text']),
      marksConfidence: ConfidenceLevel.fromJson(confidence['marks_allocated']),
      answerConfidence: ConfidenceLevel.fromJson(confidence['student_answer_text']),
    );
  }

  static int? _readNullableInt(dynamic raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }
}

/// One marked point within a student's answer.
class MarkingBreakdownPoint {
  final String point;
  final bool correct;
  final String comment;

  const MarkingBreakdownPoint({
    required this.point,
    required this.correct,
    required this.comment,
  });

  factory MarkingBreakdownPoint.fromJson(Map<String, dynamic> json) {
    return MarkingBreakdownPoint(
      point: json['point'] as String? ?? '',
      correct: json['correct'] as bool? ?? false,
      comment: json['comment'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'point': point,
    'correct': correct,
    'comment': comment,
  };
}

/// Separate mark summary for each question detected in one uploaded photo.
class MarkingQuestionScore {
  final String questionLabel;
  final String answerLabel;
  final double score;
  final double maxScore;
  final String explanation;

  const MarkingQuestionScore({
    required this.questionLabel,
    this.answerLabel = '',
    required this.score,
    required this.maxScore,
    required this.explanation,
  });

  factory MarkingQuestionScore.fromJson(Map<String, dynamic> json) {
    return MarkingQuestionScore(
      questionLabel: json['question_label'] as String? ?? 'Question',
      answerLabel: json['answer_label'] as String? ?? '',
      score: MarkingResult._readNum(json['score']),
      maxScore: MarkingResult._readNum(json['max_score'], fallback: 1),
      explanation: json['explanation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'question_label': questionLabel,
    'answer_label': answerLabel,
    'score': score,
    'max_score': maxScore,
    'explanation': explanation,
  };
}

/// Structured AI marking result for a handwritten answer, grounded in the
/// RAG reference chunks that were retrieved for the question.
class MarkingResult {
  final double score;
  final double maxScore;
  final List<MarkingQuestionScore> questionScores;
  final List<MarkingBreakdownPoint> breakdown;
  final String explanation;
  final List<String> matchedReferenceIds;

  const MarkingResult({
    required this.score,
    required this.maxScore,
    this.questionScores = const [],
    required this.breakdown,
    required this.explanation,
    required this.matchedReferenceIds,
  });

  factory MarkingResult.fromJson(Map<String, dynamic> json) {
    final rawBreakdown = json['breakdown'] as List<dynamic>? ?? const [];
    final rawQuestionScores =
        json['question_scores'] as List<dynamic>? ?? const [];
    final rawIds = json['matched_reference_ids'] as List<dynamic>? ?? const [];

    return MarkingResult(
      score: _readNum(json['score']),
      maxScore: _readNum(json['max_score'], fallback: 10),
      questionScores: rawQuestionScores
          .whereType<Map<String, dynamic>>()
          .map(MarkingQuestionScore.fromJson)
          .toList(),
      breakdown: rawBreakdown
          .whereType<Map<String, dynamic>>()
          .map(MarkingBreakdownPoint.fromJson)
          .toList(),
      explanation: json['explanation'] as String? ?? '',
      matchedReferenceIds: rawIds.map((id) => id.toString()).toList(),
    );
  }

  static double _readNum(dynamic raw, {double fallback = 0}) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw) ?? fallback;
    return fallback;
  }

  Map<String, dynamic> toJson() => {
    'score': score,
    'max_score': maxScore,
    'question_scores': questionScores
        .map((questionScore) => questionScore.toJson())
        .toList(),
    'breakdown': breakdown.map((point) => point.toJson()).toList(),
    'explanation': explanation,
    'matched_reference_ids': matchedReferenceIds,
  };
}
