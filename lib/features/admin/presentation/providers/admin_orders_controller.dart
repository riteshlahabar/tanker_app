import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../shared/models/order.dart';
import '../../../../shared/models/paginated.dart';
import '../../domain/admin_order_filter.dart';
import 'admin_providers.dart';

part 'admin_orders_controller.g.dart';

class AdminOrdersState {
  const AdminOrdersState({
    this.filter = const AdminOrderFilter(),
    this.paginated = const Paginated<Order>.empty(),
    this.loading = true,
    this.loadingMore = false,
    this.error,
  });

  final AdminOrderFilter filter;
  final Paginated<Order> paginated;
  final bool loading;
  final bool loadingMore;
  final Failure? error;

  AdminOrdersState copyWith({
    AdminOrderFilter? filter,
    Paginated<Order>? paginated,
    bool? loading,
    bool? loadingMore,
    Failure? error,
    bool clearError = false,
  }) =>
      AdminOrdersState(
        filter: filter ?? this.filter,
        paginated: paginated ?? this.paginated,
        loading: loading ?? this.loading,
        loadingMore: loadingMore ?? this.loadingMore,
        error: clearError ? null : (error ?? this.error),
      );
}

/// The admin's Orders list — same infinite-scroll shape as the customer's and
/// driver's own order lists, with a filter the admin can change at any time.
@riverpod
class AdminOrdersController extends _$AdminOrdersController {
  @override
  AdminOrdersState build() {
    unawaited(refresh());

    return const AdminOrdersState();
  }

  Future<void> setFilter(AdminOrderFilter filter) async {
    state = state.copyWith(filter: filter);
    await refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true, clearError: true);

    final result = await ref.read(adminOrderRepositoryProvider).list(state.filter, page: 1);

    state = result.when(
      success: (page) => state.copyWith(paginated: page, loading: false),
      error: (failure) => state.copyWith(loading: false, error: failure),
    );
  }

  Future<void> loadMore() async {
    if (state.loadingMore || state.loading || !state.paginated.hasMore) return;

    state = state.copyWith(loadingMore: true, clearError: true);

    final result = await ref
        .read(adminOrderRepositoryProvider)
        .list(state.filter, page: state.paginated.nextPage);

    state = result.when(
      success: (page) =>
          state.copyWith(paginated: state.paginated.merge(page), loadingMore: false),
      error: (failure) => state.copyWith(loadingMore: false, error: failure),
    );
  }
}
