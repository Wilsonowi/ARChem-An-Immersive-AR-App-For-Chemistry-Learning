import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../answer_marking/models/marking_result_model.dart';
import '../answer_marking/services/marking_service.dart';
import '../chapters/chapters_data.dart';
import '../services/gemini_service.dart';
import '../services/supabase_service.dart';
import 'chat_suggestions.dart';

enum ChatMessageKind { text, image, markingResult }

class ChatMessage {
  final String role;
  final ChatMessageKind kind;
  final String text;
  final Uint8List? imageBytes;
  final MarkingResult? markingResult;

  const ChatMessage({
    required this.role,
    this.kind = ChatMessageKind.text,
    this.text = '',
    this.imageBytes,
    this.markingResult,
  });

  bool get isUser => role == 'user';

  Map<String, String> toHistoryJson() => {'role': role, 'text': text};
}

const _greeting = ChatMessage(
  role: 'assistant',
  text:
      'Hi, I am your ARChem tutor. Ask me about any SPM Form 4 Chemistry '
      'concept, calculation, equation, or quiz question - or attach a '
      "photo of a handwritten answer and I'll mark it for you.",
);

enum MarkingFlowPhase { awaitingChapter, ocrLoading, reviewing, marking }

/// In-progress state for a photo the student has attached but not yet
/// confirmed for marking. Cleared once marking completes (success or
/// failure) - the result then lives as a normal ChatMessage in the
/// timeline, same as any tutor reply.
class MarkingFlowState {
  final MarkingFlowPhase phase;
  final Uint8List imageBytes;
  final int? chapterNumber;
  final OcrExtraction? ocr;

  const MarkingFlowState({
    required this.phase,
    required this.imageBytes,
    this.chapterNumber,
    this.ocr,
  });

  MarkingFlowState copyWith({
    MarkingFlowPhase? phase,
    int? chapterNumber,
    OcrExtraction? ocr,
  }) {
    return MarkingFlowState(
      phase: phase ?? this.phase,
      imageBytes: imageBytes,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      ocr: ocr ?? this.ocr,
    );
  }
}

class ChatbotState {
  final List<ChatMessage> messages;
  final bool isSending;
  final List<String> suggestedPrompts;
  final MarkingFlowState? markingFlow;

  const ChatbotState({
    this.messages = const [_greeting],
    this.isSending = false,
    this.suggestedPrompts = ChatSuggestions.defaultPrompts,
    this.markingFlow,
  });

  ChatbotState copyWith({
    List<ChatMessage>? messages,
    bool? isSending,
    List<String>? suggestedPrompts,
    MarkingFlowState? markingFlow,
    bool clearMarkingFlow = false,
  }) {
    return ChatbotState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      suggestedPrompts: suggestedPrompts ?? this.suggestedPrompts,
      markingFlow: clearMarkingFlow ? null : markingFlow ?? this.markingFlow,
    );
  }

  bool get isMarking => markingFlow?.phase == MarkingFlowPhase.marking;
  bool get isOcrLoading => markingFlow?.phase == MarkingFlowPhase.ocrLoading;
  bool get isAwaitingChapter =>
      markingFlow?.phase == MarkingFlowPhase.awaitingChapter;
  bool get isReviewing => markingFlow?.phase == MarkingFlowPhase.reviewing;
}

/// Chat state for the merged AI Tutor + AI Marking agent screen. Both
/// underlying Gemini pipelines are unchanged from before this merge:
/// GeminiService.sendRagTutorMessage for text, and MarkingService's
/// extractHandwriting/markHandwrittenAnswer for photos - this class only
/// orchestrates which one runs and folds the result into one timeline.
class ChatbotController extends StateNotifier<ChatbotState> {
  ChatbotController()
    : _gemini = GeminiService.instance,
      _supabase = SupabaseService.instance,
      _marking = MarkingService.instance,
      _picker = ImagePicker(),
      super(const ChatbotState()) {
    _historyLoad = _loadHistory();
  }

  final GeminiService _gemini;
  final SupabaseService _supabase;
  final MarkingService _marking;
  final ImagePicker _picker;
  late final Future<void> _historyLoad;

  Future<void> _loadHistory() async {
    try {
      final turns = await _supabase.fetchRecentChatHistory(limit: 10);
      if (turns.isEmpty) return;
      if (state.messages.length != 1) return;

      final loaded = <ChatMessage>[_greeting];
      for (final turn in turns) {
        final question = (turn['question'] as String? ?? '').trim();
        final answer = (turn['answer'] as String? ?? '').trim();
        if (question.isNotEmpty) {
          loaded.add(ChatMessage(role: 'user', text: question));
        }
        if (answer.isNotEmpty) {
          loaded.add(ChatMessage(role: 'assistant', text: answer));
        }
      }
      state = state.copyWith(messages: loaded);
    } catch (e, st) {
      debugPrint('fetchRecentChatHistory failed: $e\n$st');
    }
  }

  // ── TEXT (tutor) ──────────────────────────────────────

  Future<void> sendMessage(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty || state.isSending) return;

    await _historyLoad;
    if (state.isSending) return;

