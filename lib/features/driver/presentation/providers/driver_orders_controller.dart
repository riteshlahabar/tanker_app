import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/providers/first_load.dart';
import '../../../../shared/models/order.dart';
import '../../../../shared/models/paginated.dart';
import 'driver_providers.dart';

part 'driver_orders_controller.g.dart';

class DriverOrdersState {
  const DriverOrdersState({
    this.paginated = const Paginated<Order>.empty(),
    this.loading = true,
    this.loadingMore = false,
    this.error,
  });

  final Paginated<Order> paginated;
  final bool loading;
  final bool loadingMore;
  final Failure? error;

  DriverOrdersState copyWith({
    Paginated<Order>? paginated,
    bool? loading,
    bool? loadingMore,
    Failure? error,
    bool clearError = false,
  }) =>
      DriverOrdersState(
        paginated: paginated ?? this.paginated,
        loading: loading ?? this.loading,
        loadingMore: loadingMore ?? this.loadingMore,
        error: clearError ? null : (error ?? this.error),
      );
}

/// One of these per tab (`openOnly: true` for Active, `false` for Delivered),
/// mirroring the customer's `MyOrdersController` but pointed at the driver's
/// own endpoint.
@riverpod
class DriverOrdersController extends _$DriverOrdersController {
  @override
  DriverOrdersState build(bool openOnly) {
    FirstLoad.after(ref, refresh);

    return const DriverOrdersState();
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true, clearError: true);

    final result = await ref.read(driverOrderRepositoryProvider).list(openOnly: openOnly, page: 1);

    state = result.when(
      success: (page) => DriverOrdersState(paginated: page, loading: false),
      error: (failure) => state.copyWith(loading: false, error: failure),
    );
  }

  Future<void> loadMore() async {
    if (state.loadingMore || state.loading || !state.paginated.hasMore) return;

    state = state.copyWith(loadingMore: true, clearError: true);

    final result = await ref
        .read(driverOrderRepositoryProvider)
        .list(openOnly: openOnly, page: state.paginated.nextPage);

    state = result.when(
      success: (page) =>
          state.copyWith(paginated: state.paginated.merge(page), loadingMore: false),
      error: (failure) => state.copyWith(loadingMore: false, error: failure),
    );
  }
}
