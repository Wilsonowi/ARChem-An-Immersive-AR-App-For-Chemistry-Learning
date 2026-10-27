import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/chapter_model.dart';
import '../models/study_plan_stage.dart';
import '../services/supabase_service.dart';
import '../auth/auth_controller.dart';

// ── HOME STATE ────────────────────────────────────────────

class HomeState {
  final bool isLoading;
  final UserModel? user;
  final List<ChapterProgress> chapterProgress;
  final Map<String, dynamic>? studyPlanPayload;
  final String? error;

  const HomeState({
    this.isLoading = false,
    this.user = null,
    this.chapterProgress = const [],
    this.studyPlanPayload,
    this.error = null,
  });

  HomeState copyWith({
    bool? isLoading,
    UserModel? user,
    List<ChapterProgress>? chapterProgress,
    Map<String, dynamic>? studyPlanPayload,
    String? error,
    bool clearError = false,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      chapterProgress: chapterProgress ?? this.chapterProgress,
      studyPlanPayload: studyPlanPayload ?? this.studyPlanPayload,
      error: clearError ? null : error ?? this.error,
    );
  }

  int get completedChapters =>
      chapterProgress.where((p) => p.quizScore >= 3).length;

  double get overallPercent {
    if (chapterProgress.isEmpty) return 0.0;
    final total = chapterProgress.fold<double>(
      0,
      (sum, p) => sum + p.percentage,
    );
    return total / 8;
  }

  StudyPlanStage? get currentStudyStage =>
      StudyPlanStage.currentFromPlan(studyPlanPayload);

  bool get hasStudyPlan => studyPlanPayload != null;

  bool get isStudyPlanComplete => StudyPlanStage.isComplete(studyPlanPayload);
}

// ── HOME CONTROLLER ───────────────────────────────────────

class HomeController extends StateNotifier<HomeState> {
  HomeController(this._ref) : super(const HomeState()) {
    load();
  }

  final Ref _ref;
  final _service = SupabaseService.instance;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Load user from auth state first (instant, no network)
      final authUser = _ref.read(currentUserProvider);
      if (authUser != null) {
        state = state.copyWith(user: authUser);
      }

      // Fetch fresh profile and progress in parallel.
      final results = await Future.wait([
        _service.fetchProfile(),
        _service.fetchProgress(),
      ]);
      final studyPlan = await _service.fetchNormalizedStudyPlanPayload();

      final profile = results[0] as UserModel?;
      final progress = results[1] as List<Map<String, dynamic>>;

      final chapterProgress = progress
          .map((p) => ChapterProgress.fromJson(p))
          .toList();

      state = state.copyWith(
        isLoading: false,
        user: profile ?? authUser,
        chapterProgress: chapterProgress,
        studyPlanPayload: studyPlan,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Could not load data. Check your connection.',
      );
    }
  }

  ChapterProgress? progressFor(int chapterNumber) {
    try {
      return state.chapterProgress.firstWhere(
        (p) => p.chapterNumber == chapterNumber,
      );
    } catch (_) {
      return null;
    }
  }
}

// ── PROVIDERS ─────────────────────────────────────────────

final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>(
  (ref) {
    return HomeController(ref);
  },
);

final chapterProgressProvider = Provider.family<ChapterProgress?, int>((
  ref,
  chapterNumber,
) {
  return ref.watch(homeControllerProvider.notifier).progressFor(chapterNumber);
});
