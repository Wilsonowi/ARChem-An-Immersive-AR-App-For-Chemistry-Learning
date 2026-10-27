import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/study_plan_model.dart';
import '../services/supabase_service.dart';

// ── STATE ─────────────────────────────────────────────────
class StudyPlanState {
  final bool isLoading;
  final StudyPlanModel? plan;
  final String? error;

  const StudyPlanState({
    this.isLoading = false,
    this.plan = null,
    this.error = null,
  });

  StudyPlanState copyWith({
    bool? isLoading,
    StudyPlanModel? plan,
    String? error,
    bool clearPlan = false,
    bool clearError = false,
  }) {
    return StudyPlanState(
      isLoading: isLoading ?? this.isLoading,
      plan: clearPlan ? null : plan ?? this.plan,
      error: clearError ? null : error ?? this.error,
    );
  }

  bool get hasPlan => plan != null && plan!.hasData;
}

// ── CONTROLLER ────────────────────────────────────────────
class StudyPlanController extends StateNotifier<StudyPlanState> {
  StudyPlanController() : super(const StudyPlanState()) {
    fetchPlan();
  }

  final _supabase = SupabaseService.instance;

  Future<void> fetchPlan() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final raw = await _supabase.fetchStudyPlan();
      if (raw == null) {
        state = state.copyWith(isLoading: false, clearPlan: true);
        return;
      }
      final plan = StudyPlanModel.fromJson(raw);
      state = state.copyWith(isLoading: false, plan: plan);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Could not load your study plan. Please check your connection.',
      );
    }
  }

  Future<void> refresh() => fetchPlan();
}

// ── PROVIDER ──────────────────────────────────────────────
final studyPlanControllerProvider =
    StateNotifierProvider<StudyPlanController, StudyPlanState>(
      (ref) => StudyPlanController(),
    );
