import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/providers/first_load.dart';
import '../../domain/driver_salary.dart';
import 'driver_providers.dart';

part 'driver_salary_controller.g.dart';

class DriverSalaryState {
  const DriverSalaryState({
    this.salary,
    this.loading = true,
    this.error,
    this.from,
    this.to,
  });

  final DriverSalary? salary;
  final bool loading;
  final Failure? error;

  /// The range the next refresh will ask for; null means "this month" (the
  /// panel's own default).
  final DateTime? from;
  final DateTime? to;

  DriverSalaryState copyWith({
    DriverSalary? salary,
    bool? loading,
    Failure? error,
    DateTime? from,
    DateTime? to,
  }) =>
      DriverSalaryState(
        salary: salary ?? this.salary,
        loading: loading ?? this.loading,
        error: error,
        from: from ?? this.from,
        to: to ?? this.to,
      );
}

@riverpod
class DriverSalaryController extends _$DriverSalaryController {
  @override
  DriverSalaryState build() {
    // Never kick the first fetch off inside build() — reading state before it
    // returns throws, and an unawaited throw is swallowed silently.
    FirstLoad.after(ref, refresh);

    return const DriverSalaryState();
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true, error: null);

    final result = await ref.read(driverRepositoryProvider).salary(from: state.from, to: state.to);

    state = result.when(
      success: (salary) => state.copyWith(salary: salary, loading: false),
      error: (failure) => state.copyWith(loading: false, error: failure),
    );
  }

  Future<void> setRange(DateTime from, DateTime to) async {
    state = state.copyWith(from: from, to: to);
    await refresh();
  }
}
