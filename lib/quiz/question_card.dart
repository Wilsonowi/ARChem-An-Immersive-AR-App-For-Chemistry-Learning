import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/question_model.dart';

class QuestionCard extends StatefulWidget {
  final QuestionModel question;
  final int? selectedIndex;
  final bool answered;
  final Function(int) onOptionSelected;
  final Color accentColor;

  const QuestionCard({
    super.key,
    required this.question,
    required this.selectedIndex,
    required this.answered,
    required this.onOptionSelected,
    this.accentColor = AppColors.cyan,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  static const _labels = ['A', 'B', 'C', 'D'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question text card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            widget.question.question,
            style: AppTextStyles.bodyLarge.copyWith(height: 1.6),
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),

        const SizedBox(height: 16),

        // Option buttons
        ...List.generate(widget.question.options.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child:
                _OptionButton(
                      label: _labels[i],
                      text: widget.question.options[i],
                      state: _getOptionState(i),
                      accentColor: widget.accentColor,
                      onTap: widget.answered
                          ? null
                          : () {
                              widget.onOptionSelected(i);
                            },
                    )
                    .animate(delay: Duration(milliseconds: 60 * i))
                    .fadeIn()
                    .slideX(begin: 0.05, end: 0),
          );
        }),
      ],
    );
  }

  _OptionState _getOptionState(int index) {
    if (!widget.answered) return _OptionState.idle;
    if (index == widget.question.correctIndex) return _OptionState.correct;
    if (index == widget.selectedIndex && !_isSelectedCorrect)
      return _OptionState.wrong;
    return _OptionState.idle;
  }

  bool get _isSelectedCorrect =>
      widget.selectedIndex == widget.question.correctIndex;
}

// ── OPTION STATE ──────────────────────────────────────────
enum _OptionState { idle, correct, wrong }

// ── OPTION BUTTON ─────────────────────────────────────────
class _OptionButton extends StatelessWidget {
  final String label;
  final String text;
  final _OptionState state;
  final Color accentColor;
  final VoidCallback? onTap;

  const _OptionButton({
    required this.label,
    required this.text,
    required this.state,
    required this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor;
    final Color bgColor;
    final Color labelBg;
    final Color textColor;

    final Color iconColor;

    switch (state) {
      case _OptionState.correct:
        // Solid fill instead of a faint tint, so the correct answer reads
        // clearly at a glance rather than needing a second look.
        borderColor = Colors.transparent;
        bgColor = AppColors.green;
        labelBg = Colors.white.withValues(alpha: 0.25);
        textColor = Colors.white;
        iconColor = Colors.white;
        break;
      case _OptionState.wrong:
        borderColor = Colors.transparent;
        bgColor = AppColors.red;
        labelBg = Colors.white.withValues(alpha: 0.25);
        textColor = Colors.white;
        iconColor = Colors.white;
        break;
      case _OptionState.idle:
        borderColor = AppColors.border;
        bgColor = AppColors.card;
        labelBg = accentColor.withValues(alpha: 0.12);
        textColor = AppColors.textPrimary;
        iconColor = AppColors.textPrimary;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            // Letter badge
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: labelBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  label,
                  style: AppTextStyles.monoBold.copyWith(
                    color: state == _OptionState.idle ? accentColor : textColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Option text
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.bodyMedium.copyWith(color: textColor),
              ),
            ),

            // Correct / wrong icon
            if (state == _OptionState.correct)
              Icon(Icons.check_circle_rounded, color: iconColor, size: 20),
            if (state == _OptionState.wrong)
              Icon(Icons.cancel_rounded, color: iconColor, size: 20),
          ],
        ),
      ),
    );
  }
}
