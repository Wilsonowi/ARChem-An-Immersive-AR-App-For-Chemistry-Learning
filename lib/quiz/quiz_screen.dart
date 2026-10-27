import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../chapters/chapters_data.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../home/home_controller.dart';
import '../models/question_model.dart';
import '../widgets/chemistry_background.dart';
import 'question_card.dart';
import 'quiz_controller.dart';

class QuizScreen extends ConsumerWidget {
  final int chapterNumber;

  const QuizScreen({super.key, required this.chapterNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quizControllerProvider(chapterNumber));
    final controller = ref.read(quizControllerProvider(chapterNumber).notifier);
    final chapter = kChapters.firstWhere(
      (chapter) => chapter.number == chapterNumber,
      orElse: () => kChapters.first,
    );
    final chapterColor = AppColors.chapterColor(chapterNumber);

    if (state.phase == QuizPhase.loading || state.questions.isEmpty) {
      return _LoadingScreen(chapterColor: chapterColor);
    }

    if (state.phase == QuizPhase.completed) {
      return _ResultsView(
        state: state,
        chapterColor: chapterColor,
        onRetry: controller.retry,
      );
    }

    if (state.phase == QuizPhase.error) {
      return _ErrorView(
        message: state.errorMessage ?? 'Something went wrong.',
        chapterColor: chapterColor,
        onRetry: controller.retrySave,
      );
    }

    final question = state.currentQuestion;
    if (question == null) return _LoadingScreen(chapterColor: chapterColor);
    final selected = state.selectedIndex;
    final isCorrect = selected == question.correctIndex;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ChemistryBackground(
        // Purple theme for the quiz module (background only - the
        // chapterColor-driven accents throughout this screen intentionally
        // stay as-is, matching the same per-chapter color-coding used on
        // Study Plan and the Chapters list).
        gradientCenter: Colors.white,
        gradientEdge: AppColors.lilacGlow,
        gridColor: AppColors.indigo,
        accentColor: AppColors.indigo,
        child: SafeArea(
          child: Column(
          children: [
            _TopBar(
              chapterName: chapter.shortTitle,
              current: state.currentIndex + 1,
              total: state.totalQuestions,
              progress: state.progress,
              score: state.score,
              chapterColor: chapterColor,
              onClose: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
              onHome: () {
                ref.read(homeControllerProvider.notifier).load();
                context.go('/home');
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ChapterLabel(
                      chapterNumber: chapterNumber,
                      title: chapter.shortTitle,
                      subtopic: question.subtopic,
                      color: chapterColor,
                    ),
                    const SizedBox(height: 16),
                    QuestionCard(
                      key: ValueKey(state.currentIndex),
                      question: question,
                      selectedIndex: selected,
                      answered: state.answered,
                      accentColor: chapterColor,
                      onOptionSelected: controller.selectAnswer,
                    ),
                    if (state.answered) ...[
                      const SizedBox(height: 16),
                      _FeedbackCard(
                        isCorrect: isCorrect,
                        message: isCorrect
                            ? question.feedbackCorrect
                            : question.feedbackWrong,
                        hint: state.aiHint,
                        hintLoading: state.hintLoading,
                        onHint: isCorrect ? null : controller.loadHint,
                      ).animate().fadeIn().slideY(begin: 0.08, end: 0),
                    ],
                    const SizedBox(height: 96),
                  ],
                ),
              ),
            ),
            _BottomBar(
              answered: state.answered,
              isLast: state.isLastQuestion,
              saving: state.phase == QuizPhase.saving,
              chapterColor: chapterColor,
              onNext: controller.next,
            ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String chapterName;
  final int current;
  final int total;
  final double progress;
  final int score;
  final Color chapterColor;
  final VoidCallback onClose;
  final VoidCallback onHome;

  const _TopBar({
    required this.chapterName,
    required this.current,
    required this.total,
    required this.progress,
    required this.score,
    required this.chapterColor,
    required this.onClose,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onClose,
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CHAPTER QUIZ', style: AppTextStyles.labelSmall),
                    Text(
                      chapterName,
                      style: AppTextStyles.headingSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                '$score/$total',
                style: AppTextStyles.monoBold.copyWith(color: chapterColor),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Home',
                onPressed: onHome,
                icon: const Icon(
                  Icons.home_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Question $current of $total',
                style: AppTextStyles.labelMedium.copyWith(color: chapterColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Single pill-shaped progress bar (this used to be duplicated with
          // a row of step segments below it, showing the same information
          // twice) - solid white track, solid coloured fill.
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(chapterColor),
              minHeight: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChapterLabel extends StatelessWidget {
  final int chapterNumber;
  final String title;
  final String? subtopic;
  final Color color;

  const _ChapterLabel({
    required this.chapterNumber,
    required this.title,
    required this.subtopic,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            'Ch $chapterNumber - $title',
            style: AppTextStyles.labelSmall.copyWith(color: color),
          ),
        ),
        if (subtopic != null) ...[
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              subtopic!,
              style: AppTextStyles.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _FeedbackCard extends StatelessWidget {
  final bool isCorrect;
  final String message;
  final String? hint;
  final bool hintLoading;
  final VoidCallback? onHint;

  const _FeedbackCard({
    required this.isCorrect,
    required this.message,
    required this.hint,
    required this.hintLoading,
    this.onHint,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? AppColors.green : AppColors.red;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isCorrect
                    ? Icons.check_circle_rounded
                    : Icons.info_outline_rounded,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCorrect ? 'Correct!' : 'Incorrect',
                      style: AppTextStyles.headingSmall.copyWith(color: color),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: AppTextStyles.bodySmall.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (onHint != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: OutlinedButton.icon(
                onPressed: hintLoading ? null : onHint,
                // Explicit override: OutlinedButton otherwise inherits the
                // app-wide cyan colorScheme.primary (lib/app.dart), which
                // still needs to stay blue for every other screen until
                // they're redesigned individually.
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.indigo,
                  side: const BorderSide(color: AppColors.indigo),
                ),
                icon: hintLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome_rounded, size: 18),
                label: Text(hint == null ? 'AI Hint' : 'Refresh Hint'),
              ),
            ),
          ],
          if (hint != null) ...[
            const SizedBox(height: 12),
            Text(
              hint!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final bool answered;
  final bool isLast;
  final bool saving;
  final Color chapterColor;
  final VoidCallback onNext;

  const _BottomBar({
    required this.answered,
    required this.isLast,
    required this.saving,
    required this.chapterColor,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: answered && !saving ? onNext : null,
          style: ElevatedButton.styleFrom(backgroundColor: chapterColor),
          child: saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  isLast ? 'Finish Quiz' : 'Next Question',
                  style: AppTextStyles.button.copyWith(color: Colors.white),
                ),
        ),
      ),
    );
  }
}

class _ResultsView extends StatelessWidget {
  final QuizState state;
  final Color chapterColor;
  final Future<void> Function() onRetry;

  const _ResultsView({
    required this.state,
    required this.chapterColor,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final percent = state.totalQuestions == 0
        ? 0
        : state.score / state.totalQuestions;
    final stars = percent >= 0.8
        ? 3
        : percent >= 0.6
        ? 2
        : 1;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ChemistryBackground(
        gradientCenter: Colors.white,
        gradientEdge: AppColors.lilacGlow,
        gridColor: AppColors.indigo,
        accentColor: AppColors.indigo,
        child: SafeArea(
          child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── SCORE HEADER (centred) ──────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'QUIZ COMPLETE',
                  style: AppTextStyles.labelSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  '${state.score}/${state.totalQuestions}',
                  style: AppTextStyles.displayLarge.copyWith(
                    color: chapterColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => Icon(
                      index < stars
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: AppColors.amber,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  percent >= 0.8
                      ? 'Excellent work. You are strong in this chapter.'
                      : percent >= 0.6
                      ? 'Good progress. Review the questions you missed.'
                      : 'Keep going. A focused revision round will help a lot.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 28),
            ...state.results.map(
              (result) =>
                  _ReviewTile(result: result, chapterColor: chapterColor),
            ),
            const SizedBox(height: 24),
            // ── ACTIONS (compact pills, not full-width) ──────
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: const StadiumBorder(),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.go('/chapters'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.chapter2,
                    side: const BorderSide(color: AppColors.chapter2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: const StadiumBorder(),
                  ),
                  icon: const Icon(Icons.menu_book_rounded, size: 18),
                  label: const Text('Chapters'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.go('/home'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.cyan,
                    side: const BorderSide(color: AppColors.cyan),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: const StadiumBorder(),
                  ),
                  icon: const Icon(Icons.home_rounded, size: 18),
                  label: const Text('Home'),
                ),
              ],
            ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final QuestionResult result;
  final Color chapterColor;

  const _ReviewTile({required this.result, required this.chapterColor});

  @override
  Widget build(BuildContext context) {
    final color = result.isCorrect ? AppColors.green : AppColors.red;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            result.isCorrect
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.question.shortLabel,
                  style: AppTextStyles.labelSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  result.question.question,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                if (!result.isCorrect) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Answer: ${result.correctAnswer}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: chapterColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  final Color chapterColor;

  const _LoadingScreen({required this.chapterColor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ChemistryBackground(
        gradientCenter: Colors.white,
        gradientEdge: AppColors.lilacGlow,
        gridColor: AppColors.indigo,
        accentColor: AppColors.indigo,
        child: Center(child: CircularProgressIndicator(color: chapterColor)),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final Color chapterColor;
  final Future<void> Function() onRetry;

  const _ErrorView({
    required this.message,
    required this.chapterColor,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ChemistryBackground(
        gradientCenter: Colors.white,
        gradientEdge: AppColors.lilacGlow,
        gridColor: AppColors.indigo,
        accentColor: AppColors.indigo,
        child: Center(
          child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(backgroundColor: chapterColor),
                child: const Text('Try Again'),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
