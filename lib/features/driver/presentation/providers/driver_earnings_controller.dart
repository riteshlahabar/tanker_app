import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/driver_earnings.dart';
import 'driver_providers.dart';

part 'driver_earnings_controller.g.dart';

class DriverEarningsState {
  const DriverEarningsState({
    this.earnings,
    this.loading = true,
    this.error,
    this.from,
    this.to,
  });

  final DriverEarnings? earnings;
  final bool loading;
  final Failure? error;

  /// The range the next refresh will ask for; null means "this month" (the
  /// panel's own default).
  final DateTime? from;
  final DateTime? to;

  DriverEarningsState copyWith({
    DriverEarnings? earnings,
    bool? loading,
    Failure? error,
    DateTime? from,
    DateTime? to,
  }) =>
      DriverEarningsState(
        earnings: earnings ?? this.earnings,
        loading: loading ?? this.loading,
        error: error,
        from: from ?? this.from,
        to: to ?? this.to,
      );
}

@riverpod
class DriverEarningsController extends _$DriverEarningsController {
  @override
  DriverEarningsState build() {
    unawaited(refresh());

    return const DriverEarningsState();
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true, error: null);

    final result = await ref.read(driverRepositoryProvider).earnings(from: state.from, to: state.to);

    state = result.when(
      success: (earnings) => state.copyWith(earnings: earnings, loading: false),
      error: (failure) => state.copyWith(loading: false, error: failure),
    );
  }

  Future<void> setRange(DateTime from, DateTime to) async {
    state = state.copyWith(from: from, to: to);
    await refresh();
  }
}
