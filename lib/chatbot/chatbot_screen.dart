import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:image_picker/image_picker.dart';

import '../answer_marking/models/marking_result_model.dart';
import '../chapters/chapters_data.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../home/home_controller.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/chemistry_background.dart';
import 'chatbot_controller.dart';

class ChatbotScreen extends ConsumerStatefulWidget {
  /// When true, the photo attach chooser opens automatically on first
  /// build - used by the "AI Marking" speed-dial entry and the Home
  /// screen's Mark Answer card, so they land straight in the marking flow
  /// of this same merged agent instead of a separate screen.
  final bool autoAttachMarking;

  const ChatbotScreen({super.key, this.autoAttachMarking = false});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _autoAttachTriggered = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(chatbotControllerProvider, (previous, next) {
      if (next.messages.length != previous?.messages.length) {
        _scrollToBottom();
      }
      final justStartedReviewing =
          next.isReviewing && !(previous?.isReviewing ?? false);
      if (justStartedReviewing) {
        _showReviewSheet(context);
      }
    });

    final state = ref.watch(chatbotControllerProvider);
    final controller = ref.read(chatbotControllerProvider.notifier);

    if (widget.autoAttachMarking && !_autoAttachTriggered) {
      _autoAttachTriggered = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showAttachSheet(context, controller);
      });
    }

    final busyLabel = state.isSending
        ? 'Thinking...'
        : state.isOcrLoading
        ? 'Reading your photo...'
        : state.isMarking
        ? 'Marking your answer...'
        : null;

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
        title: Row(
          children: [
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
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.indigo,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ARChem Tutor', style: AppTextStyles.headingMedium),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Home',
            icon: const Icon(
              Icons.home_rounded,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              ref.read(homeControllerProvider.notifier).load();
              context.go('/home');
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: ChemistryBackground(
        gradientCenter: Colors.white,
        gradientEdge: AppColors.lilacGlow,
        gridColor: AppColors.indigo,
        accentColor: AppColors.indigo,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                itemCount: state.messages.length + (busyLabel != null ? 1 : 0),
                itemBuilder: (context, index) {
                  if (busyLabel != null && index == state.messages.length) {
                    return _TypingBubble(label: busyLabel);
                  }

                  final message = state.messages[index];
                  return _bubbleFor(message)
                      .animate()
                      .fadeIn(duration: 220.ms)
                      .slideY(begin: 0.04, end: 0);
                },
              ),
            ),
            if (state.isAwaitingChapter)
              _ChapterChips(onSelect: controller.selectChapterForPhoto)
            else if (state.markingFlow == null)
              _QuickPrompts(
                key: ValueKey(state.suggestedPrompts.join('|')),
                prompts: state.suggestedPrompts,
                onTap: (text) => _sendMessage(controller, text),
              )
            else
              const SizedBox(height: 8),
            _Composer(
              controller: _controller,
              enabled: !state.isSending && state.markingFlow == null,
              onSend: () => _sendMessage(controller, _controller.text),
              onAttach: () => _showAttachSheet(context, controller),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
    );
  }

  Widget _bubbleFor(ChatMessage message) {
    switch (message.kind) {
      case ChatMessageKind.image:
        return _ImageBubble(imageBytes: message.imageBytes!);
      case ChatMessageKind.markingResult:
        return _MarkingResultBubble(result: message.markingResult!);
      case ChatMessageKind.text:
        return _MessageBubble(message: message);
    }
  }

  void _sendMessage(ChatbotController controller, String text) {
    if (text.trim().isEmpty) return;
    _controller.clear();
    controller.sendMessage(text);
  }

  void _showAttachSheet(BuildContext context, ChatbotController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppColors.indigo),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(sheetContext);
                controller.attachPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.indigo),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(sheetContext);
                controller.attachPhoto(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showReviewSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _ReviewSheet(),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        decoration: BoxDecoration(
          color: isUser ? AppColors.indigo : AppColors.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 6),
            bottomRight: Radius.circular(isUser ? 6 : 18),
          ),
          border: Border.all(
            color: isUser ? AppColors.indigo : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: isUser
                  ? AppColors.indigo.withValues(alpha: 0.16)
                  : AppColors.cyan.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: isUser
            ? Text(
                message.text,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  height: 1.45,
                ),
              )
            : GptMarkdown(
                message.text,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.45,
                ),
              ),
      ),
    );
  }
}

