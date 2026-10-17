import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/providers/first_load.dart';
import '../../domain/admin_schedule_detail.dart';
import 'admin_providers.dart';

part 'admin_schedule_detail_controller.g.dart';

class AdminScheduleDetailState {
  const AdminScheduleDetailState({
    this.detail,
    this.loading = true,
    this.error,
    this.busyDate,
  });

  final AdminScheduleDetail? detail;
  final bool loading;
  final Failure? error;

  /// The one upcoming date currently being skipped or restored.
  final DateTime? busyDate;

  AdminScheduleDetailState copyWith({
    AdminScheduleDetail? detail,
    bool? loading,
    Failure? error,
    DateTime? busyDate,
    bool clearBusyDate = false,
  }) =>
      AdminScheduleDetailState(
        detail: detail ?? this.detail,
        loading: loading ?? this.loading,
        error: error,
        busyDate: clearBusyDate ? null : (busyDate ?? this.busyDate),
      );
}

@riverpod
class AdminScheduleDetailController extends _$AdminScheduleDetailController {
  @override
  AdminScheduleDetailState build(int scheduleId) {
    FirstLoad.after(ref, refresh);

    return const AdminScheduleDetailState();
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true, error: null);

    final result = await ref.read(adminScheduleRepositoryProvider).show(scheduleId);

    state = result.when(
      success: (detail) => AdminScheduleDetailState(detail: detail, loading: false),
      error: (failure) => state.copyWith(loading: false, error: failure),
    );
  }

  Future<String?> skip(DateTime date, String? reason) async {
    state = state.copyWith(busyDate: date);

    final result = await ref.read(adminScheduleRepositoryProvider).skip(scheduleId, date, reason);
    await refresh();
    state = state.copyWith(clearBusyDate: true);

    return result.when(success: (message) => message, error: (failure) => failure.message);
  }

  Future<String?> restore(DateTime date) async {
    state = state.copyWith(busyDate: date);

    final result = await ref.read(adminScheduleRepositoryProvider).restore(scheduleId, date);
    await refresh();
    state = state.copyWith(clearBusyDate: true);

    return result.when(success: (message) => message, error: (failure) => failure.message);
  }
}
