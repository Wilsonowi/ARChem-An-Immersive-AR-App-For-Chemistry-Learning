import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../chapters/chapters_data.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../quiz/quiz_chapter_card.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/chemistry_background.dart';

class SubjectiveChapterMenuScreen extends StatelessWidget {
  const SubjectiveChapterMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SPM PRACTICE', style: AppTextStyles.labelSmall),
            Text('Subjective', style: AppTextStyles.displayMedium),
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
        // ChemistryBackground keeps its default look. QuizChapterCard below
        // stays on its per-chapter color (chapter.color) - that's shared,
        // functional color-coding also used by Study Plan and the Chapters
        // list, not part of this theme pass.
        gradientCenter: Colors.white,
        gradientEdge: AppColors.lilacGlow,
        gridColor: AppColors.indigo,
        accentColor: AppColors.indigo,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          itemCount: kChapters.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final chapter = kChapters[index];
            return QuizChapterCard(
              chapterNumber: chapter.number,
              title: chapter.title,
              shortTitle: chapter.shortTitle,
              subtopicCount: chapter.subtopics.length,
              icon: chapter.icon,
              color: chapter.color,
              onTap: () => context.push('/quiz-subjective/${chapter.number}'),
            )
                .animate(delay: Duration(milliseconds: index * 60))
                .fadeIn()
                .slideY(begin: 0.08, end: 0);
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 4),
    );
  }
}
