import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/my_schedule.dart';
import 'customer_schedule_providers.dart';

part 'my_schedule_controller.g.dart';

class MyScheduleState {
  const MyScheduleState({this.data, this.loading = true, this.error, this.busyDate});

  final MySchedule? data;
  final bool loading;
  final Failure? error;

  /// The one date currently being skipped or restored, so only that row
  /// shows a spinner rather than the whole list.
  final DateTime? busyDate;

  MyScheduleState copyWith({
    MySchedule? data,
    bool? loading,
    Failure? error,
    DateTime? busyDate,
    bool clearBusyDate = false,
  }) =>
      MyScheduleState(
        data: data ?? this.data,
        loading: loading ?? this.loading,
        error: error,
        busyDate: clearBusyDate ? null : (busyDate ?? this.busyDate),
      );
}

/// Backs both the Home schedule card and the My Deliveries screen, so a skip
/// made on one is reflected on the other without a second fetch.
@riverpod
class MyScheduleController extends _$MyScheduleController {
  @override
  MyScheduleState build() {
    unawaited(refresh());

    return const MyScheduleState();
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true, error: null);

    final result = await ref.read(customerScheduleRepositoryProvider).mySchedule();

    state = result.when(
      success: (data) => MyScheduleState(data: data, loading: false),
      error: (failure) => state.copyWith(loading: false, error: failure),
    );
  }

  /// Returns the panel's own message either way, for a snackbar.
  Future<String?> skip(DateTime date, String? reason) async {
    state = state.copyWith(busyDate: date);

    final result = await ref.read(customerScheduleRepositoryProvider).skip(date, reason);
    await refresh();
    state = state.copyWith(clearBusyDate: true);

    return result.when(success: (message) => message, error: (failure) => failure.message);
  }

  Future<String?> restore(DateTime date) async {
    state = state.copyWith(busyDate: date);

    final result = await ref.read(customerScheduleRepositoryProvider).restore(date);
    await refresh();
    state = state.copyWith(clearBusyDate: true);

    return result.when(success: (message) => message, error: (failure) => failure.message);
  }
}
