import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/study_plan_model.dart';
import '../models/study_plan_stage.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/chemistry_background.dart';
import '../study_plan/study_plan_controller.dart';

class StudyPlanScreen extends ConsumerWidget {
  const StudyPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyPlanControllerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ChemistryBackground(
        child: RefreshIndicator(
          color: AppColors.cyan,
          backgroundColor: AppColors.card,
          onRefresh: () =>
              ref.read(studyPlanControllerProvider.notifier).refresh(),
          child: CustomScrollView(
          slivers: [
            // ── APP BAR ───────────────────────────────────
            SliverAppBar(
              backgroundColor: AppColors.surface,
              floating: true,
              pinned: false,
              elevation: 0,
              toolbarHeight: 64,
              automaticallyImplyLeading: false,
              leading: IconButton(
                tooltip: 'Back',
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/home');
                  }
                },
              ),
              title: Text('Study Plan', style: AppTextStyles.headingLarge),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () =>
                      ref.read(studyPlanControllerProvider.notifier).refresh(),
                ),
              ],
            ),

            // ── BODY ──────────────────────────────────────
            if (state.isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.cyan),
                ),
              )
            else if (state.error != null)
              SliverFillRemaining(
                child: _ErrorState(
                  message: state.error!,
                  onRetry: () =>
                      ref.read(studyPlanControllerProvider.notifier).refresh(),
                ),
              )
            else if (!state.hasPlan)
              SliverFillRemaining(child: _NoPlanState())
            else
              _PlanContent(plan: state.plan!),
          ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: -1),
    );
  }
}

// ── PLAN CONTENT ──────────────────────────────────────────
class _PlanContent extends StatelessWidget {
  final StudyPlanModel plan;
  const _PlanContent({required this.plan});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // ── EXAM READINESS ────────────────────────────
          _ExamReadinessCard(
            percent: plan.examReadinessPercent,
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 16),

          // ── MOTIVATIONAL MESSAGE ──────────────────────
          if (plan.motivationalMessage.isNotEmpty) ...[
            _MotivationalCard(
              message: plan.motivationalMessage,
            ).animate(delay: 80.ms).fadeIn(),
            const SizedBox(height: 16),
          ],

          // ── WEAK / STRONG CHAPTERS ────────────────────
          _ChapterTagsRow(
            weak: plan.weakChapters,
            strong: plan.strongChapters,
          ).animate(delay: 120.ms).fadeIn(),

          const SizedBox(height: 20),

          // ── CURRENT STAGE ──────────────────────────────
          if (plan.currentStage != null) ...[
            Text(
              'Current Stage',
              style: AppTextStyles.headingMedium,
            ).animate(delay: 160.ms).fadeIn(),
            const SizedBox(height: 12),
            _StageCard(
              stage: plan.currentStage!,
              isCurrent: true,
              isExpanded: true,
            ).animate(delay: 200.ms).fadeIn(),
            const SizedBox(height: 24),
          ],

          // ── WEEKLY GOALS ──────────────────────────────
          if (plan.weeklyGoals.isNotEmpty) ...[
            Text(
              'This Week',
              style: AppTextStyles.headingMedium,
            ).animate(delay: 240.ms).fadeIn(),
            const SizedBox(height: 12),
            _WeeklyGoalsCard(
              goals: plan.weeklyGoals,
            ).animate(delay: 280.ms).fadeIn(),
            const SizedBox(height: 24),
          ],

          // ── ALL STAGES ─────────────────────────────────
          Text(
            'All Stages (${plan.completedStages}/${plan.totalStages})',
            style: AppTextStyles.headingMedium,
          ).animate(delay: 320.ms).fadeIn(),
          const SizedBox(height: 12),

          ...List.generate(plan.stages.length, (i) {
            final stage = plan.stages[i];
            final isCurrent = stage == plan.currentStage;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child:
                  _StageCard(
                        stage: stage,
                        isCurrent: isCurrent,
                        isExpanded: false,
                      )
                      .animate(delay: Duration(milliseconds: 360 + i * 40))
                      .fadeIn()
                      .slideY(begin: 0.05, end: 0),
            );
          }),
        ]),
      ),
    );
  }
}

// ── EXAM READINESS CARD ───────────────────────────────────
class _ExamReadinessCard extends StatelessWidget {
  final int percent;
  const _ExamReadinessCard({required this.percent});