    final history = _recentTextHistory();

    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(role: 'user', text: text),
      ],
      isSending: true,
    );

    final reply = await _gemini.sendRagTutorMessage(
      message: text,
      history: history,
    );

    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(role: 'assistant', text: reply),
      ],
      isSending: false,
      suggestedPrompts: ChatSuggestions.forReply(reply),
    );

    try {
      await _supabase.saveChatTurn(question: text, answer: reply);
    } catch (e, st) {
      debugPrint('saveChatTurn failed: $e\n$st');
    }
  }

  List<Map<String, String>> _recentTextHistory() {
    final history = state.messages
        .where(
          (message) =>
              message.kind == ChatMessageKind.text &&
              message.text.trim().isNotEmpty &&
              message.text != _greeting.text,
        )
        .map((message) => message.toHistoryJson())
        .toList();

    return history.length > 10 ? history.sublist(history.length - 10) : history;
  }

  // ── PHOTO (marking) ───────────────────────────────────

  Future<void> attachPhoto(ImageSource source) async {
    if (state.isSending || state.markingFlow != null) return;

    final picked = await _picker.pickImage(source: source, imageQuality: 90);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();

    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(
          role: 'user',
          kind: ChatMessageKind.image,
          imageBytes: bytes,
        ),
        const ChatMessage(
          role: 'assistant',
          text: 'Which chapter is this for?',
        ),
      ],
      markingFlow: MarkingFlowState(
        phase: MarkingFlowPhase.awaitingChapter,
        imageBytes: bytes,
      ),
    );
  }

  Future<void> selectChapterForPhoto(int chapterNumber) async {
    final flow = state.markingFlow;
    if (flow == null || flow.phase != MarkingFlowPhase.awaitingChapter) return;

    state = state.copyWith(
      markingFlow: flow.copyWith(
        phase: MarkingFlowPhase.ocrLoading,
        chapterNumber: chapterNumber,
      ),
    );

    try {
      final ocr = await _marking.extractHandwriting(
        imageBytes: flow.imageBytes,
        mimeType: 'image/jpeg',
      );
      final current = state.markingFlow;
      if (current == null) return; // cancelled while awaiting
      state = state.copyWith(
        markingFlow: current.copyWith(
          phase: MarkingFlowPhase.reviewing,
          ocr: ocr,
        ),
      );
    } catch (e, st) {
      debugPrint('extractHandwriting failed: $e\n$st');
      _failMarking(
        "Sorry, I couldn't read that photo clearly. Check your "
        'connection and try attaching it again.',
      );
    }
  }

  void updateReviewField({String? question, String? marks, String? answer}) {
    final flow = state.markingFlow;
    final ocr = flow?.ocr;
    if (flow == null || ocr == null) return;

    var updated = ocr;
    if (question != null) updated = updated.copyWith(questionText: question);
    if (answer != null) updated = updated.copyWith(studentAnswerText: answer);
    if (marks != null) {
      final parsed = int.tryParse(marks.trim());
      updated = parsed == null
          ? updated.copyWith(clearMarksAllocated: true)
          : updated.copyWith(marksAllocated: parsed);
    }
    state = state.copyWith(markingFlow: flow.copyWith(ocr: updated));
  }

  void cancelMarkingFlow() {
    state = state.copyWith(clearMarkingFlow: true);
  }

  Future<void> confirmMarking() async {
    final flow = state.markingFlow;
    final ocr = flow?.ocr;
    if (flow == null || ocr == null || flow.chapterNumber == null) return;
    if (ocr.questionText.trim().isEmpty ||
        ocr.studentAnswerText.trim().isEmpty) {
      return;
    }

    state = state.copyWith(
      markingFlow: flow.copyWith(phase: MarkingFlowPhase.marking),
    );

    final chapter = _chapterTitle(flow.chapterNumber!);
    try {
      final result = await _marking.markHandwrittenAnswer(
        questionText: ocr.questionText.trim(),
        ocrText: ocr.studentAnswerText.trim(),
        chapter: chapter,
        maxScore: ocr.marksAllocated ?? MarkingService.defaultMaxScore,
      );

      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(
            role: 'assistant',
            kind: ChatMessageKind.markingResult,
            markingResult: result,
          ),
        ],
        clearMarkingFlow: true,
      );

      unawaited(
        _marking
            .saveSubmission(
              chapter: chapter,
              chapterNumber: flow.chapterNumber!,
              ocr: ocr,
              result: result,
            )
            .catchError(
              (e, st) => debugPrint('saveSubmission failed: $e\n$st'),
            ),
      );
    } catch (e, st) {
      debugPrint('markHandwrittenAnswer failed: $e\n$st');
      _failMarking(
        "Sorry, I couldn't mark that answer. Check your "
        'connection and try again.',
      );
    }
  }

  void _failMarking(String message) {
    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(role: 'assistant', text: message),
      ],
      clearMarkingFlow: true,
    );
  }

  String _chapterTitle(int chapterNumber) {
    return kChapters
        .firstWhere(
          (chapter) => chapter.number == chapterNumber,
          orElse: () => kChapters.first,
        )
        .title;
  }
}

final chatbotControllerProvider =
    StateNotifierProvider<ChatbotController, ChatbotState>(
      (ref) => ChatbotController(),
    );
