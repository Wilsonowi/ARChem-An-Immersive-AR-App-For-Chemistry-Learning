import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../home/current_study_status.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/chemistry_background.dart';
import 'models/weekly_study_plan_model.dart';
import 'weekly_plan_controller.dart';

const _monthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];
const _weekdayShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

class WeeklyPlanScreen extends ConsumerWidget {
  const WeeklyPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(weeklyPlanControllerProvider);
    final controller = ref.read(weeklyPlanControllerProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ChemistryBackground(
        // Purple theme, matching the rest of the app - see
        // lib/widgets/chemistry_background.dart for the (backward-compatible)
        // override params.
        gradientCenter: Colors.white,
        gradientEdge: AppColors.lilacGlow,
        gridColor: AppColors.indigo,
        accentColor: AppColors.indigo,
        child: RefreshIndicator(
          color: AppColors.indigo,
          backgroundColor: AppColors.card,
          onRefresh: controller.refresh,
          child: CustomScrollView(
            slivers: [
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
                    tooltip: 'Retake Diagnostic Test',
                    icon: const Icon(
                      Icons.quiz_rounded,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => _retakeDiagnostic(context, controller, ref),
                  ),
                  IconButton(
                    tooltip: 'Refresh',
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: controller.refresh,
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: _WeekNavigator(
                  weekStart: state.viewedWeekStart,
                  isCurrentWeek: state.isCurrentWeek,
                  onPrev: () => controller.changeWeek(-1),
                  onNext: () => controller.changeWeek(1),
                ),
              ),

              SliverToBoxAdapter(
                child: _DayStrip(
                  weekStart: state.viewedWeekStart,
                  today: state.currentWeekStart,
                  isCurrentWeek: state.isCurrentWeek,
                  selectedDayKey: state.selectedDayKey,
                  onSelect: controller.selectDay,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              ..._buildBody(context, state, controller),
            ],
          ),
        ),
      ),
      floatingActionButton: state.canAdjust
          ? _AdjustFab(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const _AdjustPlanDialog(),
              ),
            )
          : null,
      bottomNavigationBar: const AppBottomNavBar(currentIndex: -1),
    );
  }

  /// Pushes the diagnostic test and, once the student pops back, re-checks
  /// or force-rebuilds the plan depending on whether one already existed -
  /// this is the "take/redo the plan" entry point from the Weekly Plan
  /// screen itself, not just from Home.
  Future<void> _retakeDiagnostic(
    BuildContext context,
    WeeklyPlanController controller,
    WidgetRef ref,
  ) async {
    await context.push('/diagnostic');
    if (!context.mounted) return;
    await controller.refresh();
    ref.invalidate(homeWeeklyPlanProvider);
  }

  List<Widget> _buildBody(
    BuildContext context,
    WeeklyPlanState state,
    WeeklyPlanController controller,
  ) {
    switch (state.phase) {
      case WeeklyPlanPhase.loading:
        return [
          const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: AppColors.indigo),
            ),
          ),
        ];
      case WeeklyPlanPhase.generating:
        return [
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.indigo),
                  const SizedBox(height: 18),
                  Text(
                    'Building your personalised week...',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ];
      case WeeklyPlanPhase.error:
        return [
          SliverFillRemaining(
            child: _ErrorState(
              message: state.errorMessage ?? 'Something went wrong.',
              onRetry: controller.load,
            ),
          ),
        ];
      case WeeklyPlanPhase.ready:
        if (state.needsDiagnostic) {
          return [
            SliverFillRemaining(
              child: _DiagnosticRequiredState(
                onTakeDiagnostic: () async {
                  await context.push('/diagnostic');
                  if (!context.mounted) return;
                  await controller.load();
                },
              ),
            ),
          ];
        }
        if (state.plan == null && state.isFutureWeek) {
          return [
            const SliverFillRemaining(
              child: _EmptyState(
                icon: Icons.hourglass_empty_rounded,
                title: "This week hasn't started yet",
                message:
                    'Your plan will be generated from your progress once '
                    'the week begins.',
              ),
            ),
          ];
        }
        if (state.plan == null && state.isPastWeek) {
          return [
            const SliverFillRemaining(
              child: _EmptyState(
                icon: Icons.history_rounded,
                title: 'No plan was saved for this week',
                message: "This week doesn't have a recorded study plan.",
              ),
            ),
          ];
        }
        return [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text('Ongoing', style: AppTextStyles.headingMedium),
                const SizedBox(height: 12),
                _DayTimeline(blocks: state.selectedDayBlocks),
              ]),
            ),
          ),
        ];
    }
  }
}

