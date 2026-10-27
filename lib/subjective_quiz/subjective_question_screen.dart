import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../widgets/chemistry_background.dart';
import 'models/subjective_question_model.dart';
import 'subjective_quiz_controller.dart';

class SubjectiveQuestionScreen extends ConsumerStatefulWidget {
  final int chapterNumber;

  const SubjectiveQuestionScreen({super.key, required this.chapterNumber});

  @override
  ConsumerState<SubjectiveQuestionScreen> createState() =>
      _SubjectiveQuestionScreenState();
}

class _SubjectiveQuestionScreenState
    extends ConsumerState<SubjectiveQuestionScreen> {
  final _answerControllers = <TextEditingController>[];

  @override
  void dispose() {
    for (final c in _answerControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncControllers(int count) {
    while (_answerControllers.length < count) {
      _answerControllers.add(TextEditingController());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      subjectiveQuizControllerProvider(widget.chapterNumber),
    );
    final controller = ref.read(
      subjectiveQuizControllerProvider(widget.chapterNumber).notifier,
    );
    _syncControllers(state.answers.length);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('Subjective Quiz', style: AppTextStyles.headingSmall),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: ChemistryBackground(
        // Purple theme for the quiz module - this screen's content was
        // already indigo-themed; only its background gradient/particles
        // (still defaulting to blue) needed the override.
        gradientCenter: Colors.white,
        gradientEdge: AppColors.lilacGlow,
        gridColor: AppColors.indigo,
        accentColor: AppColors.indigo,
        child: SafeArea(
          child: switch (state.phase) {
            SubjectiveQuizPhase.generating => const _LoadingView(
                label: 'Generating your questions...',
              ),
            SubjectiveQuizPhase.error => _ErrorView(
                message: state.errorMessage ?? 'Something went wrong.',
                onRetry: controller.retry,
              ),
            SubjectiveQuizPhase.result => _ResultView(
                state: state,
                onDone: () => context.go('/quiz-subjective'),
              ),
            _ => _QuestionsView(
                state: state,
                controllers: _answerControllers,
                onAnswerChanged: controller.updateAnswer,
                onSubmit: controller.submit,
              ),
          },
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  final String label;

  const _LoadingView({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.indigo),
          const SizedBox(height: 16),
          Text(label, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

class _QuestionsView extends StatelessWidget {
  final SubjectiveQuizState state;
  final List<TextEditingController> controllers;
  final void Function(int index, String text) onAnswerChanged;
  final VoidCallback onSubmit;

  const _QuestionsView({
    required this.state,
    required this.controllers,
    required this.onAnswerChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final marking = state.phase == SubjectiveQuizPhase.marking;

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: state.questions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _QuestionCard(
                index: index,
                question: state.questions[index],
                controller: controllers[index],
                enabled: !marking,
                onChanged: (text) => onAnswerChanged(index, text),
              ).animate(delay: Duration(milliseconds: index * 80)).fadeIn();
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: state.canSubmit && !marking ? onSubmit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.indigo,
              ),
              child: marking
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      'Submit',
                      style: AppTextStyles.button.copyWith(color: Colors.white),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final int index;
  final SubjectiveQuestion question;
  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onChanged;

  const _QuestionCard({
    required this.index,
    required this.question,
    required this.controller,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Question ${index + 1}',
                  style: AppTextStyles.labelSmall,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.indigoDim,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${question.marks} marks',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.indigo,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            question.questionText,
            style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: controller,
            enabled: enabled,
            minLines: 3,
            maxLines: 8,
            style: AppTextStyles.bodyMedium,
            decoration: const InputDecoration(hintText: 'Type your answer...'),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final SubjectiveQuizState state;
  final VoidCallback onDone;

  const _ResultView({required this.state, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('TOTAL SCORE', style: AppTextStyles.labelSmall),
        const SizedBox(height: 6),
        Text(
          '${state.totalAwarded} / ${state.totalPossible} marks',
          style: AppTextStyles.displayLarge.copyWith(color: AppColors.indigo),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: state.totalPossible == 0
                ? 0
                : state.totalAwarded / state.totalPossible,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.indigo),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 24),
        for (var i = 0; i < state.questions.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _ResultCard(
              index: i,
              question: state.questions[i],
              answer: i < state.answers.length ? state.answers[i] : '',
              result: i < state.result.length ? state.result[i] : null,
            ),
          ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: onDone,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.indigo),
            child: Text(
              'Back to Chapters',
              style: AppTextStyles.button.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  final int index;
  final SubjectiveQuestion question;
  final String answer;
  final SubjectiveQuestionResult? result;

  const _ResultCard({
    required this.index,
    required this.question,
    required this.answer,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final awarded = result?.marksAwarded ?? 0;
    final possible = result?.marksPossible ?? question.marks;
    final color = possible == 0
        ? AppColors.textMuted
        : awarded == possible
        ? AppColors.green
        : awarded == 0
        ? AppColors.red
        : AppColors.amber;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Question ${index + 1}',
                  style: AppTextStyles.labelSmall,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withValues(alpha: 0.35)),
                ),
                child: Text(
                  '$awarded / $possible marks',
                  style: AppTextStyles.labelSmall.copyWith(color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question.questionText,
            style: AppTextStyles.bodyMedium.copyWith(
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text('Your Answer', style: AppTextStyles.labelSmall),
          const SizedBox(height: 4),
          Text(
            answer.isEmpty ? 'No answer given.' : answer,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Text('Explanation', style: AppTextStyles.labelSmall),
          const SizedBox(height: 4),
          Text(
            result?.explanation ?? 'No explanation returned.',
            style: AppTextStyles.bodySmall.copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.red, size: 48),
            const SizedBox(height: 16),
            Text(message, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.indigo),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
