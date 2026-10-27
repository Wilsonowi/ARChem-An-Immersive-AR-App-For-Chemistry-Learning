import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../chapters/chapters_data.dart';
import '../models/chapter_model.dart';
import '../models/question_model.dart';
import '../home/current_study_status.dart';
import '../home/home_controller.dart';
import '../services/gemini_service.dart';
import '../services/supabase_service.dart';
import '../weekly_plan/weekly_plan_controller.dart';

enum QuizPhase { loading, inProgress, saving, completed, error }

class QuizState {
  final QuizPhase phase;
  final int chapterNumber;
  final List<QuestionModel> questions;
  final int currentIndex;
  final List<QuestionResult> results;
  final int? selectedIndex;
  final String? errorMessage;
  final String? aiHint;
  final bool hintLoading;

  const QuizState({
    required this.chapterNumber,
    this.phase = QuizPhase.loading,
    this.questions = const [],
    this.currentIndex = 0,
    this.results = const [],
    this.selectedIndex,
    this.errorMessage,
    this.aiHint,
    this.hintLoading = false,
  });

  QuizState copyWith({
    QuizPhase? phase,
    List<QuestionModel>? questions,
    int? currentIndex,
    List<QuestionResult>? results,
    int? selectedIndex,
    String? errorMessage,
    String? aiHint,
    bool? hintLoading,
    bool clearSelection = false,
    bool clearHint = false,
    bool clearError = false,
  }) {
    return QuizState(
      chapterNumber: chapterNumber,
      phase: phase ?? this.phase,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      results: results ?? this.results,
      selectedIndex: clearSelection
          ? null
          : selectedIndex ?? this.selectedIndex,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      aiHint: clearHint ? null : aiHint ?? this.aiHint,
      hintLoading: hintLoading ?? this.hintLoading,
    );
  }

  QuestionModel? get currentQuestion =>
      currentIndex < questions.length ? questions[currentIndex] : null;
  int get totalQuestions => questions.length;
  int get score => results.where((result) => result.isCorrect).length;
  bool get answered => selectedIndex != null;
  bool get isLastQuestion => currentIndex >= questions.length - 1;
  double get progress =>
      totalQuestions == 0 ? 0 : (currentIndex + 1) / totalQuestions;
}

class QuizController extends StateNotifier<QuizState> {
  QuizController({required Ref ref, required int chapterNumber})
    : _gemini = GeminiService.instance,
      _supabase = SupabaseService.instance,
      _ref = ref,
      super(QuizState(chapterNumber: chapterNumber)) {
    load();
  }

  final GeminiService _gemini;
  final SupabaseService _supabase;
  final Ref _ref;

  Future<void> load() async {
    final chapter = _chapter;
    if (chapter == null) {
      state = state.copyWith(
        phase: QuizPhase.error,
        errorMessage: 'Chapter not found.',
      );
      return;
    }

    state = QuizState(chapterNumber: state.chapterNumber);
    final questions = await _gemini.generateQuizQuestions(
      chapter: chapter.title,
      chapterNumber: chapter.number,
      count: 5,
    );

    if (questions.isEmpty) {
      state = state.copyWith(
        phase: QuizPhase.error,
        errorMessage: 'Could not load quiz questions.',
      );
      return;
    }

    state = state.copyWith(
      phase: QuizPhase.inProgress,
      questions: questions,
      clearError: true,
    );
  }

  void selectAnswer(int index) {
    if (state.answered || state.currentQuestion == null) return;
    final question = state.currentQuestion!;
    final result = QuestionResult(
      question: question,
      selectedIndex: index,
      isCorrect: index == question.correctIndex,
    );
    state = state.copyWith(
      selectedIndex: index,
      results: [...state.results, result],
      clearHint: true,
    );
  }

  Future<void> loadHint() async {
    final question = state.currentQuestion;
    final selectedIndex = state.selectedIndex;
    if (question == null ||
        selectedIndex == null ||
        selectedIndex == question.correctIndex) {
      return;
    }

    state = state.copyWith(hintLoading: true);
    final hint = await _gemini.getAIHint(
      question: question.question,
      wrongAnswer: question.options[selectedIndex],
      correctAnswer: question.options[question.correctIndex],
      chapter: question.chapter,
    );
    state = state.copyWith(aiHint: hint, hintLoading: false);
  }

  Future<void> next() async {
    if (!state.answered) return;
    if (state.isLastQuestion) {
      await _completeQuiz();
      return;
    }

    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      clearSelection: true,
      clearHint: true,
      hintLoading: false,
    );
  }

  /// Used by the "Retry Quiz" button on the results screen - the student
  /// wants a fresh attempt, so this intentionally reloads new questions.
  Future<void> retry() async {
    await load();
  }

  /// Used by the "Try Again" button on the error screen, which only shows
  /// up after the student already finished the quiz but saving failed. The
  /// student's answers are already in [state.results] - resume the save
  /// instead of making them redo the quiz. Falls back to a full reload if
  /// there's nothing to resave (e.g. the initial question load failed).
  Future<void> retrySave() async {
    if (state.results.isEmpty) {
      await load();
      return;
    }
    await _completeQuiz();
  }

  Future<void> _completeQuiz() async {
    final chapter = _chapter;
    if (chapter == null) return;

    state = state.copyWith(phase: QuizPhase.saving);
    try {
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

      await _supabase.saveProgress(
        chapter: chapter.title,
        chapterNumber: chapter.number,
        quizScore: state.score,
        maxScore: state.totalQuestions,
      );

      _ref.invalidate(homeWeeklyPlanProvider);
      await Future.wait([
        _ref.read(homeControllerProvider.notifier).load(),
        _ref.read(weeklyPlanControllerProvider.notifier).refresh(),
      ]);

      state = state.copyWith(phase: QuizPhase.completed);
    } catch (_) {
      state = state.copyWith(
        phase: QuizPhase.error,
        errorMessage: 'Quiz completed, but results could not be saved.',
      );
    }
  }

  ChapterModel? get _chapter {
    for (final chapter in kChapters) {
      if (chapter.number == state.chapterNumber) return chapter;
    }
    return null;
  }
}

final quizControllerProvider = StateNotifierProvider.autoDispose
    .family<QuizController, QuizState, int>(
      (ref, chapterNumber) =>
          QuizController(ref: ref, chapterNumber: chapterNumber),
    );
