import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/driver_summary.dart';
import 'driver_providers.dart';

part 'driver_summary_controller.g.dart';

class DriverSummaryState {
  const DriverSummaryState({this.summary, this.loading = true, this.error});

  final DriverSummary? summary;
  final bool loading;
  final Failure? error;
}

@riverpod
class DriverSummaryController extends _$DriverSummaryController {
  @override
  DriverSummaryState build() {
    unawaited(refresh());

    return const DriverSummaryState();
  }

  Future<void> refresh() async {
    state = const DriverSummaryState();

    final result = await ref.read(driverRepositoryProvider).summary();

    state = result.when(
      success: (summary) => DriverSummaryState(summary: summary, loading: false),
      error: (failure) => DriverSummaryState(loading: false, error: failure),
    );
  }
}
