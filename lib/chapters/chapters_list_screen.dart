import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'chapters_data.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/chemistry_background.dart';
import 'chapters_card.dart';
import '../home/home_controller.dart';

class ChapterListScreen extends ConsumerWidget {
  const ChapterListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeControllerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CHEMISTRY BY AR CHEM', style: AppTextStyles.labelSmall),
            Text('Chapters', style: AppTextStyles.displayMedium),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: ChemistryBackground(
        // Purple theme, matching Home/Quiz module - see
        // lib/widgets/chemistry_background.dart for the (backward-compatible)
        // override params; every other still-blue screen using
        // ChemistryBackground keeps its default look. ChapterCard below
        // stays on its per-chapter color (chapter.color) - that's shared,
        // functional color-coding also used by Study Plan and the quiz
        // chapter-list screens, not part of this theme pass.
        gradientCenter: Colors.white,
        gradientEdge: AppColors.lilacGlow,
        gridColor: AppColors.indigo,
        accentColor: AppColors.indigo,
        child: state.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.indigo),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                itemCount: kChapters.length,
                itemBuilder: (context, i) {
                  final chapter = kChapters[i];
                  final progress = ref.watch(
                    chapterProgressProvider(chapter.number),
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child:
                        ChapterCard(
                              chapter: chapter,
                              progress: progress,
                              compact: false,
                              showProgressBar: false,
                              onTap: () =>
                                  context.push('/lecture/${chapter.number}'),
                            )
                            .animate(delay: Duration(milliseconds: i * 60))
                            .fadeIn()
                            .slideY(begin: 0.1, end: 0),
                  );
                },
              ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
    );
  }
}
