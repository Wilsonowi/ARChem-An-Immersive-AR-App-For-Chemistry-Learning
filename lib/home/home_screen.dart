import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../weekly_plan/models/weekly_study_plan_model.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/chemistry_background.dart';
import 'current_study_status.dart';
import 'home_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeControllerProvider);
    final user = state.user;
    final deviceNow = ref.watch(deviceClockProvider).valueOrNull ?? DateTime.now();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ChemistryBackground(
        // Purple theme for Home only - see lib/widgets/chemistry_background.dart
        // for the (backward-compatible) override params; every other screen
        // still using ChemistryBackground keeps its default blue look.
        gradientCenter: Colors.white,
        gradientEdge: AppColors.lilacGlow,
        gridColor: AppColors.indigo,
        accentColor: AppColors.indigo,
        child: RefreshIndicator(
          color: AppColors.indigo,
          backgroundColor: AppColors.card,
          onRefresh: () => ref.read(homeControllerProvider.notifier).load(),
          child: CustomScrollView(
            slivers: [
              // ── TOP BAR ────────────────────────────────────
              SliverAppBar(
                backgroundColor: AppColors.surface,
                floating: true,
                pinned: false,
                elevation: 0,
                expandedHeight: 0,
                toolbarHeight: 70,
                title: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.indigoDim,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.indigo.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          user?.initials ?? 'A',
                          style: AppTextStyles.headingSmall.copyWith(
                            color: AppColors.indigo,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_greeting(), style: AppTextStyles.bodySmall),
                          Text(
                            user?.fullName ?? 'Student',
                            style: AppTextStyles.headingSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    _DeviceTimePill(now: deviceNow),
                    const SizedBox(width: 4),
                    // Profile icon
                    IconButton(
                      onPressed: () => context.push('/profile'),
                      icon: const Icon(
                        Icons.person_outline_rounded,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 24),

                    // ── STATS ROW ──────────────────────────────
                    _StatsRow(state: state).animate().fadeIn(duration: 400.ms),

                    const SizedBox(height: 28),

                    // ── CURRENT PLAN (hero card, moved above the AI
                    // shortcuts since it's the most actionable thing on
                    // the dashboard right now) ────────────────────
                    Row(
                      children: [
                        Text(
                          'Current Plan',
                          style: AppTextStyles.headingLarge.copyWith(
                            color: AppColors.indigoDark,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => context.go('/study-plan'),
                          // Explicit override: TextButton otherwise inherits
                          // the app-wide cyan textButtonTheme (lib/app.dart),
                          // which still needs to stay blue for every other
                          // screen until they're redesigned individually.
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.indigo,
                          ),
                          child: const Text('View Plan'),
                        ),
                      ],
                    ).animate(delay: 100.ms).fadeIn(),

                    const SizedBox(height: 12),

                    _CurrentStudyStatusCard(state: state)
                        .animate(delay: 140.ms)
                        .fadeIn()
                        .slideY(begin: 0.08, end: 0),

                    const SizedBox(height: 28),

                    // ── AI SHORTCUTS ───────────────────────────
                    _AiTutorCard()
                        .animate(delay: 180.ms)
                        .fadeIn()
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 14),

                    _MarkAnswerCard()
                        .animate(delay: 220.ms)
                        .fadeIn()
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 14),

                    _QuizCard()
                        .animate(delay: 260.ms)
                        .fadeIn()
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _DeviceTimePill extends StatelessWidget {
  final DateTime now;

  const _DeviceTimePill({required this.now});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.indigoDim,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.indigo.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.schedule_rounded,
            size: 15,
            color: AppColors.indigo,
          ),
          const SizedBox(width: 5),
          Text(
            _formatTime(now),
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.indigoDark,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime value) {
    final hour12 = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour < 12 ? 'AM' : 'PM';
    return '$hour12:$minute $period';
  }
}

// ── PLAN HERO CARD ──────────────────────────────────────────
// Shared bold gradient container for every _CurrentStudyStatusCard state -
// the dashboard's single "hero" card, styled after the reference dashboard's
// blue gradient "Today's Task" card (white text/icons on a saturated
// purple-family gradient) rather than the flat bordered-white look used
// elsewhere on this screen.
class _PlanHeroCard extends StatelessWidget {
  final Widget child;
  const _PlanHeroCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.indigo, AppColors.indigoDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.indigo.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// A translucent-white icon badge used inside [_PlanHeroCard], matching the
/// reference dashboard's white-on-gradient icon treatment.
class _HeroIconBadge extends StatelessWidget {
  final IconData icon;
  const _HeroIconBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }
}

/// A labelled progress bar used inside [_PlanHeroCard], matching the
/// reference dashboard's "Today's Focus" progress bar.
class _HeroProgressBar extends StatelessWidget {
  final String label;
  final double percent; // 0..1
  const _HeroProgressBar({required this.label, required this.percent});

  @override
  Widget build(BuildContext context) {
    final pct = percent.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            Text(
              '${(pct * 100).round()}%',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 10,
            backgroundColor: Colors.white.withValues(alpha: 0.22),
            valueColor: const AlwaysStoppedAnimation(Colors.white),
          ),
        ),
      ],
    );
  }
}

/// A translucent-white status pill (e.g. "STUDYING NOW") used inside
/// [_PlanHeroCard].
class _HeroPill extends StatelessWidget {
  final String label;
  const _HeroPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: Colors.white,
          fontSize: 9,
        ),
      ),
    );
  }
}

