import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../chapters/chapters_data.dart';
import '../diagnostic/diagnostic_controller.dart';
import '../models/question_model.dart';
import '../quiz/question_card.dart';
import '../generating_plan_screen.dart';
import '../home/home_controller.dart';
import '../home/current_study_status.dart';
import '../weekly_plan/weekly_plan_controller.dart';
import '../widgets/chemistry_background.dart';

class DiagnosticScreen extends ConsumerStatefulWidget {
  const DiagnosticScreen({super.key});

  @override
  ConsumerState<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends ConsumerState<DiagnosticScreen> {
  int? _selectedIndex;
  bool _answered = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(diagnosticControllerProvider);

    ref.listen(diagnosticControllerProvider, (prev, next) async {
      final justCompleted =
          prev?.phase != DiagnosticPhase.completed &&
          next.phase == DiagnosticPhase.completed;
      if (justCompleted && mounted) {
        ref.invalidate(homeWeeklyPlanProvider);
        await Future.wait([
          ref.read(homeControllerProvider.notifier).load(),
          ref.read(weeklyPlanControllerProvider.notifier).refresh(),
        ]);
      }
    });

    if (state.phase == DiagnosticPhase.idle) {
      return _DiagnosticIntroScreen(
        onBack: () => _goBack(context),
        onStart: () {
          setState(() {
            _selectedIndex = null;
            _answered = false;
          });
          ref.read(diagnosticControllerProvider.notifier).startTest();
        },
      );
    }

    // Show generating plan screen
    if (state.phase == DiagnosticPhase.generatingPlan) {
      return GeneratingPlanScreen(statusMessage: state.statusMessage);
    }

    if (state.phase == DiagnosticPhase.completed) {
      return _DiagnosticSummaryScreen(
        results: state.results,
        onBack: () => _goBack(context),
        onViewPlan: () => context.go('/study-plan'),
      );
    }

    // Show error screen
    if (state.phase == DiagnosticPhase.error) {
      return _ErrorScreen(
        message: state.errorMessage ?? 'Something went wrong.',
        onRetry: () {
          setState(() {
            _selectedIndex = null;
            _answered = false;
          });
          ref.read(diagnosticControllerProvider.notifier).retry();
        },
      );
    }

    // Show loading screen
    if (state.phase == DiagnosticPhase.loading || state.questions.isEmpty) {
      return _LoadingScreen();
    }

    final question = state.currentQuestion;
    if (question == null) return _LoadingScreen();

    final chapterColor = AppColors.chapterColor(question.chapterNumber);
    final chapter = kChapters.firstWhere(
      (c) => c.number == question.chapterNumber,
      orElse: () => kChapters.first,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ChemistryBackground(
        // Purple theme, matching the rest of the app (background only -
        // this screen's own accent is already chapterColor-driven via
        // QuestionCard, matching the same per-chapter color-coding used
        // elsewhere, so it's untouched).
        gradientCenter: Colors.white,
        gradientEdge: AppColors.lilacGlow,
        gridColor: AppColors.indigo,
        accentColor: AppColors.indigo,
        child: SafeArea(
          child: Column(
            children: [
            // ── TOP BAR ───────────────────────────────────
            _TopBar(
              current: state.currentIndex + 1,
              total: state.totalQuestions,
              progress: state.progress,
              chapterColor: chapterColor,
              chapterName: chapter.shortTitle,
              onQuit: () => _confirmQuit(context),
            ),

            // ── QUESTION AREA ─────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chapter + subtopic label
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: chapterColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: chapterColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            'Ch ${question.chapterNumber} — ${chapter.shortTitle}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: chapterColor,
                            ),
                          ),
                        ),
                        if (question.subtopic != null) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              question.subtopic!,
                              style: AppTextStyles.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ).animate().fadeIn(duration: 300.ms),

                    const SizedBox(height: 16),

                    // Question card
                    QuestionCard(
                      key: ValueKey(state.currentIndex),
                      question: question,
                      selectedIndex: _selectedIndex,
                      answered: _answered,
                      accentColor: chapterColor,
                      onOptionSelected: _onOptionSelected,
                    ),

                    // Feedback card
                    if (_answered) ...[
                      const SizedBox(height: 16),
                      _FeedbackCard(
                        isCorrect: _selectedIndex == question.correctIndex,
                        message: _selectedIndex == question.correctIndex
                            ? question.feedbackCorrect
                            : question.feedbackWrong,
                      ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                    ],

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // ── BOTTOM BUTTON ─────────────────────────────
            _BottomBar(
              answered: _answered,
              isLast: state.isLastQuestion,
              isSubmitting: state.phase == DiagnosticPhase.submitting,
              chapterColor: chapterColor,
              onNext: _answered ? _onNext : null,
            ),
            ],
          ),
        ),
      ),
    );
  }

  void _onOptionSelected(int index) {
    if (_answered) return;
    setState(() {
      _selectedIndex = index;
      _answered = true;
    });
    ref.read(diagnosticControllerProvider.notifier).onAnswerSelected(index);
  }

  Future<void> _onNext() async {
    await ref.read(diagnosticControllerProvider.notifier).onNext();
    setState(() {
      _selectedIndex = null;
      _answered = false;
    });
  }

  Future<void> _confirmQuit(BuildContext context) async {
    final shouldQuit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Quit diagnostic test?'),
        content: const Text(
          'Your current answers will not be saved. You can start again later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Continue Test'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Quit Test'),
          ),
        ],
      ),
    );

    if (shouldQuit == true && mounted) {
      ref.invalidate(diagnosticControllerProvider);
      _goBack(context);
    }
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/study-plan');
    }
  }
}

