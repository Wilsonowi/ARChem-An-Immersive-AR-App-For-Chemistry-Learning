import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question_model.dart';
import '../services/gemini_service.dart';
import '../services/supabase_service.dart';
import '../weekly_plan/services/weekly_plan_service.dart';

// ── DIAGNOSTIC PHASE ──────────────────────────────────────
enum DiagnosticPhase {
  idle, // test has not started yet
  loading, // generating diagnostic questions
  inProgress, // student answering questions
  submitting, // saving results to Supabase
  generatingPlan, // Gemini generating study plan
  completed, // results saved and plan generated
  error, // something failed
}

// ── DIAGNOSTIC STATE ──────────────────────────────────────
class DiagnosticState {
  final DiagnosticPhase phase;
  final List<QuestionModel> questions;
  final int currentIndex;
  final List<QuestionResult> results;
  final String? errorMessage;
  final String statusMessage;
  final bool planGenerated;

  const DiagnosticState({
    this.phase = DiagnosticPhase.idle,
    this.questions = const [],
    this.currentIndex = 0,
    this.results = const [],
    this.errorMessage,
    this.statusMessage = 'Loading your diagnostic test...',
    this.planGenerated = false,
  });

  DiagnosticState copyWith({
    DiagnosticPhase? phase,
    List<QuestionModel>? questions,
    int? currentIndex,
    List<QuestionResult>? results,
    String? errorMessage,
    String? statusMessage,
    bool? planGenerated,
    bool clearError = false,
  }) {
    return DiagnosticState(
      phase: phase ?? this.phase,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      results: results ?? this.results,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      statusMessage: statusMessage ?? this.statusMessage,
      planGenerated: planGenerated ?? this.planGenerated,
    );
  }

  // ── COMPUTED ──────────────────────────────────────────
  int get totalQuestions => questions.length;
  bool get isLastQuestion => currentIndex >= totalQuestions - 1;
  double get progress =>
      totalQuestions > 0 ? (currentIndex + 1) / totalQuestions : 0.0;

  QuestionModel? get currentQuestion =>
      currentIndex < questions.length ? questions[currentIndex] : null;

  int chapterOf(int index) {
    if (index < questions.length) {
      return questions[index].chapterNumber;
    }
    return 1;
  }
}

// ── DIAGNOSTIC CONTROLLER ─────────────────────────────────
class DiagnosticController extends StateNotifier<DiagnosticState> {
  DiagnosticController() : super(const DiagnosticState());

  final _supabase = SupabaseService.instance;
  final _weeklyPlan = WeeklyPlanService.instance;
  final _gemini = GeminiService.instance;

  Future<void> startTest() async {
    state = const DiagnosticState();
    await _loadQuestions();
  }

  // ── LOAD QUESTIONS ────────────────────────────────────
  Future<void> _loadQuestions() async {
    state = state.copyWith(
      phase: DiagnosticPhase.loading,
      statusMessage: 'Loading your diagnostic test...',
    );

    try {
      final questions = await _gemini.generateDiagnosticQuestions();

      if (questions.isEmpty) {
        state = state.copyWith(
          phase: DiagnosticPhase.error,
          errorMessage: 'Diagnostic questions are not available yet.',
        );
        return;
      }

      state = state.copyWith(
        phase: DiagnosticPhase.inProgress,
        questions: questions,
      );
    } catch (e) {
      state = state.copyWith(
        phase: DiagnosticPhase.error,
        errorMessage: 'Could not load diagnostic questions.',
      );
    }
  }

  // ── ANSWER SELECTED ───────────────────────────────────
  void onAnswerSelected(int selectedIndex) {
    final current = state.currentQuestion;
    if (current == null) return;

    final isCorrect = selectedIndex == current.correctIndex;
    final result = QuestionResult(
      question: current,
      selectedIndex: selectedIndex,
      isCorrect: isCorrect,
    );

    final updatedResults = [...state.results, result];
    state = state.copyWith(results: updatedResults);
  }

