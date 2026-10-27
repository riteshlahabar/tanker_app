import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/providers/first_load.dart';
import '../../../../shared/models/driver_expense.dart';
import '../../../../shared/models/paginated.dart';
import '../../domain/admin_expense_repository.dart';
import 'admin_providers.dart';

part 'admin_expenses_controller.g.dart';

class AdminExpensesState {
  const AdminExpensesState({
    this.paginated = const Paginated<DriverExpense>.empty(),
    this.summary,
    this.filter = const AdminExpenseFilter(),
    this.loading = true,
    this.loadingMore = false,
    this.error,
  });

  final Paginated<DriverExpense> paginated;

  /// Spending totals for this exact [filter] — fetched beside the first page,
  /// never derived from the rows in hand. A sum over one loaded page would
  /// understate the real figure the moment the list paginates, and a money
  /// total that quietly reads low is the one thing this screen must not do.
  ///
  /// **Null means not totalled**, not zero: the first load has not landed, or
  /// the summary call failed while the list succeeded. Either way the header
  /// says so rather than drawing a confident ₹ 0 — the same convention as an
  /// order's "Not priced yet". It is nullable precisely so a failed refresh
  /// cannot leave the previous filter's figure sitting over fresh rows.
  final AdminExpenseSummary? summary;

  final AdminExpenseFilter filter;
  final bool loading;
  final bool loadingMore;
  final Failure? error;

  AdminExpensesState copyWith({
    Paginated<DriverExpense>? paginated,
    AdminExpenseSummary? summary,
    AdminExpenseFilter? filter,
    bool? loading,
    bool? loadingMore,
    Failure? error,
    bool clearError = false,
    // Unlike the others this is *replaced*, not merged: a refresh that could
    // not total must drop the old figure, never keep it.
    bool replaceSummary = false,
  }) =>
      AdminExpensesState(
        paginated: paginated ?? this.paginated,
        summary: replaceSummary ? summary : (summary ?? this.summary),
        filter: filter ?? this.filter,
        loading: loading ?? this.loading,
        loadingMore: loadingMore ?? this.loadingMore,
        error: clearError ? null : (error ?? this.error),
      );

  /// Drives the "clear" affordance on the filter bar.
  bool get isFiltered =>
      filter.driverId != null ||
      filter.category != null ||
      filter.hasRange ||
      (filter.search?.isNotEmpty ?? false);
}

@riverpod
class AdminExpensesController extends _$AdminExpensesController {
  @override
  AdminExpensesState build() {
    // Never kick the first fetch off inside build() — reading state before it
    // returns throws, and an unawaited throw is swallowed silently.
    FirstLoad.after(ref, refresh);

    return const AdminExpensesState();
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true, clearError: true);

    final repository = ref.read(adminExpenseRepositoryProvider);
    final filter = state.filter;

    // Both at once: they are independent reads of the same filter, and running
    // them in sequence would show the list for a beat with last filter's total
    // still sitting above it.
    final (list, summary) = await (
      repository.list(filter: filter, page: 1),
      repository.summary(filter: filter),
    ).wait;

    state = list.when(
      success: (page) => state.copyWith(
        paginated: page,
        // A failed summary leaves the list perfectly usable, so it is not an
        // error for the screen — the header just says it could not total.
        summary: summary.valueOrNull,
        replaceSummary: true,
        loading: false,
        clearError: true,
      ),
      error: (failure) => state.copyWith(loading: false, error: failure),
    );
  }

  Future<void> setFilter(AdminExpenseFilter filter) async {
    state = state.copyWith(filter: filter);
    await refresh();
  }

  Future<void> loadMore() async {
    if (state.loadingMore || state.loading || !state.paginated.hasMore) return;

    state = state.copyWith(loadingMore: true, clearError: true);

    final result = await ref
        .read(adminExpenseRepositoryProvider)
        .list(filter: state.filter, page: state.paginated.nextPage);

    state = result.when(
      success: (page) => state.copyWith(
        paginated: state.paginated.merge(page),
        loadingMore: false,
      ),
      error: (failure) => state.copyWith(loadingMore: false, error: failure),
    );
  }
}
