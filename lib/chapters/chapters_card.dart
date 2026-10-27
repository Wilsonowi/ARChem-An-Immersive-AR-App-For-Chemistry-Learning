import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/chapter_model.dart';

class ChapterCard extends StatelessWidget {
  final ChapterModel chapter;
  final ChapterProgress? progress;
  final VoidCallback? onTap;
  final bool compact;
  final bool showProgressBar;

  const ChapterCard({
    super.key,
    required this.chapter,
    this.progress,
    this.onTap,
    this.compact = false,
    this.showProgressBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = chapter.color;
    final expDone = progress?.experimentDone ?? false;
    final percent = progress?.percentage ?? 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top colour strip
            Container(height: 4, color: color),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chapter number + icon row
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(chapter.icon, color: color, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Ch ${chapter.number}',
                        style: AppTextStyles.labelMedium.copyWith(color: color),
                      ),
                      const Spacer(),
                      // Experiment badge
                      if (expDone)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.greenDim,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.green.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.science_rounded,
                                color: AppColors.green,
                                size: 10,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Lab',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.green,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Chapter title
                  Text(
                    compact ? chapter.shortTitle : chapter.title,
                    style: AppTextStyles.headingSmall,
                    maxLines: compact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (!compact) ...[
                    const SizedBox(height: 4),
                    Text(
                      chapter.description,
                      style: AppTextStyles.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  if (showProgressBar) ...[
                    const SizedBox(height: 12),

                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: percent,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 4,
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
