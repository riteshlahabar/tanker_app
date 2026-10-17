import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/providers/first_load.dart';
import '../../../../shared/models/paginated.dart';
import '../../../../shared/models/driver_expense.dart';
import 'driver_providers.dart';

part 'driver_expenses_controller.g.dart';

class DriverExpensesState {
  const DriverExpensesState({
    this.paginated = const Paginated<DriverExpense>.empty(),
    this.summary = ExpenseSummary.empty,
    this.loading = true,
    this.loadingMore = false,
    this.error,
  });

  final Paginated<DriverExpense> paginated;
  final ExpenseSummary summary;
  final bool loading;
  final bool loadingMore;
  final Failure? error;

  DriverExpensesState copyWith({
    Paginated<DriverExpense>? paginated,
    ExpenseSummary? summary,
    bool? loading,
    bool? loadingMore,
    Failure? error,
    bool clearError = false,
  }) =>
      DriverExpensesState(
        paginated: paginated ?? this.paginated,
        summary: summary ?? this.summary,
        loading: loading ?? this.loading,
        loadingMore: loadingMore ?? this.loadingMore,
        error: clearError ? null : (error ?? this.error),
      );
}

@riverpod
class DriverExpensesController extends _$DriverExpensesController {
  @override
  DriverExpensesState build() {
    // Never kick the first fetch off inside build() — reading state before it
    // returns throws, and an unawaited throw is swallowed silently.
    FirstLoad.after(ref, refresh);

    return const DriverExpensesState();
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true, clearError: true);

    final repository = ref.read(expenseRepositoryProvider);

    // The list and its totals header belong to one screen, so both are read
    // before anything is drawn — a half-refreshed screen would show rows that
    // disagree with the total above them.
    final listResult = await repository.list(page: 1);
    final summaryResult = await repository.summary();

    final summary = summaryResult.when(
      success: (value) => value,
      // The totals are a convenience; the list is the screen. A failed summary
      // keeps the last one rather than emptying the header.
      error: (_) => state.summary,
    );

    state = listResult.when(
      success: (page) => state.copyWith(
        paginated: page,
        summary: summary,
        loading: false,
        clearError: true,
      ),
      error: (failure) => state.copyWith(loading: false, error: failure),
    );
  }

  Future<void> loadMore() async {
    if (state.loadingMore || state.loading || !state.paginated.hasMore) return;

    state = state.copyWith(loadingMore: true, clearError: true);

    final result = await ref.read(expenseRepositoryProvider).list(page: state.paginated.nextPage);

    state = result.when(
      success: (page) => state.copyWith(
        paginated: state.paginated.merge(page),
        loadingMore: false,
      ),
      error: (failure) => state.copyWith(loadingMore: false, error: failure),
    );
  }
}
