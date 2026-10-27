import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/supabase_service.dart';
import 'models/weekly_study_plan_model.dart';
import 'services/weekly_plan_service.dart';

enum WeeklyPlanPhase { loading, generating, ready, error }

class WeeklyPlanState {
  final WeeklyPlanPhase phase;
  final DateTime viewedWeekStart; // Monday 00:00 of the week being viewed
  final DateTime currentWeekStart; // Monday 00:00 of "today"
  final WeeklyStudyPlan? plan; // null = no saved plan for viewedWeekStart
  final String selectedDayKey;
  final String? errorMessage;

  /// Whether the student has completed the diagnostic test, as of the last
  /// load(). Defaults to true so it never wrongly flashes the "take the
  /// diagnostic test" prompt before the first load() has actually checked.
  final bool hasCompletedDiagnostic;

  const WeeklyPlanState({
    required this.viewedWeekStart,
    required this.currentWeekStart,
    required this.selectedDayKey,
    this.phase = WeeklyPlanPhase.loading,
    this.plan,
    this.errorMessage,
    this.hasCompletedDiagnostic = true,
  });

  WeeklyPlanState copyWith({
    WeeklyPlanPhase? phase,
    DateTime? viewedWeekStart,
    DateTime? currentWeekStart,
    WeeklyStudyPlan? plan,
    String? selectedDayKey,
    String? errorMessage,
    bool? hasCompletedDiagnostic,
    bool clearPlan = false,
    bool clearError = false,
  }) {
    return WeeklyPlanState(
      phase: phase ?? this.phase,
      viewedWeekStart: viewedWeekStart ?? this.viewedWeekStart,
      currentWeekStart: currentWeekStart ?? this.currentWeekStart,
      plan: clearPlan ? null : plan ?? this.plan,
      selectedDayKey: selectedDayKey ?? this.selectedDayKey,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      hasCompletedDiagnostic:
          hasCompletedDiagnostic ?? this.hasCompletedDiagnostic,
    );
  }

  /// Current week, no saved plan, and the student hasn't taken the
  /// diagnostic test yet - there is no real progress signal to build a
  /// plan from, so the UI should prompt for the diagnostic test instead of
  /// silently generating a meaningless all-zero-score plan.
  bool get needsDiagnostic =>
      plan == null && isCurrentWeek && !hasCompletedDiagnostic;

  bool get isCurrentWeek => _isSameDate(viewedWeekStart, currentWeekStart);
  bool get isFutureWeek => viewedWeekStart.isAfter(currentWeekStart);
  bool get isPastWeek => viewedWeekStart.isBefore(currentWeekStart);

  List<StudyBlock> get selectedDayBlocks =>
      plan?.blocksFor(selectedDayKey) ?? const [];

  /// The FAB only makes sense on the current week's plan - adjusting a
  /// read-only past week or a not-yet-generated future week doesn't apply.
  bool get canAdjust => isCurrentWeek && plan != null;