// ── WEEK NAVIGATOR ─────────────────────────────────────────
class _WeekNavigator extends StatelessWidget {
  final DateTime weekStart;
  final bool isCurrentWeek;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _WeekNavigator({
    required this.weekStart,
    required this.isCurrentWeek,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    final label = weekStart.month == weekEnd.month
        ? '${_monthNames[weekStart.month - 1]} ${weekStart.day} - ${weekEnd.day}'
        : '${_monthNames[weekStart.month - 1]} ${weekStart.day} - '
              '${_monthNames[weekEnd.month - 1]} ${weekEnd.day}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrev,
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(label, style: AppTextStyles.headingSmall),
                if (isCurrentWeek) ...[
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.indigoDim,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'THIS WEEK',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.indigo,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── DAY STRIP ───────────────────────────────────────────────
class _DayStrip extends StatelessWidget {
  final DateTime weekStart;
  final DateTime today;
  final bool isCurrentWeek;
  final String selectedDayKey;
  final ValueChanged<String> onSelect;

  const _DayStrip({
    required this.weekStart,
    required this.today,
    required this.isCurrentWeek,
    required this.selectedDayKey,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: WeeklyStudyPlan.weekdayKeys.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final key = WeeklyStudyPlan.weekdayKeys[index];
          final date = weekStart.add(Duration(days: index));
          final isSelected = key == selectedDayKey;
          final isToday = isCurrentWeek &&
              date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;

          return _DayCard(
            weekdayLabel: _weekdayShort[index],
            dayNumber: date.day,
            isSelected: isSelected,
            isToday: isToday,
            onTap: () => onSelect(key),
          );
        },
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final String weekdayLabel;
  final int dayNumber;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  const _DayCard({
    required this.weekdayLabel,
    required this.dayNumber,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 56,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.indigoDim : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.indigo : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              weekdayLabel,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? AppColors.indigo : AppColors.textMuted,
                fontSize: 9,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$dayNumber',
              style: AppTextStyles.headingSmall.copyWith(
                color: isSelected ? AppColors.indigo : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 4,
              height: 4,
              child: isToday
                  ? const DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.indigo,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ── DAY TIMELINE ────────────────────────────────────────────
class _DayTimeline extends StatelessWidget {
  final List<StudyBlock> blocks;
  const _DayTimeline({required this.blocks});

  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.self_improvement_rounded,
              color: AppColors.textMuted,
              size: 32,
            ),
            const SizedBox(height: 10),
            Text(
              'No study blocks today',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: blocks
          .map(
            (block) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TimelineBlockRow(block: block),
            ),
          )
          .toList(),
    );
  }
}

class _TimelineBlockRow extends StatelessWidget {
  final StudyBlock block;
  const _TimelineBlockRow({required this.block});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.chapterColor(block.chapterNumber);

    return IntrinsicHeight(
      child: Row(
        // stretch (not start): the accent bar below has no intrinsic
        // height of its own, so it needs to be stretched to match the
        // block card's height rather than collapsing to zero.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 56,
            child: Text(
              _startLabel(block),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(width: 3, decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          )),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Ch${block.chapterNumber}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: color,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(block.chapterTitle, style: AppTextStyles.headingSmall),
                  const SizedBox(height: 2),
                  Text(block.subtopic, style: AppTextStyles.bodySmall),
                  const SizedBox(height: 6),
                  Text(
                    block.timeRangeLabel,
                    style: AppTextStyles.bodySmall.copyWith(color: color),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _startLabel(StudyBlock block) {
    final hour12 = block.start.hourOfPeriod == 0 ? 12 : block.start.hourOfPeriod;
    final period = block.start.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour12$period';
  }
}

// ── ADJUST FAB ──────────────────────────────────────────────
// Dedicated to this screen only - the app has no reusable
// FloatingActionButton elsewhere; this is visually styled to match the
// bottom nav's indigo circular center-button convention
// (lib/widgets/bottom_nav.dart's _CenterButton) without touching that
// shared widget.
class _AdjustFab extends StatelessWidget {
  final VoidCallback onPressed;
  const _AdjustFab({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppColors.indigo,
      shape: const CircleBorder(),
      tooltip: 'Adjust plan',
      child: const Icon(Icons.edit_calendar_rounded, color: Colors.white),
    );
  }
}

// ── ADJUST PLAN DIALOG ──────────────────────────────────────
enum _DialogPhase { input, loading, error }

class _AdjustPlanDialog extends ConsumerStatefulWidget {
  const _AdjustPlanDialog();

  @override
  ConsumerState<_AdjustPlanDialog> createState() => _AdjustPlanDialogState();
}

class _AdjustPlanDialogState extends ConsumerState<_AdjustPlanDialog> {
  final _controller = TextEditingController();
  _DialogPhase _phase = _DialogPhase.input;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _phase = _DialogPhase.loading;
      _errorText = null;
    });

    try {
      final message = await ref
          .read(weeklyPlanControllerProvider.notifier)
          .submitAdjustment(text);
      ref.invalidate(homeWeeklyPlanProvider);

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message.isEmpty ? 'Plan updated.' : message),
          backgroundColor: AppColors.card,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _DialogPhase.error;
        _errorText = _friendlyAdjustmentError(e);
      });
    }
  }

  String _friendlyAdjustmentError(Object error) {
    final text = error.toString().replaceFirst('FormatException: ', '').trim();
    if (text.isEmpty) {
      return "Couldn't update your plan. Please try a clearer request.";
    }
    if (text.contains('SocketException') || text.contains('TimeoutException')) {
      return "Couldn't reach Gemini. Check your connection and try again.";
    }
    if (text.contains('Gemini error')) {
      return "Gemini couldn't update the plan right now. $text";
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final selectedDayKey = ref.watch(
      weeklyPlanControllerProvider.select((s) => s.selectedDayKey),
    );
    final dayLabel = selectedDayKey.isEmpty
        ? ''
        : '${selectedDayKey[0].toUpperCase()}${selectedDayKey.substring(1)}';
    final isBusy = _phase == _DialogPhase.loading;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Adjust $dayLabel\'s Plan', style: AppTextStyles.headingMedium),
            const SizedBox(height: 6),
            Text(
              'Tell the AI what to change - only this day will be affected.',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 4,
              enabled: !isBusy,
              style: AppTextStyles.bodyMedium,
              // Explicit focusedBorder override: TextField otherwise
              // inherits the app-wide cyan inputDecorationTheme
              // (lib/app.dart), which still needs to stay blue for every
              // other screen until they're redesigned individually.
              decoration: InputDecoration(
                hintText:
                    "e.g. I'm busy with exams today so no time for study",
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.indigo,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            if (_phase == _DialogPhase.error) ...[
              const SizedBox(height: 10),
              Text(
                _errorText ?? 'Something went wrong.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.red),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: isBusy ? null : () => Navigator.of(context).pop(),
                    // Explicit override: TextButton otherwise inherits the
                    // app-wide cyan textButtonTheme (lib/app.dart), which
                    // still needs to stay blue for every other screen until
                    // they're redesigned individually.
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.indigo,
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isBusy ? null : _submit,
                      // Explicit override: ElevatedButton otherwise
                      // inherits the app-wide cyan elevatedButtonTheme
                      // (lib/app.dart), which still needs to stay blue for
                      // every other screen until they're redesigned
                      // individually.
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.indigoDark,
                      ),
                      child: isBusy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              _phase == _DialogPhase.error
                                  ? 'Retry'
                                  : 'Update Plan',
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── DIAGNOSTIC REQUIRED STATE ─────────────────────────────────
// Shown for the current week when no plan has been saved yet AND the
// student hasn't taken the diagnostic test - there's no real progress
// signal to build a plan from, so this replaces what used to be a silent
// auto-generated all-zero-score plan.
class _DiagnosticRequiredState extends StatelessWidget {
  final VoidCallback onTakeDiagnostic;
  const _DiagnosticRequiredState({required this.onTakeDiagnostic});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.quiz_rounded,
              color: AppColors.textMuted,
              size: 56,
            ),
            const SizedBox(height: 20),
            Text(
              'Take the diagnostic test first',
              style: AppTextStyles.headingLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Your weekly study plan is built from your diagnostic test "
              "results. Complete it to generate this week's plan.",
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: onTakeDiagnostic,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.indigoDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                label: const Text('Take Diagnostic Test'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── EMPTY STATE ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.textMuted, size: 56),
            const SizedBox(height: 20),
            Text(title, style: AppTextStyles.headingLarge, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── ERROR STATE ─────────────────────────────────────────────
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
              // Explicit override: TextButton otherwise inherits the
              // app-wide cyan textButtonTheme (lib/app.dart), which still
              // needs to stay blue for every other screen until they're
              // redesigned individually.
              style: TextButton.styleFrom(foregroundColor: AppColors.indigo),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
