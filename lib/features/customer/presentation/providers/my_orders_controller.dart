import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/providers/first_load.dart';
import '../../../../shared/models/order.dart';
import '../../../../shared/models/paginated.dart';
import 'customer_order_providers.dart';

part 'my_orders_controller.g.dart';

class OrdersListState {
  const OrdersListState({
    this.paginated = const Paginated<Order>.empty(),
    this.loading = true,
    this.loadingMore = false,
    this.error,
  });

  final Paginated<Order> paginated;
  final bool loading;
  final bool loadingMore;
  final Failure? error;

  OrdersListState copyWith({
    Paginated<Order>? paginated,
    bool? loading,
    bool? loadingMore,
    Failure? error,
    bool clearError = false,
  }) =>
      OrdersListState(
        paginated: paginated ?? this.paginated,
        loading: loading ?? this.loading,
        loadingMore: loadingMore ?? this.loadingMore,
        error: clearError ? null : (error ?? this.error),
      );
}

/// One of these per tab (`openOnly: true` for Ongoing, `false` for History) —
/// each keeps its own page cursor so switching tabs never re-fetches the
/// other's list.
@riverpod
class MyOrdersController extends _$MyOrdersController {
  @override
  OrdersListState build(bool openOnly) {
    FirstLoad.after(ref, refresh);

    return const OrdersListState();
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true, clearError: true);

    final result =
        await ref.read(customerOrderRepositoryProvider).list(openOnly: openOnly, page: 1);

    state = result.when(
      success: (page) => OrdersListState(paginated: page, loading: false),
      error: (failure) => state.copyWith(loading: false, error: failure),
    );
  }

  Future<void> loadMore() async {
    if (state.loadingMore || state.loading || !state.paginated.hasMore) return;

    state = state.copyWith(loadingMore: true, clearError: true);

    final result = await ref
        .read(customerOrderRepositoryProvider)
        .list(openOnly: openOnly, page: state.paginated.nextPage);

    state = result.when(
      success: (page) =>
          state.copyWith(paginated: state.paginated.merge(page), loadingMore: false),
      error: (failure) => state.copyWith(loadingMore: false, error: failure),
    );
  }
}
