import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/chemistry_background.dart';

class ExperimentMenuScreen extends StatelessWidget {
  const ExperimentMenuScreen({super.key});

  static const _experiments = [
    _ExperimentItem(
      title: 'CuCO3 Heating',
      subtitle: 'Observe copper(II) carbonate decomposition in Unity.',
      chapter: 'Chapter 6',
      icon: Icons.local_fire_department_rounded,
      color: AppColors.red,
      route: '/ar/CuCO3_Heating',
      enabled: true,
    ),
    _ExperimentItem(
      title: 'Rate of Reaction',
      subtitle: 'Concentration and temperature effects on reaction rate.',
      chapter: 'Chapter 7',
      icon: Icons.air_rounded,
      // Was AppColors.cyan - kept as a distinct third accent (alongside
      // red/amber above/below) so the three experiment cards stay visually
      // distinguishable, just recolored off the old blue theme.
      color: AppColors.indigo,
      route: '/ar/RateOfReactionExperiment',
      enabled: true,
    ),
    _ExperimentItem(
      title: 'Neutralisation',
      subtitle: 'Acid-base neutralisation reaction in Unity.',
      chapter: 'Chapter 4',
      icon: Icons.opacity_rounded,
      color: AppColors.amber,
      route: '/ar/Neutralisation',
      enabled: true,
    ),
    _ExperimentItem(
      title: 'Salt Formation',
      subtitle: 'Salt preparation experiment module.',
      chapter: 'Chapter 6',
      icon: Icons.science_rounded,
      color: AppColors.green,
      route: '/ar/SaltFormation',
      enabled: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('UNITY EXPERIMENTS', style: AppTextStyles.labelSmall),
            Text('AR Chemistry Lab', style: AppTextStyles.displayMedium),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: ChemistryBackground(
        // Purple theme, matching the rest of the app. This is the
        // experiment LIST page only - the Unity/AR experience launched via
        // context.push(experiment.route) is untouched by this pass.
        gradientCenter: Colors.white,
        gradientEdge: AppColors.lilacGlow,
        gridColor: AppColors.indigo,
        accentColor: AppColors.indigo,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          itemCount: _experiments.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final experiment = _experiments[index];
            return _ExperimentCard(
                  item: experiment,
                  onTap: experiment.enabled
                      ? () => context.push(experiment.route)
                      : null,
                )
                .animate(delay: Duration(milliseconds: index * 70))
                .fadeIn()
                .slideY(begin: 0.08, end: 0);
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 3),
    );
  }
}

class _ExperimentCard extends StatelessWidget {
  final _ExperimentItem item;
  final VoidCallback? onTap;

  const _ExperimentCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1 : 0.58,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: enabled
                  ? item.color.withValues(alpha: 0.35)
                  : AppColors.border,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: item.color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: AppTextStyles.headingSmall,
                          ),
                        ),
                        _StatusPill(
                          text: enabled ? 'OPEN' : 'SOON',
                          color: enabled
                              ? AppColors.green
                              : AppColors.textMuted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.subtitle,
                      style: AppTextStyles.bodySmall.copyWith(height: 1.45),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          color: item.color,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.chapter,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: item.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (enabled) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.textMuted,
                  size: 16,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusPill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(text, style: AppTextStyles.labelSmall.copyWith(color: color)),
    );
  }
}

class _ExperimentItem {
  final String title;
  final String subtitle;
  final String chapter;
  final IconData icon;
  final Color color;
  final String route;
  final bool enabled;

  const _ExperimentItem({
    required this.title,
    required this.subtitle,
    required this.chapter,
    required this.icon,
    required this.color,
    required this.route,
    required this.enabled,
  });
}
