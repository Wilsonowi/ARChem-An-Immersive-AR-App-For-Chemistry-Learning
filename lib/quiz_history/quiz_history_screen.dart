import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../widgets/chemistry_background.dart';
import 'models/quiz_history_model.dart';
import 'quiz_history_controller.dart';

class QuizHistoryScreen extends ConsumerWidget {
  const QuizHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quizHistoryControllerProvider);
    final controller = ref.read(quizHistoryControllerProvider.notifier);

    ref.listen(quizHistoryControllerProvider, (previous, next) {
      final justReady = next.analysisPhase == AnalysisPhase.ready &&
          previous?.analysisPhase != AnalysisPhase.ready;
      if (justReady) _showAnalysisSheet(context, next.analysis!);
    });

    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
                context.go('/profile');
              }
            },
          ),
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: Text('Quiz History', style: AppTextStyles.headingMedium),
          bottom: TabBar(
            labelColor: AppColors.indigo,
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: AppColors.indigo,
            labelStyle: AppTextStyles.labelMedium,
            tabs: const [
              Tab(text: 'MCQ'),
              Tab(text: 'Subjective'),
            ],
          ),
        ),
        body: ChemistryBackground(
          gradientCenter: Colors.white,
          gradientEdge: AppColors.lilacGlow,
          gridColor: AppColors.indigo,
          accentColor: AppColors.indigo,
          child: switch (state.loadPhase) {
            HistoryLoadPhase.loading => const _CenteredLoader(
                label: 'Loading your quiz history...',
              ),
            HistoryLoadPhase.error => _ErrorView(
                message: state.loadError ?? 'Something went wrong.',
                onRetry: controller.retryLoad,
              ),
            HistoryLoadPhase.ready => TabBarView(
                children: [
                  _McqHistoryList(attempts: state.mcqAttempts),
                  _SubjectiveHistoryList(attempts: state.subjectiveAttempts),
                ],
              ),
          },
        ),
        bottomNavigationBar: state.loadPhase == HistoryLoadPhase.ready &&
                state.hasAnyHistory
            ? _AnalyzeBar(
                analyzing: state.analysisPhase == AnalysisPhase.analyzing,
                onTap: controller.analyzeWeaknesses,
              )
            : null,
      ),
    );
  }

  void _showAnalysisSheet(BuildContext context, WeaknessAnalysis analysis) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AnalysisSheet(analysis: analysis),
    );
  }
}

class _CenteredLoader extends StatelessWidget {
  final String label;

