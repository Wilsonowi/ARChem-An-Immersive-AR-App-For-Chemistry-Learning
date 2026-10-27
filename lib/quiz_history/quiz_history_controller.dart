import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/quiz_history_model.dart';
import 'services/quiz_history_service.dart';

enum HistoryLoadPhase { loading, ready, error }

enum AnalysisPhase { idle, analyzing, ready, error }

class QuizHistoryState {
  final HistoryLoadPhase loadPhase;
  final List<McqAttempt> mcqAttempts;
  final List<SubjectiveAttempt> subjectiveAttempts;
  final String? loadError;

  final AnalysisPhase analysisPhase;
  final WeaknessAnalysis? analysis;
  final String? analysisError;

  const QuizHistoryState({
    this.loadPhase = HistoryLoadPhase.loading,
    this.mcqAttempts = const [],
    this.subjectiveAttempts = const [],
    this.loadError,
    this.analysisPhase = AnalysisPhase.idle,
    this.analysis,
    this.analysisError,
  });

  QuizHistoryState copyWith({
    HistoryLoadPhase? loadPhase,
    List<McqAttempt>? mcqAttempts,
    List<SubjectiveAttempt>? subjectiveAttempts,
    String? loadError,
    AnalysisPhase? analysisPhase,
    WeaknessAnalysis? analysis,
    String? analysisError,
  }) {
    return QuizHistoryState(
      loadPhase: loadPhase ?? this.loadPhase,
      mcqAttempts: mcqAttempts ?? this.mcqAttempts,
      subjectiveAttempts: subjectiveAttempts ?? this.subjectiveAttempts,
      loadError: loadError ?? this.loadError,
      analysisPhase: analysisPhase ?? this.analysisPhase,
      analysis: analysis ?? this.analysis,
      analysisError: analysisError ?? this.analysisError,
    );
  }

  bool get hasAnyHistory => mcqAttempts.isNotEmpty || subjectiveAttempts.isNotEmpty;
}

class QuizHistoryController extends StateNotifier<QuizHistoryState> {
  QuizHistoryController()
    : _service = QuizHistoryService.instance,
      super(const QuizHistoryState()) {
    _loadHistory();
  }

  final QuizHistoryService _service;

  Future<void> _loadHistory() async {
    state = state.copyWith(loadPhase: HistoryLoadPhase.loading);
    List<McqAttempt> mcqAttempts = const [];
    List<SubjectiveAttempt> subjectiveAttempts = const [];
    Object? firstError;
    StackTrace? firstStackTrace;

    try {
      mcqAttempts = await _service.fetchMcqAttempts();
    } catch (e, st) {
      firstError ??= e;
      firstStackTrace ??= st;
      debugPrint('fetchMcqAttempts failed: $e\n$st');
    }

    try {
      subjectiveAttempts = await _service.fetchSubjectiveAttempts();
    } catch (e, st) {
      firstError ??= e;
      firstStackTrace ??= st;
      debugPrint('fetchSubjectiveAttempts failed: $e\n$st');
    }

    if (firstError != null &&
        mcqAttempts.isEmpty &&
        subjectiveAttempts.isEmpty) {
      debugPrint('loadHistory failed: $firstError\n$firstStackTrace');
      state = state.copyWith(
        loadPhase: HistoryLoadPhase.error,
        loadError: "Couldn't load your quiz history. Check your connection "
            'and try again.',
      );
      return;
    }

    state = state.copyWith(
      loadPhase: HistoryLoadPhase.ready,
      mcqAttempts: mcqAttempts,
      subjectiveAttempts: subjectiveAttempts,
    );
  }

  Future<void> retryLoad() => _loadHistory();

  Future<void> analyzeWeaknesses() async {
    if (state.analysisPhase == AnalysisPhase.analyzing) return;
    state = state.copyWith(analysisPhase: AnalysisPhase.analyzing);
    try {
      final analysis = await _service.analyzeWeaknesses(
        mcqAttempts: state.mcqAttempts,
        subjectiveAttempts: state.subjectiveAttempts,
      );
      state = state.copyWith(
        analysisPhase: AnalysisPhase.ready,
        analysis: analysis,
      );
    } catch (e, st) {
      debugPrint('analyzeWeaknesses failed: $e\n$st');
      state = state.copyWith(
        analysisPhase: AnalysisPhase.error,
        analysisError:
            "Couldn't analyze your history right now. Check your "
            'connection and try again.',
      );
    }
  }
}

final quizHistoryControllerProvider =
    StateNotifierProvider.autoDispose<QuizHistoryController, QuizHistoryState>(
      (ref) => QuizHistoryController(),
    );