class _ImageBubble extends StatelessWidget {
  final Uint8List imageBytes;

  const _ImageBubble({required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.6,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.memory(imageBytes, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class _MarkingResultBubble extends StatelessWidget {
  final MarkingResult result;

  const _MarkingResultBubble({required this.result});

  @override
  Widget build(BuildContext context) {
    final percent = result.maxScore == 0 ? 0.0 : result.score / result.maxScore;
    final score = result.score == result.score.roundToDouble()
        ? result.score.toInt().toString()
        : result.score.toStringAsFixed(1);
    final maxScore = result.maxScore == result.maxScore.roundToDouble()
        ? result.maxScore.toInt().toString()
        : result.maxScore.toStringAsFixed(1);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.86,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
            bottomRight: Radius.circular(14),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.fact_check_rounded, color: AppColors.indigo, size: 18),
                const SizedBox(width: 8),
                Text('Marking Result', style: AppTextStyles.headingSmall),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '$score / $maxScore marks',
              style: AppTextStyles.displayMedium.copyWith(
                color: AppColors.indigo,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: percent.clamp(0, 1),
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.indigo),
                minHeight: 6,
              ),
            ),
            if (result.questionScores.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text('Per-question marks', style: AppTextStyles.labelSmall),
              const SizedBox(height: 8),
              ...result.questionScores.map(
                (questionScore) => _QuestionScoreRow(score: questionScore),
              ),
            ],
            if (result.explanation.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                result.explanation,
                style: AppTextStyles.bodySmall.copyWith(height: 1.4),
              ),
            ],
            if (result.breakdown.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...result.breakdown.map(
                (point) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        point.correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        color: point.correct ? AppColors.green : AppColors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          point.point,
                          style: AppTextStyles.bodySmall.copyWith(height: 1.35),
                        ),
                      ),
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

class _QuestionScoreRow extends StatelessWidget {
  final MarkingQuestionScore score;

  const _QuestionScoreRow({required this.score});

  @override
  Widget build(BuildContext context) {
    final awarded = score.score == score.score.roundToDouble()
        ? score.score.toInt().toString()
        : score.score.toStringAsFixed(1);
    final maximum = score.maxScore == score.maxScore.roundToDouble()
        ? score.maxScore.toInt().toString()
        : score.maxScore.toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.indigo.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.indigo.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  score.answerLabel.isEmpty
                      ? score.questionLabel
                      : '${score.questionLabel} / ${score.answerLabel}',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$awarded/$maximum',
                style: AppTextStyles.monoBold.copyWith(
                  color: AppColors.indigo,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (score.explanation.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              score.explanation,
              style: AppTextStyles.bodySmall.copyWith(height: 1.35),
            ),
          ],
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  final String label;

  const _TypingBubble({required this.label});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
            bottomRight: Radius.circular(14),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.indigo,
              ),
            ),
            const SizedBox(width: 10),
            Text(label, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}

/// Horizontally scrollable suggestion chips. Content is driven entirely by
/// [prompts], which the controller regenerates from the tutor's last reply
/// via [ChatSuggestions] - passing a new [key] when the prompt list changes
/// makes each new set animate in as its own row.
class _QuickPrompts extends StatelessWidget {
  final List<String> prompts;
  final ValueChanged<String> onTap;

  const _QuickPrompts({super.key, required this.prompts, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: prompts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final prompt = prompts[index];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => onTap(prompt),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.indigo.withValues(alpha: 0.14),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: AppColors.indigo,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      prompt,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.indigoDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(duration: 250.ms).slideX(begin: 0.08, end: 0);
        },
      ),
    );
  }
}

/// Chapter picker shown as a chip row (same pattern as _QuickPrompts) right
/// after a photo is attached, instead of a dropdown on a separate screen.
class _ChapterChips extends StatelessWidget {
  final ValueChanged<int> onSelect;