// ── TOP BAR ───────────────────────────────────────────────
class _DiagnosticSummaryScreen extends StatelessWidget {
  final List<QuestionResult> results;
  final VoidCallback onBack;
  final VoidCallback onViewPlan;

  const _DiagnosticSummaryScreen({
    required this.results,
    required this.onBack,
    required this.onViewPlan,
  });

  @override
  Widget build(BuildContext context) {
    final total = results.length;
    final score = results.where((result) => result.isCorrect).length;
    final percent = total == 0 ? 0.0 : score / total;
    final chapterScores = _buildChapterScores(results);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ChemistryBackground(
        gradientCenter: Colors.white,
        gradientEdge: AppColors.lilacGlow,
        gridColor: AppColors.indigo,
        accentColor: AppColors.indigo,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Back',
                      onPressed: onBack,
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Diagnostic Summary',
                        style: AppTextStyles.headingLarge,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.indigo,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.indigo.withValues(alpha: 0.18),
                              blurRadius: 30,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'TEST COMPLETE',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              '$score / $total',
                              style: AppTextStyles.displayMedium.copyWith(
                                color: Colors.white,
                                fontSize: 42,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(percent * 100).round()}% overall score',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                            const SizedBox(height: 18),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: LinearProgressIndicator(
                                value: percent.clamp(0.0, 1.0).toDouble(),
                                minHeight: 10,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.2),
                                valueColor:
                                    const AlwaysStoppedAnimation(Colors.white),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Your personalised weekly study plan has been generated from this result.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.88),
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 300.ms).slideY(
                            begin: 0.06,
                            end: 0,
                          ),
                      const SizedBox(height: 24),
                      Text(
                        'Chapter Breakdown',
                        style: AppTextStyles.headingMedium,
                      ),
                      const SizedBox(height: 12),
                      ...chapterScores.map(
                        (chapterScore) =>
                            _ChapterSummaryRow(score: chapterScore)
                                .animate()
                                .fadeIn(duration: 250.ms)
                                .slideX(begin: 0.04, end: 0),
                      ),
                      const SizedBox(height: 90),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: onViewPlan,
                    icon: const Icon(Icons.event_note_rounded),
                    label: const Text('View Study Plan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChapterSummaryRow extends StatelessWidget {
  final ChapterDiagnosticScore score;

  const _ChapterSummaryRow({required this.score});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.chapterColor(score.chapterNumber);
    final percent = score.percentage;
    final status = percent >= 0.8
        ? 'Strong'
        : percent >= 0.6
            ? 'Good'
            : 'Needs Review';
    final statusColor = percent >= 0.8
        ? AppColors.green
        : percent >= 0.6
            ? AppColors.amber
            : AppColors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'Ch\n${score.chapterNumber}',
              textAlign: TextAlign.center,
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
                height: 1.05,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(score.chapter, style: AppTextStyles.headingSmall),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: percent.clamp(0.0, 1.0).toDouble(),
                    minHeight: 6,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${score.score}/${score.maxScore}',
                style: AppTextStyles.monoBold.copyWith(color: color),
              ),
              const SizedBox(height: 4),
              Text(
                status,
                style: AppTextStyles.labelSmall.copyWith(color: statusColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

List<ChapterDiagnosticScore> _buildChapterScores(List<QuestionResult> results) {
  final grouped = <int, List<QuestionResult>>{};
  for (final result in results) {
    grouped.putIfAbsent(result.question.chapterNumber, () => []).add(result);
  }

  final scores = grouped.entries.map((entry) {
    final chapterResults = entry.value;
    return ChapterDiagnosticScore(
      chapter: chapterResults.first.question.chapter,
      chapterNumber: entry.key,
      score: chapterResults.where((result) => result.isCorrect).length,
      maxScore: chapterResults.length,
    );
  }).toList()
    ..sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));

  return scores;
}

