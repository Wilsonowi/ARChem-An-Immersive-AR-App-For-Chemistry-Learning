/// One markable point in a question's mark scheme (not shown to the
/// student - only used internally when Gemini marks the answer later).
class MarkSchemePoint {
  final String point;
  final int marks;

  const MarkSchemePoint({required this.point, required this.marks});

  factory MarkSchemePoint.fromJson(Map<String, dynamic> json) {
    return MarkSchemePoint(
      point: json['point'] as String? ?? '',
      marks: _readInt(json['marks']),
    );
  }

  Map<String, dynamic> toJson() => {'point': point, 'marks': marks};

  static int _readInt(dynamic raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw) ?? 0;
    return 0;
  }
}

/// One Gemini-generated SPM-style subjective question, grounded in the
/// chapter's RAG reference chunks.
class SubjectiveQuestion {
  final String questionText;
  final int marks;
  final List<MarkSchemePoint> markScheme;

  const SubjectiveQuestion({
    required this.questionText,
    required this.marks,
    required this.markScheme,
  });

  factory SubjectiveQuestion.fromJson(Map<String, dynamic> json) {
    final rawScheme = json['mark_scheme'] as List<dynamic>? ?? const [];
    return SubjectiveQuestion(
      questionText: json['question'] as String? ?? '',
      marks: MarkSchemePoint._readInt(json['marks']),
      markScheme: rawScheme
          .whereType<Map<String, dynamic>>()
          .map(MarkSchemePoint.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'question': questionText,
    'marks': marks,
    'mark_scheme': markScheme.map((p) => p.toJson()).toList(),
  };
}

/// Gemini's marking result for one submitted answer.
class SubjectiveQuestionResult {
  final int marksAwarded;
  final int marksPossible;
  final String explanation;

  const SubjectiveQuestionResult({
    required this.marksAwarded,
    required this.marksPossible,
    required this.explanation,
  });

  factory SubjectiveQuestionResult.fromJson(Map<String, dynamic> json) {
    return SubjectiveQuestionResult(
      marksAwarded: MarkSchemePoint._readInt(json['marks_awarded']),
      marksPossible: MarkSchemePoint._readInt(json['marks_possible']),
      explanation: json['explanation'] as String? ?? '',
    );
  }
}
