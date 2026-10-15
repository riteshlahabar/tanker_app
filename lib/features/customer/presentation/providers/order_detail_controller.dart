import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../shared/models/order.dart';
import 'customer_order_providers.dart';

part 'order_detail_controller.g.dart';

class OrderDetailState {
  const OrderDetailState({this.order, this.loading = true, this.error, this.cancelling = false});

  final Order? order;
  final bool loading;
  final Failure? error;
  final bool cancelling;

  OrderDetailState copyWith({Order? order, bool? loading, Failure? error, bool? cancelling}) =>
      OrderDetailState(
        order: order ?? this.order,
        loading: loading ?? this.loading,
        error: error,
        cancelling: cancelling ?? this.cancelling,
      );
}

@riverpod
class OrderDetailController extends _$OrderDetailController {
  @override
  OrderDetailState build(int orderId) {
    unawaited(refresh());

    return const OrderDetailState();
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true, error: null);

    final result = await ref.read(customerOrderRepositoryProvider).show(orderId);

    state = result.when(
      success: (order) => OrderDetailState(order: order, loading: false),
      error: (failure) => state.copyWith(loading: false, error: failure),
    );
  }

  /// Returns the panel's own message on success, so the screen can show it in
  /// a snackbar before popping.
  Future<String?> cancel(String reason) async {
    state = state.copyWith(cancelling: true, error: null);

    final result = await ref.read(customerOrderRepositoryProvider).cancel(orderId, reason);

    return result.when(
      success: (order) {
        state = OrderDetailState(order: order, loading: false);

        return 'Order cancelled.';
      },
      error: (failure) {
        state = state.copyWith(cancelling: false, error: failure);

        return null;
      },
    );
  }
}