// ── CURRENT STUDY STATUS CARD ───────────────────────────────
// Live "studying now" / "resting now" status for today, derived read-only
// from the weekly study plan (see lib/home/current_study_status.dart) -
// this widget never writes to or regenerates that plan.
class _CurrentStudyStatusCard extends ConsumerWidget {
  final HomeState state;
  const _CurrentStudyStatusCard({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(currentStudyStatusProvider);

    switch (status.kind) {
      case CurrentStudyStatusKind.loading:
        return _PlanHeroCard(
          child: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                "Checking today's plan...",
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              ),
            ],
          ),
        );

      case CurrentStudyStatusKind.noPlan:
        return _PlanHeroCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HeroIconBadge(icon: Icons.event_note_rounded),
              const SizedBox(height: 16),
              Text(
                "This week's plan isn't ready yet",
                style: AppTextStyles.headingMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Open your Study Plan to generate this week\'s schedule.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              _HeroProgressBar(
                label: 'Overall Syllabus Progress',
                percent: state.overallPercent,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => context.go('/study-plan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.indigoDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Open Study Plan',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );

      case CurrentStudyStatusKind.studying:
        return _StudyingNowCard(
          block: status.activeBlock!,
          overallPercent: state.overallPercent,
        );

      case CurrentStudyStatusKind.resting:
        return _RestingNowCard(
          next: status.nextBlock,
          overallPercent: state.overallPercent,
        );
    }
  }
}

class _StudyingNowCard extends StatelessWidget {
  final StudyBlock block;
  final double overallPercent;
  const _StudyingNowCard({required this.block, required this.overallPercent});

  @override
  Widget build(BuildContext context) {
    return _PlanHeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _HeroIconBadge(icon: Icons.auto_stories_rounded),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _HeroPill(label: 'STUDYING NOW'),
                    const SizedBox(height: 6),
                    Text(
                      block.chapterTitle,
                      style: AppTextStyles.headingMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${block.subtopic} · ${block.timeRangeLabel}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _HeroProgressBar(
            label: 'Overall Syllabus Progress',
            percent: overallPercent,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/lecture/${block.chapterNumber}'),
              icon: const Icon(
                Icons.menu_book_rounded,
                size: 18,
                color: AppColors.indigoDark,
              ),
              label: const Text(
                'Study Now',
                style: TextStyle(
                  color: AppColors.indigoDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RestingNowCard extends StatelessWidget {
  final StudyBlock? next;
  final double overallPercent;
  const _RestingNowCard({required this.next, required this.overallPercent});

  @override
  Widget build(BuildContext context) {
    return _PlanHeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _HeroIconBadge(icon: Icons.self_improvement_rounded),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _HeroPill(label: 'RESTING'),
                    const SizedBox(height: 6),
                    Text(
                      next == null
                          ? 'No more sessions today'
                          : 'Next: ${next!.chapterTitle} at ${_formatStart(next!)}',
                      style: AppTextStyles.headingMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (next != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        next!.subtopic,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _HeroProgressBar(
            label: 'Overall Syllabus Progress',
            percent: overallPercent,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () => context.go('/study-plan'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white70),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'View Full Plan',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatStart(StudyBlock block) {
    final time = block.start;
    final hour12 = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour12:$minute $period';
  }
}

// ── STATS ROW ────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final HomeState state;
  const _StatsRow({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.green,
            value: '${state.completedChapters}/8',
            label: 'Chapters Done',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.trending_up_rounded,
            color: AppColors.indigo,
            value: '${(state.overallPercent * 100).toInt()}%',
            label: 'Overall Progress',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.science_rounded,
            color: AppColors.amber,
            value: '4/4',
            label: 'Labs Done',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  const _StatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 19),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTextStyles.headingLarge.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── AI SHORTCUT CARD ─────────────────────────────────────────
// Shared layout for the AI Tutor / Mark My Answer cards below: a solid
// (not tinted) colour icon square and a rounded pill call-to-action label,
// styled after the reference dashboard's "Daily Reading" card so these
// read as bold, tappable shortcuts rather than flat bordered rows.
class _AiShortcutCard extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final String ctaLabel;

  const _AiShortcutCard({
    required this.onTap,
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.16),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.headingSmall.copyWith(
                      color: AppColors.indigoDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                ctaLabel,
                style: AppTextStyles.labelSmall.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiTutorCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _AiShortcutCard(
      onTap: () => context.push('/chat'),
      icon: Icons.auto_awesome_rounded,
      accent: AppColors.indigo,
      title: 'Ask ARChem Tutor',
      subtitle: 'Get quick help for SPM Chemistry concepts and calculations',
      ctaLabel: 'ASK',
    );
  }
}

class _MarkAnswerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _AiShortcutCard(
      onTap: () => context.push('/chat?attach=marking'),
      icon: Icons.camera_alt_rounded,
      accent: AppColors.amber,
      title: 'Mark My Answer',
      subtitle: 'Photograph a handwritten answer for instant AI feedback',
      ctaLabel: 'MARK',
    );
  }
}

class _QuizCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _AiShortcutCard(
      onTap: () => context.push('/quiz-type'),
      icon: Icons.quiz_rounded,
      accent: AppColors.green,
      title: 'Take a Quiz',
      subtitle: 'Practice with MCQ or subjective SPM-style questions',
      ctaLabel: 'QUIZ',
    );
  }
}
