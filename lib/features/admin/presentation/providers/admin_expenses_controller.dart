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
    this.filter = const AdminExpenseFilter(),
    this.loading = true,
    this.loadingMore = false,
    this.error,
  });

  final Paginated<DriverExpense> paginated;
  final AdminExpenseFilter filter;
  final bool loading;
  final bool loadingMore;
  final Failure? error;

  AdminExpensesState copyWith({
    Paginated<DriverExpense>? paginated,
    AdminExpenseFilter? filter,
    bool? loading,
    bool? loadingMore,
    Failure? error,
    bool clearError = false,
  }) =>
      AdminExpensesState(
        paginated: paginated ?? this.paginated,
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

    final result = await ref
        .read(adminExpenseRepositoryProvider)
        .list(filter: state.filter, page: 1);

    state = result.when(
      success: (page) => state.copyWith(paginated: page, loading: false, clearError: true),
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
