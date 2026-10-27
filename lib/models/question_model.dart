/// Represents a single multiple choice question
/// used in both diagnostic test and regular quiz.
class QuestionModel {
  final String question;
  final List<String> options; // always 4 options
  final int correctIndex; // 0=A, 1=B, 2=C, 3=D
  final String feedbackCorrect;
  final String feedbackWrong;
  final String shortLabel; // short label for results review
  final String chapter;
  final int chapterNumber;
  final String? subtopic;

  const QuestionModel({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.feedbackCorrect,
    required this.feedbackWrong,
    required this.shortLabel,
    required this.chapter,
    required this.chapterNumber,
    this.subtopic,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final options = _readOptions(json);
    final correctIndex = _readCorrectIndex(json);
    final safeCorrectIndex = options.isEmpty
        ? 0
        : correctIndex.clamp(0, options.length - 1).toInt();

    return QuestionModel(
      question: json['question'] as String? ?? '',
      options: options,
      correctIndex: safeCorrectIndex,
      feedbackCorrect: json['feedbackCorrect'] as String? ?? '',
      feedbackWrong: json['feedbackWrong'] as String? ?? '',
      shortLabel: json['shortLabel'] as String? ?? '',
      chapter: json['chapter'] as String? ?? '',
      chapterNumber: json['chapterNumber'] as int? ?? 1,
      subtopic: json['subtopic'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'question': question,
    'options': options,
    'correctIndex': correctIndex,
    'feedbackCorrect': feedbackCorrect,
    'feedbackWrong': feedbackWrong,
    'shortLabel': shortLabel,
    'chapter': chapter,
    'chapterNumber': chapterNumber,
    'subtopic': subtopic,
  };

  static List<String> _readOptions(Map<String, dynamic> json) {
    final rawOptions = json['options'] ?? json['choices'] ?? json['answers'];

    if (rawOptions is List) {
      return rawOptions.map((option) => option.toString().trim()).toList();
    }

    if (rawOptions is Map) {
      const keys = ['A', 'B', 'C', 'D'];
      return keys
          .map((key) => rawOptions[key] ?? rawOptions[key.toLowerCase()])
          .where((option) => option != null)
          .map((option) => option.toString().trim())
          .toList();
    }

    const letterKeys = ['A', 'B', 'C', 'D'];
    final letterOptions = letterKeys
        .map((key) => json[key] ?? json[key.toLowerCase()])
        .where((option) => option != null)
        .map((option) => option.toString().trim())
        .toList();
    if (letterOptions.length == 4) return letterOptions;

    const optionKeys = ['optionA', 'optionB', 'optionC', 'optionD'];
    return optionKeys
        .map((key) => json[key])
        .where((option) => option != null)
        .map((option) => option.toString().trim())
        .toList();
  }

  static int _readCorrectIndex(Map<String, dynamic> json) {
    final raw = json['correctIndex'] ?? json['correct_index'];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) {
      final parsed = int.tryParse(raw);
      if (parsed != null) return parsed;
      final letter = raw.trim().toUpperCase();
      const letters = ['A', 'B', 'C', 'D'];
      final index = letters.indexOf(letter);
      if (index >= 0) return index;
    }

    final answer = json['correctAnswer'] ?? json['correct_answer'] ?? json['answer'];
    if (answer is String) {
      final options = _readOptions(json);
      final index = options.indexWhere(
        (option) => option.toLowerCase() == answer.trim().toLowerCase(),
      );
      if (index >= 0) return index;
    }

    return 0;
  }
}

/// Result for a single answered question
class QuestionResult {
  final QuestionModel question;
  final int selectedIndex;
  final bool isCorrect;

  const QuestionResult({
    required this.question,
    required this.selectedIndex,
    required this.isCorrect,
  });

  String get selectedAnswer =>
      selectedIndex >= 0 && selectedIndex < question.options.length
      ? question.options[selectedIndex]
      : 'No answer';

  String get correctAnswer => question.options[question.correctIndex];
}

/// Aggregated diagnostic score per chapter
class ChapterDiagnosticScore {
  final String chapter;
  final int chapterNumber;
  final int score;
  final int maxScore;

  const ChapterDiagnosticScore({
    required this.chapter,
    required this.chapterNumber,
    required this.score,
    required this.maxScore,
  });

  double get percentage => maxScore > 0 ? score / maxScore : 0.0;

  bool get isWeak => percentage < 0.6;
  bool get isStrong => percentage >= 0.8;

  Map<String, dynamic> toJson() => {
    'chapter': chapter,
    'chapter_number': chapterNumber,
    'score': score,
    'max_score': maxScore,
  };
}
