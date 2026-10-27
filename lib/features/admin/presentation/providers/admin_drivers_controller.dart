import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/providers/first_load.dart';
import '../../../../shared/models/paginated.dart';
import '../../domain/admin_driver.dart';
import '../../domain/entity_list_filter.dart';
import 'admin_providers.dart';

part 'admin_drivers_controller.g.dart';

class AdminDriversState {
  const AdminDriversState({
    this.filter = const EntityListFilter(),
    this.paginated = const Paginated<AdminDriver>.empty(),
    this.loading = true,
    this.loadingMore = false,
    this.error,
  });

  final EntityListFilter filter;
  final Paginated<AdminDriver> paginated;
  final bool loading;
  final bool loadingMore;
  final Failure? error;

  AdminDriversState copyWith({
    EntityListFilter? filter,
    Paginated<AdminDriver>? paginated,
    bool? loading,
    bool? loadingMore,
    Failure? error,
    bool clearError = false,
  }) =>
      AdminDriversState(
        filter: filter ?? this.filter,
        paginated: paginated ?? this.paginated,
        loading: loading ?? this.loading,
        loadingMore: loadingMore ?? this.loadingMore,
        error: clearError ? null : (error ?? this.error),
      );
}

@riverpod
class AdminDriversController extends _$AdminDriversController {
  @override
  /// [initialStatus] opens the list already narrowed — the dashboard's
  /// "Active" counters do, so the list matches the figure that was tapped.
  /// It is a family argument rather than something set after mounting:
  /// Riverpod forbids modifying a provider from a widget lifecycle, and
  /// seeding it later races the opening load.
  AdminDriversState build({bool? initialStatus}) {
    FirstLoad.after(ref, refresh);

    return AdminDriversState(filter: EntityListFilter(status: initialStatus));
  }

  Future<void> setFilter(EntityListFilter filter) async {
    state = state.copyWith(filter: filter);
    await refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true, clearError: true);

    final result = await ref.read(adminDriverRepositoryProvider).list(state.filter, page: 1);

    state = result.when(
      success: (page) => state.copyWith(paginated: page, loading: false),
      error: (failure) => state.copyWith(loading: false, error: failure),
    );
  }

  Future<void> loadMore() async {
    if (state.loadingMore || state.loading || !state.paginated.hasMore) return;

    state = state.copyWith(loadingMore: true, clearError: true);

    final result = await ref
        .read(adminDriverRepositoryProvider)
        .list(state.filter, page: state.paginated.nextPage);

    state = result.when(
      success: (page) =>
          state.copyWith(paginated: state.paginated.merge(page), loadingMore: false),
      error: (failure) => state.copyWith(loadingMore: false, error: failure),
    );
  }
}