  const _CenteredLoader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.indigo),
          const SizedBox(height: 16),
          Text(label, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.red, size: 48),
            const SizedBox(height: 16),
            Text(message, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.indigo),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String label;

  const _EmptyState({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, color: AppColors.textMuted, size: 40),
            const SizedBox(height: 12),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── MCQ HISTORY ──────────────────────────────────────────────

class _McqHistoryList extends StatelessWidget {
  final List<McqAttempt> attempts;

  const _McqHistoryList({required this.attempts});

  @override
  Widget build(BuildContext context) {
    if (attempts.isEmpty) {
      return const _EmptyState(label: 'No MCQ quizzes attempted yet.');
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: attempts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _McqAttemptCard(attempt: attempts[index]),
    );
  }
}

class _McqAttemptCard extends StatelessWidget {
  final McqAttempt attempt;

  const _McqAttemptCard({required this.attempt});

  @override
  Widget build(BuildContext context) {
    final chapterColor = AppColors.chapterColor(attempt.chapterNumber);
    final scoreColor = _scoreColor(attempt.score, attempt.total);
    final percent = attempt.total == 0 ? 0.0 : attempt.score / attempt.total;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: chapterColor.withValues(alpha: 0.26)),
          boxShadow: [
            BoxShadow(
              color: chapterColor.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 6, color: chapterColor),
              Expanded(
                child: ExpansionTile(
                tilePadding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                leading: _ChapterBadge(
                  chapterNumber: attempt.chapterNumber,
                  color: chapterColor,
                ),
                title: Text(attempt.chapter, style: AppTextStyles.headingSmall),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(attempt.createdAt),
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: percent.clamp(0.0, 1.0).toDouble(),
                          minHeight: 6,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            scoreColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                trailing: _ScorePill(
                  label: '${attempt.score}/${attempt.total}',
                  color: scoreColor,
                ),
                children: attempt.questions
                    .asMap()
                    .entries
                    .map(
                      (entry) => _McqQuestionRow(
                        number: entry.key + 1,
                        question: entry.value,
                        chapterColor: chapterColor,
                      ),
                    )
                    .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _McqQuestionRow extends StatelessWidget {
  final int number;
  final McqHistoryQuestion question;
  final Color chapterColor;

  const _McqQuestionRow({
    required this.number,
    required this.question,
    required this.chapterColor,
  });

  @override
  Widget build(BuildContext context) {
    final resultColor = question.isCorrect ? AppColors.green : AppColors.red;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: chapterColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: chapterColor.withValues(alpha: 0.14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: resultColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              question.isCorrect
                  ? Icons.check_rounded
                  : Icons.close_rounded,
              color: resultColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question $number',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: chapterColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  question.questionText,
                  style: AppTextStyles.bodySmall.copyWith(height: 1.4),
                ),
                const SizedBox(height: 8),
                _AnswerLine(
                  label: 'Your answer',
                  value: question.selectedAnswer ?? '-',
                  color: question.isCorrect ? AppColors.green : AppColors.red,
                ),
                if (!question.isCorrect) ...[
                  const SizedBox(height: 4),
                  _AnswerLine(
                    label: 'Correct answer',
                    value: question.correctAnswer,
                    color: AppColors.green,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── SUBJECTIVE HISTORY ───────────────────────────────────────

class _SubjectiveHistoryList extends StatelessWidget {
  final List<SubjectiveAttempt> attempts;

  const _SubjectiveHistoryList({required this.attempts});

  @override
  Widget build(BuildContext context) {
    final visibleAttempts = attempts.isEmpty
        ? _sampleSubjectiveAttempts
        : attempts;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: visibleAttempts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) =>
          _SubjectiveAttemptCard(attempt: visibleAttempts[index]),
    );
  }
}

class _SubjectiveAttemptCard extends StatelessWidget {
  final SubjectiveAttempt attempt;

  const _SubjectiveAttemptCard({required this.attempt});

  @override
  Widget build(BuildContext context) {
    final chapterColor = AppColors.chapterColor(attempt.chapterNumber);
    final scoreColor = _scoreColor(attempt.totalAwarded, attempt.totalPossible);
    final percent = attempt.totalPossible == 0
        ? 0.0
        : attempt.totalAwarded / attempt.totalPossible;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: chapterColor.withValues(alpha: 0.26)),
          boxShadow: [
            BoxShadow(
              color: chapterColor.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 6, color: chapterColor),
              Expanded(
                child: ExpansionTile(
                tilePadding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                leading: _ChapterBadge(
                  chapterNumber: attempt.chapterNumber,
                  color: chapterColor,
                ),
                title: Text(attempt.chapter, style: AppTextStyles.headingSmall),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(attempt.createdAt),
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: percent.clamp(0.0, 1.0).toDouble(),
                          minHeight: 6,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            scoreColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                trailing: _ScorePill(
                  label:
                      '${attempt.totalAwarded}/${attempt.totalPossible}',
                  color: scoreColor,
                ),
                children: attempt.questions
                    .asMap()
                    .entries
                    .map(
                      (entry) => _SubjectiveQuestionRow(
                        number: entry.key + 1,
                        question: entry.value,
                        chapterColor: chapterColor,
                      ),
                    )
                    .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubjectiveQuestionRow extends StatelessWidget {
  final int number;
  final SubjectiveHistoryQuestion question;
  final Color chapterColor;

  const _SubjectiveQuestionRow({
    required this.number,
    required this.question,
    required this.chapterColor,
  });

  @override
  Widget build(BuildContext context) {
    final scoreColor = _scoreColor(question.marksAwarded, question.marks);

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: chapterColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: chapterColor.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Question $number',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: chapterColor,
                  ),
                ),
              ),
              _ScorePill(
                label: '${question.marksAwarded}/${question.marks}',
                color: scoreColor,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question.question,
            style: AppTextStyles.bodySmall.copyWith(
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (question.studentAnswer.isNotEmpty) ...[
            const SizedBox(height: 10),
            _AnswerLine(
              label: 'Your answer',
              value: question.studentAnswer,
              color: AppColors.textSecondary,
            ),
          ],
          if (question.explanation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              question.explanation,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChapterBadge extends StatelessWidget {
  final int chapterNumber;
  final Color color;

  const _ChapterBadge({required this.chapterNumber, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        'Ch\n$chapterNumber',
        textAlign: TextAlign.center,
        style: AppTextStyles.labelSmall.copyWith(color: color, height: 1.05),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final String label;
  final Color color;

  const _ScorePill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }
}

class _AnswerLine extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _AnswerLine({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
          height: 1.35,
        ),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: value, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}

// ── ANALYZE BAR + SHEET ──────────────────────────────────────

class _AnalyzeBar extends StatelessWidget {
  final bool analyzing;
  final VoidCallback onTap;

  const _AnalyzeBar({required this.analyzing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: analyzing ? null : onTap,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.indigo),
            icon: analyzing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                  )
                : const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
            label: Text(
              analyzing ? 'Analyzing...' : 'Analyze My Weak Topics',
              style: AppTextStyles.button.copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnalysisSheet extends StatelessWidget {
  final WeaknessAnalysis analysis;

  const _AnalysisSheet({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: AppColors.indigo, size: 20),
                const SizedBox(width: 8),
                Text('Your Weak Topics', style: AppTextStyles.headingSmall),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              analysis.overallSummary.isEmpty
                  ? 'No summary was returned.'
                  : analysis.overallSummary,
              style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
            ),
            if (analysis.weakTopics.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...analysis.weakTopics.map(
                (topic) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.amberDim,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: AppColors.amber, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              topic.chapterNumber != null
                                  ? 'Ch ${topic.chapterNumber}: ${topic.topic}'
                                  : topic.topic,
                              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      if (topic.reason.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(topic.reason, style: AppTextStyles.bodySmall.copyWith(height: 1.4)),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Color _scoreColor(num score, num total) {
  if (total <= 0) return AppColors.textMuted;
  final percent = score / total;
  if (percent >= 0.8) return AppColors.green;
  if (percent >= 0.5) return AppColors.amber;
  return AppColors.red;
}

final List<SubjectiveAttempt> _sampleSubjectiveAttempts = [
  SubjectiveAttempt(
    chapter: 'Acid, Base and Salt',
    chapterNumber: 6,
    createdAt: DateTime(2026, 9, 12, 15, 30),
    totalAwarded: 5,
    totalPossible: 7,
    questions: const [
      SubjectiveHistoryQuestion(
        question:
            'Explain why hydrochloric acid only shows acidic properties when dissolved in water.',
        marks: 3,
        studentAnswer:
            'It ionises in water to produce hydrogen ions. Without water there are no mobile ions, so it does not show acidic properties.',
        marksAwarded: 3,
        explanation:
            'Good answer. You correctly linked acidic properties to the formation of hydrogen ions in aqueous solution.',
      ),
      SubjectiveHistoryQuestion(
        question:
            'A student reacts zinc with dilute hydrochloric acid. State the gas produced and describe one chemical test for the gas.',
        marks: 4,
        studentAnswer:
            'Hydrogen gas is produced. Test it using a lighted splint and it gives a pop sound.',
        marksAwarded: 2,
        explanation:
            'The gas and test are correct. Add the balanced equation and observation details to score full marks.',
      ),
    ],
  ),
  SubjectiveAttempt(
    chapter: 'The Mole Concept, Chemical Formula and Equation',
    chapterNumber: 3,
    createdAt: DateTime(2026, 9, 10, 20, 15),
    totalAwarded: 4,
    totalPossible: 6,
    questions: const [
      SubjectiveHistoryQuestion(
        question:
            'Calculate the number of moles in 12 g of carbon. Relative atomic mass of carbon = 12.',
        marks: 2,
        studentAnswer: 'Number of moles = mass / molar mass = 12 / 12 = 1 mol.',
        marksAwarded: 2,
        explanation:
            'Correct calculation with formula, substitution, and unit.',
      ),
      SubjectiveHistoryQuestion(
        question:
            'Balance the equation for the reaction between magnesium and oxygen to form magnesium oxide.',
        marks: 4,
        studentAnswer: 'Mg + O2 -> MgO',
        marksAwarded: 2,
        explanation:
            'The product is correct, but the balanced equation should be 2Mg + O2 -> 2MgO.',
      ),
    ],
  ),
  SubjectiveAttempt(
    chapter: 'Chemical Bond',
    chapterNumber: 5,
    createdAt: DateTime(2026, 9, 8, 10, 5),
    totalAwarded: 2,
    totalPossible: 5,
    questions: const [
      SubjectiveHistoryQuestion(
        question:
            'Compare ionic compounds and covalent compounds in terms of electrical conductivity.',
        marks: 5,
        studentAnswer:
            'Ionic compounds conduct electricity. Covalent compounds do not conduct electricity.',
        marksAwarded: 2,
        explanation:
            'Partly correct. Mention that ionic compounds conduct only when molten or aqueous because ions are mobile.',
      ),
    ],
  ),
];

String _formatDate(DateTime dt) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
}