  // ── NEXT QUESTION ─────────────────────────────────────
  Future<void> onNext() async {
    if (state.isLastQuestion) {
      await _submitDiagnostic();
    } else {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  // ── SUBMIT DIAGNOSTIC ─────────────────────────────────
  Future<void> _submitDiagnostic() async {
    state = state.copyWith(
      phase: DiagnosticPhase.submitting,
      statusMessage: 'Saving your results...',
    );

    try {
      // Calculate scores per chapter
      final scores = _calculateChapterScores();

      // Save diagnostic results to Supabase
      await _supabase.saveDiagnosticResults(
        scores.map((s) => s.toJson()).toList(),
      );

      // Save individual question results to quiz_history in one request.
      await _supabase.saveQuizQuestions(
        state.results
            .map(
              (result) => {
                'chapter': result.question.chapter,
                'chapter_number': result.question.chapterNumber,
                'subtopic': result.question.subtopic,
                'question_text': result.question.question,
                'selected_answer': result.selectedAnswer,
                'correct_answer': result.correctAnswer,
                'is_correct': result.isCorrect,
                'explanation': result.isCorrect
                    ? result.question.feedbackCorrect
                    : result.question.feedbackWrong,
              },
            )
            .toList(),
      );

      // Generate study plan
      state = state.copyWith(
        phase: DiagnosticPhase.generatingPlan,
        statusMessage: 'Analysing your results...',
      );

      await Future.delayed(const Duration(milliseconds: 800));

      state = state.copyWith(
        statusMessage: 'Building your personalised study plan...',
      );

      await _weeklyPlan.generatePlanFromScores(
        weekStartDate: _mondayOf(DateTime.now()),
        scores: scores,
      );

      // Mark diagnostic as complete on profile
      await _supabase.updateProfile(hasCompletedDiagnostic: true);

      state = state.copyWith(
        phase: DiagnosticPhase.completed,
        statusMessage: 'Your study plan is ready!',
        planGenerated: true,
      );
    } catch (e) {
      state = state.copyWith(
        phase: DiagnosticPhase.error,
        errorMessage: 'Failed to save results. Please check your connection.',
      );
    }
  }

  // ── CALCULATE SCORES PER CHAPTER ─────────────────────
  List<ChapterDiagnosticScore> _calculateChapterScores() {
    // Group results by chapter number
    final Map<int, List<QuestionResult>> byChapter = {};

    for (final result in state.results) {
      final n = result.question.chapterNumber;
      byChapter.putIfAbsent(n, () => []).add(result);
    }

    // Build score per chapter
    final scores = <ChapterDiagnosticScore>[];

    for (final entry in byChapter.entries) {
      final chapterNum = entry.key;
      final results = entry.value;
      final score = results.where((r) => r.isCorrect).length;
      final chapter = results.first.question.chapter;

      scores.add(
        ChapterDiagnosticScore(
          chapter: chapter,
          chapterNumber: chapterNum,
          score: score,
          maxScore: results.length,
        ),
      );
    }

    // Sort by chapter number
    scores.sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));
    return scores;
  }

  // ── RETRY ─────────────────────────────────────────────
  /// Retry after an error. If the student had already answered every
  /// question and the failure happened while saving, just retry the save -
  /// don't make them redo the whole diagnostic test. Only reset from
  /// scratch if the failure happened before the test was fully answered
  /// (e.g. questions failed to load).
  Future<void> retry() async {
    final fullyAnswered =
        state.questions.isNotEmpty &&
        state.results.length == state.questions.length;

    if (fullyAnswered) {
      await _submitDiagnostic();
      return;
    }

    state = const DiagnosticState();
    await _loadQuestions();
  }

  DateTime _mondayOf(DateTime date) {
    final midnight = DateTime(date.year, date.month, date.day);
    return midnight.subtract(Duration(days: midnight.weekday - DateTime.monday));
  }
}

// ── PROVIDER ──────────────────────────────────────────────
final diagnosticControllerProvider =
    StateNotifierProvider.autoDispose<DiagnosticController, DiagnosticState>(
      (ref) => DiagnosticController(),
    );