  static bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class WeeklyPlanController extends StateNotifier<WeeklyPlanState> {
  WeeklyPlanController()
    : _service = WeeklyPlanService.instance,
      super(
        WeeklyPlanState(
          viewedWeekStart: _mondayOf(DateTime.now()),
          currentWeekStart: _mondayOf(DateTime.now()),
          selectedDayKey: _weekdayKeyOf(DateTime.now()),
        ),
      ) {
    load();
  }

  final WeeklyPlanService _service;

  Future<void> load() async {
    // Recompute "today" fresh every load - handles the app being left open
    // across midnight, or across the Monday week-boundary.
    final today = DateTime.now();
    final currentWeekStart = _mondayOf(today);

    state = state.copyWith(
      phase: WeeklyPlanPhase.loading,
      currentWeekStart: currentWeekStart,
      clearError: true,
    );

    try {
      final existing = await _service.fetchPlan(
        weekStartDate: state.viewedWeekStart,
      );

      if (existing != null) {
        state = state.copyWith(phase: WeeklyPlanPhase.ready, plan: existing);
        return;
      }

      final viewingCurrentWeek = WeeklyPlanState._isSameDate(
        state.viewedWeekStart,
        currentWeekStart,
      );

      if (!viewingCurrentWeek) {
        // Never auto-generate for a non-current week: a future week's
        // progress isn't known yet, and a past week is intentionally left
        // as history rather than backfilled.
        state = state.copyWith(phase: WeeklyPlanPhase.ready, clearPlan: true);
        return;
      }

      // No saved plan for the current week - only auto-generate one once
      // the student has actually taken the diagnostic test. Without it
      // there's no real progress signal yet, so generating here would just
      // produce a meaningless all-zero-score plan; ask them to take the
      // diagnostic test instead.
      final profile = await SupabaseService.instance.fetchProfile();
      final hasCompletedDiagnostic = profile?.hasCompletedDiagnostic ?? false;

      if (!hasCompletedDiagnostic) {
        state = state.copyWith(
          phase: WeeklyPlanPhase.ready,
          clearPlan: true,
          hasCompletedDiagnostic: false,
        );
        return;
      }

      state = state.copyWith(
        phase: WeeklyPlanPhase.generating,
        hasCompletedDiagnostic: true,
      );
      final generated = await _service.generatePlan(
        weekStartDate: state.viewedWeekStart,
      );
      state = state.copyWith(phase: WeeklyPlanPhase.ready, plan: generated);
    } catch (_) {
      state = state.copyWith(
        phase: WeeklyPlanPhase.error,
        errorMessage: 'Could not load your study plan. Check your connection.',
      );
    }
  }

  /// Forces a fresh plan for the currently viewed (current) week, ignoring
  /// any already-saved row. Used when the student explicitly wants to redo
  /// their plan - e.g. after retaking the diagnostic test - since load()
  /// on its own would just keep returning the existing saved plan.
  Future<void> regeneratePlan() async {
    state = state.copyWith(phase: WeeklyPlanPhase.generating, clearError: true);
    try {
      final generated = await _service.generatePlan(
        weekStartDate: state.viewedWeekStart,
      );
      state = state.copyWith(
        phase: WeeklyPlanPhase.ready,
        plan: generated,
        hasCompletedDiagnostic: true,
      );
    } catch (_) {
      state = state.copyWith(
        phase: WeeklyPlanPhase.error,
        errorMessage:
            'Could not rebuild your study plan. Check your connection.',
      );
    }
  }

  Future<void> changeWeek(int deltaWeeks) async {
    final newWeekStart = state.viewedWeekStart.add(Duration(days: 7 * deltaWeeks));
    final isNewWeekCurrent = WeeklyPlanState._isSameDate(
      newWeekStart,
      state.currentWeekStart,
    );

    state = state.copyWith(
      viewedWeekStart: newWeekStart,
      selectedDayKey: isNewWeekCurrent
          ? _weekdayKeyOf(DateTime.now())
          : 'monday',
      clearPlan: true,
    );
    await load();
  }

  void selectDay(String dayKey) {
    if (!WeeklyStudyPlan.weekdayKeys.contains(dayKey)) return;
    state = state.copyWith(selectedDayKey: dayKey);
  }

  /// Pure re-fetch, matching the legacy StudyPlanController.refresh()
  /// semantics exactly. Deliberately NOT a forced Gemini regeneration, so
  /// it can never silently discard a plan the student already customised
  /// via the adjustment dialog - a brand-new current week with no saved
  /// row still generates, because load() already handles that case.
  Future<void> refresh() => load();

  /// Throws on failure - the adjustment dialog catches it and shows an
  /// error + retry itself, rather than this being stored as shared
  /// screen-level error state.
  Future<String> submitAdjustment(String userText) async {
    final currentPlan = state.plan;
    if (currentPlan == null) {
      throw StateError('No plan loaded to adjust.');
    }

    final selectedDayDate = dateForSelectedDay();
    final deviceNow = DateTime.now();
    final result = await _service.requestAdjustment(
      userRequest: userText,
      selectedDayKey: state.selectedDayKey,
      selectedDayDate: selectedDayDate,
      deviceNow: deviceNow,
      currentPlan: currentPlan,
    );

    final merged = await _service.saveMergedPlan(currentPlan, result.changedDays);
    state = state.copyWith(plan: merged);
    return result.message;
  }

  DateTime dateForSelectedDay() {
    final index = WeeklyStudyPlan.weekdayKeys.indexOf(state.selectedDayKey);
    return state.viewedWeekStart.add(Duration(days: index < 0 ? 0 : index));
  }

  static DateTime _mondayOf(DateTime date) {
    final midnight = DateTime(date.year, date.month, date.day);
    return midnight.subtract(Duration(days: midnight.weekday - DateTime.monday));
  }

  static String _weekdayKeyOf(DateTime date) =>
      WeeklyStudyPlan.weekdayKeys[date.weekday - DateTime.monday];
}

final weeklyPlanControllerProvider =
    StateNotifierProvider<WeeklyPlanController, WeeklyPlanState>(
      (ref) => WeeklyPlanController(),
    );
