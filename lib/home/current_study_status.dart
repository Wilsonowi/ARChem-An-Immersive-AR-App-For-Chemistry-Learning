import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../weekly_plan/models/weekly_study_plan_model.dart';
import '../weekly_plan/services/weekly_plan_service.dart';

enum CurrentStudyStatusKind { loading, noPlan, studying, resting }

/// Live "what should I be doing right now" status for the Home dashboard,
/// derived read-only from the weekly study plan (lib/weekly_plan/). This
/// file never writes to, adjusts, or regenerates that plan - it only reads
/// the current week's already-saved blocks and compares them against the
/// current time.
class CurrentStudyStatus {
  final CurrentStudyStatusKind kind;
  final StudyBlock? activeBlock; // set when kind == studying
  final StudyBlock? nextBlock; // set when kind == resting and a block remains today

  const CurrentStudyStatus._({required this.kind, this.activeBlock, this.nextBlock});

  const CurrentStudyStatus.loading() : this._(kind: CurrentStudyStatusKind.loading);
  const CurrentStudyStatus.noPlan() : this._(kind: CurrentStudyStatusKind.noPlan);
  const CurrentStudyStatus.studying(StudyBlock block)
      : this._(kind: CurrentStudyStatusKind.studying, activeBlock: block);
  const CurrentStudyStatus.resting({StudyBlock? next})
      : this._(kind: CurrentStudyStatusKind.resting, nextBlock: next);
}

/// Fetches (never generates) the current week's saved plan. Deliberately
/// independent of lib/weekly_plan/weekly_plan_controller.dart's own state -
/// that controller's `viewedWeekStart`/`selectedDayKey` reflect whatever
/// week/day the Study Plan screen's UI last navigated to, which would give
/// the wrong "right now" answer here if reused directly. If nothing has
/// been generated yet for this week, this resolves to null rather than
/// triggering generation - kicking off generation stays the Study Plan
/// screen's job, not this read-only Home card's.
final homeWeeklyPlanProvider = FutureProvider.autoDispose<WeeklyStudyPlan?>((
  ref,
) {
  final monday = _mondayOf(DateTime.now());
  return WeeklyPlanService.instance.fetchPlan(weekStartDate: monday);
});

/// Ticks once immediately and then every 30 seconds, purely to trigger
/// [currentStudyStatusProvider] to re-derive status as time passes - it
/// carries no data of its own beyond "now changed".
Stream<DateTime> _clock() async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(seconds: 30), (_) => DateTime.now());
}

final deviceClockProvider = StreamProvider.autoDispose<DateTime>((ref) => _clock());

final currentStudyStatusProvider = Provider.autoDispose<CurrentStudyStatus>((
  ref,
) {
  final now = ref.watch(deviceClockProvider).valueOrNull ?? DateTime.now();
  final planAsync = ref.watch(homeWeeklyPlanProvider);

  return planAsync.when(
    data: (plan) => _deriveStatus(plan, now),
    loading: () => const CurrentStudyStatus.loading(),
    error: (_, _) => const CurrentStudyStatus.noPlan(),
  );
});

CurrentStudyStatus _deriveStatus(WeeklyStudyPlan? plan, DateTime now) {
  if (plan == null) return const CurrentStudyStatus.noPlan();

  final todayKey = WeeklyStudyPlan.weekdayKeys[now.weekday - DateTime.monday];
  final blocks = plan.blocksFor(todayKey); // already sorted by start time
  final nowMinutes = now.hour * 60 + now.minute;

  for (final block in blocks) {
    final endMinutes = block.end.hour * 60 + block.end.minute;
    if (nowMinutes >= block.startMinutes && nowMinutes < endMinutes) {
      return CurrentStudyStatus.studying(block);
    }
  }

  StudyBlock? next;
  for (final block in blocks) {
    if (block.startMinutes > nowMinutes) {
      next = block;
      break;
    }
  }
  return CurrentStudyStatus.resting(next: next);
}

DateTime _mondayOf(DateTime date) {
  final midnight = DateTime(date.year, date.month, date.day);
  return midnight.subtract(Duration(days: midnight.weekday - DateTime.monday));
}