class _DiagnosticIntroScreen extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onStart;

  const _DiagnosticIntroScreen({required this.onBack, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ChemistryBackground(
        gradientCenter: Colors.white,
        gradientEdge: AppColors.lilacGlow,
        gridColor: AppColors.indigo,
        accentColor: AppColors.indigo,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  tooltip: 'Back',
                  onPressed: onBack,
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.textPrimary,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.indigo.withValues(alpha: 0.12),
                            blurRadius: 28,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 86,
                            height: 86,
                            decoration: BoxDecoration(
                              color: AppColors.indigo.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(
                                color: AppColors.indigo.withValues(alpha: 0.24),
                              ),
                            ),
                            child: const Icon(
                              Icons.fact_check_rounded,
                              color: AppColors.indigo,
                              size: 42,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            'Diagnostic Test',
                            style: AppTextStyles.displayMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Answer 37 SPM Form 4 Chemistry questions so ARChem can understand your strengths and build a personalised weekly study plan.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _IntroStat(
                                  icon: Icons.quiz_rounded,
                                  label: 'Questions',
                                  value: '37',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _IntroStat(
                                  icon: Icons.auto_awesome_rounded,
                                  label: 'Output',
                                  value: 'Plan',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: onStart,
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: const Text('Start Questions'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.indigo,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms).slideY(
                          begin: 0.06,
                          end: 0,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IntroStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _IntroStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.indigo, size: 22),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.headingSmall),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final int current;
  final int total;
  final double progress;
  final Color chapterColor;
  final String chapterName;
  final VoidCallback onQuit;

  const _TopBar({
    required this.current,
    required this.total,
    required this.progress,
    required this.chapterColor,
    required this.chapterName,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DIAGNOSTIC TEST', style: AppTextStyles.labelSmall),
                  const SizedBox(height: 2),
                  Text(
                    'Question $current of $total',
                    style: AppTextStyles.headingSmall,
                  ),
                ],
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onQuit,
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Quit Test'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: chapterColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: chapterColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: AppTextStyles.monoBold.copyWith(
                    color: chapterColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(chapterColor),
              minHeight: 6,
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── FEEDBACK CARD ─────────────────────────────────────────
class _FeedbackCard extends StatelessWidget {
  final bool isCorrect;
  final String message;
  const _FeedbackCard({required this.isCorrect, required this.message});

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCorrect ? Icons.check_circle_rounded : Icons.info_outline_rounded,
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
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── BOTTOM BAR ────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final bool answered;
  final bool isLast;
  final bool isSubmitting;
  final Color chapterColor;
  final VoidCallback? onNext;

  const _BottomBar({
    required this.answered,
    required this.isLast,
    required this.isSubmitting,
    required this.chapterColor,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: answered ? 1.0 : 0.0,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: answered ? onNext : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: chapterColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    isLast ? 'Submit & Generate Plan' : 'Next Question',
                    style: AppTextStyles.button.copyWith(color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }
}

// ── LOADING SCREEN ────────────────────────────────────────
class _LoadingScreen extends StatelessWidget {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                color: AppColors.indigo,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Loading your diagnostic test...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text('Preparing 37 questions', style: AppTextStyles.bodySmall),
          ],
        ),
        ),
      ),
    );
  }
}

// ── ERROR SCREEN ──────────────────────────────────────────
class _ErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorScreen({required this.message, required this.onRetry});

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
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                color: AppColors.red,
                size: 56,
              ),
              const SizedBox(height: 20),
              Text('Connection Error', style: AppTextStyles.headingLarge),
              const SizedBox(height: 12),
              Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
