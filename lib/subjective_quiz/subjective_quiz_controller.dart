import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../chapters/chapters_data.dart';
import '../models/chapter_model.dart';
import 'models/subjective_question_model.dart';
import 'services/subjective_quiz_service.dart';
import 'subjective_quiz_prompts.dart';

enum SubjectiveQuizPhase { generating, ready, marking, result, error }

class SubjectiveQuizState {
  final SubjectiveQuizPhase phase;
  final int chapterNumber;
  final List<SubjectiveQuestion> questions;
  final List<String> answers;
  final List<SubjectiveQuestionResult> result;
  final String? errorMessage;

  const SubjectiveQuizState({
    this.phase = SubjectiveQuizPhase.generating,
    required this.chapterNumber,
    this.questions = const [],
    this.answers = const ['', '', ''],
    this.result = const [],
    this.errorMessage,
  });

  SubjectiveQuizState copyWith({
    SubjectiveQuizPhase? phase,
    List<SubjectiveQuestion>? questions,
    List<String>? answers,
    List<SubjectiveQuestionResult>? result,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SubjectiveQuizState(
      phase: phase ?? this.phase,
      chapterNumber: chapterNumber,
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      result: result ?? this.result,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  bool get canSubmit =>
      questions.length == SubjectiveQuizPrompts.questionCount &&
      answers.every((a) => a.trim().isNotEmpty);

  int get totalAwarded =>
      result.fold(0, (sum, r) => sum + r.marksAwarded);
  int get totalPossible =>
      result.fold(0, (sum, r) => sum + r.marksPossible);
}

class SubjectiveQuizController extends StateNotifier<SubjectiveQuizState> {
  SubjectiveQuizController({required int chapterNumber})
    : _service = SubjectiveQuizService.instance,
      super(SubjectiveQuizState(chapterNumber: chapterNumber)) {
    generateQuestions();
  }

  final SubjectiveQuizService _service;

  ChapterModel? get _chapter {
    for (final chapter in kChapters) {
      if (chapter.number == state.chapterNumber) return chapter;
    }
    return null;
  }

  Future<void> generateQuestions() async {
    final chapter = _chapter;
    if (chapter == null) {
      state = state.copyWith(
        phase: SubjectiveQuizPhase.error,
        errorMessage: 'Chapter not found.',
      );
      return;
    }

    state = state.copyWith(phase: SubjectiveQuizPhase.generating, clearError: true);
    try {
      final questions = await _service.generateQuestions(
        chapterNumber: chapter.number,
        chapter: chapter.title,
        subtopics: chapter.subtopics,
      );
      state = state.copyWith(
        phase: SubjectiveQuizPhase.ready,
        questions: questions,
        answers: List.filled(questions.length, ''),
      );
    } catch (e, st) {
      debugPrint('generateQuestions failed: $e\n$st');
      state = state.copyWith(
        phase: SubjectiveQuizPhase.error,
        errorMessage:
            "Couldn't generate questions for this chapter. Check your "
            'connection and try again.'
            '${kDebugMode ? '\n\n[debug] $e' : ''}',
      );
    }
  }

  void updateAnswer(int index, String text) {
    if (index < 0 || index >= state.answers.length) return;
    final updated = [...state.answers];
    updated[index] = text;
    state = state.copyWith(answers: updated);
  }

  Future<void> submit() async {
    if (!state.canSubmit) return;

    state = state.copyWith(phase: SubjectiveQuizPhase.marking, clearError: true);
    try {
      final result = await _service.markAnswers(
        questions: state.questions,
        answers: state.answers,
      );
      state = state.copyWith(phase: SubjectiveQuizPhase.result, result: result);

      final chapter = _chapter;
      if (chapter != null) {
        unawaited(
          _service
              .saveAttempt(
                chapter: chapter.title,
                chapterNumber: chapter.number,
                questions: state.questions,
                answers: state.answers,
                results: result,
              )
              .catchError((e, st) => debugPrint('saveAttempt failed: $e\n$st')),
        );
      }
    } catch (e, st) {
      debugPrint('markAnswers failed: $e\n$st');
      state = state.copyWith(
        phase: SubjectiveQuizPhase.error,
        errorMessage:
            "Couldn't mark your answers. Check your connection and try "
            'again.'
            '${kDebugMode ? '\n\n[debug] $e' : ''}',
      );
    }
  }

  /// Retries whichever step failed - generation if we never got questions,
  /// submission if marking is what failed.
  Future<void> retry() async {
    if (state.questions.isEmpty) {
      await generateQuestions();
    } else {
      await submit();
    }
  }
}

final subjectiveQuizControllerProvider = StateNotifierProvider.autoDispose
    .family<SubjectiveQuizController, SubjectiveQuizState, int>(
      (ref, chapterNumber) =>
          SubjectiveQuizController(chapterNumber: chapterNumber),
    );
