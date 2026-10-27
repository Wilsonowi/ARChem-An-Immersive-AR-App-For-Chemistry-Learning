import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/chemistry_background.dart';

class QuizTypeSelectionScreen extends StatelessWidget {
  const QuizTypeSelectionScreen({super.key});

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
            Text('SPM PRACTICE', style: AppTextStyles.labelSmall),
            Text('Quizzes', style: AppTextStyles.displayMedium),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: ChemistryBackground(
        // Purple theme for the quiz module - see
        // lib/widgets/chemistry_background.dart for the (backward-compatible)
        // override params; every other still-blue screen using
        // ChemistryBackground keeps its default look.
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
                Text(
                  'Choose Quiz Type',
                  style: AppTextStyles.headingLarge.copyWith(
                    color: AppColors.indigoDark,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Practice with multiple choice questions or SPM-style '
                  'structured questions.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _QuizTypeCard(
                  icon: Icons.quiz_rounded,
                  // Blue for MCQ, green for Subjective - distinct accent
                  // colours rather than two shades of the same purple.
                  color: AppColors.chapter2, // blue
                  title: 'MCQ',
                  subtitle: 'Multiple choice questions, instant feedback',
                  ctaLabel: 'START',
                  onTap: () => context.push('/quiz'),
                ).animate().fadeIn().slideY(begin: 0.08, end: 0),
                const SizedBox(height: 16),
                _QuizTypeCard(
                  icon: Icons.edit_note_rounded,
                  color: AppColors.green,
                  title: 'Subjective',
                  subtitle: 'Structured-response questions, marked by AI',
                  ctaLabel: 'START',
                  onTap: () => context.push('/quiz-subjective'),
                ).animate(delay: 80.ms).fadeIn().slideY(begin: 0.08, end: 0),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 4),
    );
  }
}

// Same "solid icon square + shadow + pill CTA" treatment used for the AI
// shortcut cards on Home (lib/home/home_screen.dart's _AiShortcutCard) -
// kept as its own local copy here since these two screens don't share a
// widget module today.
class _QuizTypeCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final VoidCallback onTap;

  const _QuizTypeCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.headingMedium.copyWith(
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
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                ctaLabel,
                style: AppTextStyles.labelSmall.copyWith(
                  color: color,
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
