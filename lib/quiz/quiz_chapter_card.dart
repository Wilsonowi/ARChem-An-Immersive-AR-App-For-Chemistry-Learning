import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// Chapter-selection card used by both the MCQ quiz menu and the subjective
/// quiz chapter menu, so both paths share one identical chapter list.
class QuizChapterCard extends StatelessWidget {
  final int chapterNumber;
  final String title;
  final String shortTitle;
  final int subtopicCount;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuizChapterCard({
    super.key,
    required this.chapterNumber,
    required this.title,
    required this.shortTitle,
    required this.subtopicCount,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.32)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chapter $chapterNumber',
                    style: AppTextStyles.labelSmall.copyWith(color: color),
                  ),
                  const SizedBox(height: 4),
                  Text(shortTitle, style: AppTextStyles.headingSmall),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: AppTextStyles.bodySmall.copyWith(height: 1.35),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$subtopicCount subtopics',
                    style: AppTextStyles.labelSmall.copyWith(color: color),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textMuted,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