  const _ChapterChips({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: kChapters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final chapter = kChapters[index];
          return ActionChip(
            onPressed: () => onSelect(chapter.number),
            label: Text(chapter.shortTitle),
            avatar: Icon(chapter.icon, size: 16, color: chapter.color),
            backgroundColor: AppColors.surface,
            side: const BorderSide(color: AppColors.border),
            labelStyle: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(duration: 250.ms).slideX(begin: 0.08, end: 0);
        },
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;
  final VoidCallback onAttach;

  const _Composer({
    required this.controller,
    required this.enabled,
    required this.onSend,
    required this.onAttach,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.border.withValues(alpha: 0.65)),
          ),
        ),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _ComposerIconButton(
                tooltip: 'Attach photo',
                icon: Icons.add_photo_alternate_outlined,
                enabled: enabled,
                onTap: onAttach,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => enabled ? onSend() : null,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.35,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ask a chemistry question...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _SendButton(enabled: enabled, onSend: onSend),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComposerIconButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _ComposerIconButton({
    required this.tooltip,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: enabled
            ? AppColors.indigo.withValues(alpha: 0.1)
            : AppColors.surface,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onTap : null,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              icon,
              color: enabled ? AppColors.indigo : AppColors.textMuted,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onSend;

  const _SendButton({required this.enabled, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? AppColors.indigo : AppColors.border,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onSend : null,
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

/// Bottom sheet for reviewing/editing the OCR-extracted question, marks,
/// and answer before confirming marking - the same reliability step the
/// dedicated Mark My Answer screen had, just presented as a sheet over the
/// chat instead of a full-screen navigation.
class _ReviewSheet extends ConsumerStatefulWidget {
  const _ReviewSheet();

  @override
  ConsumerState<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends ConsumerState<_ReviewSheet> {
  late final TextEditingController _questionCtrl;
  late final TextEditingController _marksCtrl;
  late final TextEditingController _answerCtrl;

  @override
  void initState() {
    super.initState();
    final ocr = ref.read(chatbotControllerProvider).markingFlow?.ocr;
    _questionCtrl = TextEditingController(text: ocr?.questionText ?? '');
    _marksCtrl = TextEditingController(
      text: ocr?.marksAllocated?.toString() ?? '',
    );
    _answerCtrl = TextEditingController(text: ocr?.studentAnswerText ?? '');
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    _marksCtrl.dispose();
    _answerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ocr = ref.watch(
      chatbotControllerProvider.select((s) => s.markingFlow?.ocr),
    );
    final marking = ref.watch(
      chatbotControllerProvider.select((s) => s.isMarking),
    );
    final controller = ref.read(chatbotControllerProvider.notifier);

    if (ocr == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
              Text('Review Before Marking', style: AppTextStyles.headingSmall),
              if (ocr.hasLowConfidence) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.amberDim,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.amber, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'One or more fields were hard to read. Please '
                          'check and correct them before marking.',
                          style: AppTextStyles.bodySmall.copyWith(height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _ReviewField(
                label: 'Question(s)',
                confidence: ocr.questionConfidence,
                controller: _questionCtrl,
                minLines: 2,
                maxLines: 4,
                onChanged: (text) => controller.updateReviewField(question: text),
              ),
              const SizedBox(height: 14),
              _ReviewField(
                label: 'Marks Allocated',
                confidence: ocr.marksConfidence,
                controller: _marksCtrl,
                keyboardType: TextInputType.number,
                onChanged: (text) => controller.updateReviewField(marks: text),
              ),
              const SizedBox(height: 14),
              _ReviewField(
                label: 'Student Answer(s)',
                confidence: ocr.answerConfidence,
                controller: _answerCtrl,
                minLines: 3,
                maxLines: 8,
                onChanged: (text) => controller.updateReviewField(answer: text),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: marking
                      ? null
                      : () {
                          controller.confirmMarking();
                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.indigo),
                  child: Text(
                    'Mark It',
                    style: AppTextStyles.button.copyWith(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    controller.cancelMarkingFlow();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewField extends StatelessWidget {
  final String label;
  final ConfidenceLevel confidence;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final int minLines;
  final int maxLines;
  final TextInputType? keyboardType;

  const _ReviewField({
    required this.label,
    required this.confidence,
    required this.controller,
    required this.onChanged,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = switch (confidence) {
      ConfidenceLevel.high => AppColors.green,
      ConfidenceLevel.medium => AppColors.amber,
      ConfidenceLevel.low => AppColors.red,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AppTextStyles.labelSmall),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: badgeColor.withValues(alpha: 0.35)),
              ),
              child: Text(
                confidence.name,
                style: AppTextStyles.labelSmall.copyWith(color: badgeColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          minLines: minLines,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: AppTextStyles.bodyMedium,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