  Color get _color {
    if (percent >= 75) return AppColors.green;
    if (percent >= 50) return AppColors.cyan;
    if (percent >= 25) return AppColors.amber;
    return AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_color.withOpacity(0.15), _color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          // Circular progress
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: percent / 100,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(_color),
                  strokeWidth: 7,
                ),
                Text(
                  '$percent%',
                  style: AppTextStyles.headingMedium.copyWith(color: _color),
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exam Readiness',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: _color,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(_readinessLabel, style: AppTextStyles.headingSmall),
                const SizedBox(height: 4),
                Text(
                  'Based on your diagnostic test results.',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _readinessLabel {
    if (percent >= 75) return 'Well prepared!';
    if (percent >= 50) return 'On the right track';
    if (percent >= 25) return 'Needs more practice';
    return 'Just getting started';
  }
}

// ── MOTIVATIONAL CARD ─────────────────────────────────────
class _MotivationalCard extends StatelessWidget {
  final String message;
  const _MotivationalCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cyanDim,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cyan.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── CHAPTER TAGS ROW ──────────────────────────────────────
class _ChapterTagsRow extends StatelessWidget {
  final List<String> weak;
  final List<String> strong;
  const _ChapterTagsRow({required this.weak, required this.strong});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (weak.isNotEmpty) ...[
          Text(
            'Needs Focus',
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.red),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: weak
                .map((ch) => _ChapterTag(name: ch, color: AppColors.red))
                .toList(),
          ),
          const SizedBox(height: 12),
        ],
        if (strong.isNotEmpty) ...[
          Text(
            'Strong Areas',
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.green),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: strong
                .map((ch) => _ChapterTag(name: ch, color: AppColors.green))
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _ChapterTag extends StatelessWidget {
  final String name;
  final Color color;
  const _ChapterTag({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(name, style: AppTextStyles.bodySmall.copyWith(color: color)),
    );
  }
}

// ── STAGE CARD ─────────────────────────────────────────────
class _StageCard extends StatefulWidget {
  final StudyPlanStage stage;
  final bool isCurrent;
  final bool isExpanded;
  const _StageCard({
    required this.stage,
    required this.isCurrent,
    required this.isExpanded,
  });

  @override
  State<_StageCard> createState() => _StageCardState();
}

class _StageCardState extends State<_StageCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.isExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final stage = widget.stage;
    final color = AppColors.chapterColor(stage.chapterNumber);
    final border = widget.isCurrent
        ? Border.all(color: color.withOpacity(0.5), width: 1.5)
        : Border.all(color: AppColors.border);
    final tasksDone =
        (stage.lectureCompleted ? 1 : 0) + (stage.quizCompleted ? 1 : 0);

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: border,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              color: widget.isCurrent
                  ? color.withOpacity(0.08)
                  : Colors.transparent,
              child: Row(
                children: [
                  // Stage badge
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: stage.completed
                          ? AppColors.green.withOpacity(0.15)
                          : color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: stage.completed
                          ? const Icon(
                              Icons.check_rounded,
                              color: AppColors.green,
                              size: 20,
                            )
                          : Text(
                              '${stage.stage}',
                              style: AppTextStyles.headingSmall.copyWith(
                                color: color,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (widget.isCurrent) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'CURRENT',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: color,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Expanded(
                              child: Text(
                                stage.chapter,
                                style: AppTextStyles.headingSmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$tasksDone/2 tasks done',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),

            // Expandable tasks
            if (_expanded) ...[
              const Divider(height: 1, color: AppColors.border),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _TaskRow(
                      icon: Icons.menu_book_rounded,
                      label: 'Lecture',
                      actionLabel: 'Start',
                      isCompleted: stage.lectureCompleted,
                      color: color,
                      onTap: () =>
                          context.push('/lecture/${stage.chapterNumber}'),
                    ),
                    const SizedBox(height: 10),
                    _TaskRow(
                      icon: Icons.quiz_rounded,
                      label: 'Quiz',
                      actionLabel: 'Take Quiz',
                      isCompleted: stage.quizCompleted,
                      color: color,
                      onTap: () =>
                          context.push('/quiz/${stage.chapterNumber}'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── TASK ROW ────────────────────────────────────────────────
class _TaskRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String actionLabel;
  final bool isCompleted;
  final Color color;
  final VoidCallback onTap;

  const _TaskRow({
    required this.icon,
    required this.label,
    required this.actionLabel,
    required this.isCompleted,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
        if (isCompleted)
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.green,
            size: 18,
          )
        else
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: color,
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            child: Text(
              actionLabel,
              style: AppTextStyles.bodySmall.copyWith(color: color),
            ),
          ),
      ],
    );
  }
}

// ── WEEKLY GOALS CARD ─────────────────────────────────────
class _WeeklyGoalsCard extends StatelessWidget {
  final List<String> goals;
  const _WeeklyGoalsCard({required this.goals});

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
        children: goals.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.cyanDim,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '${entry.key + 1}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.cyan,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.value,
                    style: AppTextStyles.bodyMedium.copyWith(height: 1.4),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── NO PLAN STATE ─────────────────────────────────────────
class _NoPlanState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.assignment_outlined,
              color: AppColors.textMuted,
              size: 56,
            ),
            const SizedBox(height: 20),
            Text('No Study Plan Yet', style: AppTextStyles.headingLarge),
            const SizedBox(height: 12),
            Text(
              'Complete the diagnostic test to get your '
              'personalised study plan.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => context.push('/diagnostic'),
                child: const Text('Take Diagnostic Test'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── ERROR STATE ───────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: AppColors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
