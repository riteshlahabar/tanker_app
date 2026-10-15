import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_result.dart';
import '../../../../shared/models/order.dart';
import 'admin_providers.dart';

part 'admin_order_detail_controller.g.dart';

class AdminOrderDetailState {
  const AdminOrderDetailState({this.order, this.loading = true, this.error, this.acting = false});

  final Order? order;
  final bool loading;
  final Failure? error;
  final bool acting;

  AdminOrderDetailState copyWith({Order? order, bool? loading, Failure? error, bool? acting}) =>
      AdminOrderDetailState(
        order: order ?? this.order,
        loading: loading ?? this.loading,
        error: error,
        acting: acting ?? this.acting,
      );
}

@riverpod
class AdminOrderDetailController extends _$AdminOrderDetailController {
  @override
  AdminOrderDetailState build(int orderId) {
    unawaited(refresh());

    return const AdminOrderDetailState();
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true, error: null);

    final result = await ref.read(adminOrderRepositoryProvider).show(orderId);

    state = result.when(
      success: (order) => AdminOrderDetailState(order: order, loading: false),
      error: (failure) => state.copyWith(loading: false, error: failure),
    );
  }

  Future<String?> assign({required int driverId, int? spotId}) =>
      _act(() => ref.read(adminOrderRepositoryProvider).assign(orderId, driverId: driverId, spotId: spotId));

  Future<String?> cancel(String reason) =>
      _act(() => ref.read(adminOrderRepositoryProvider).cancel(orderId, reason));

  Future<String?> _act(Future<ApiResult<Order>> Function() call) async {
    state = state.copyWith(acting: true, error: null);

    final result = await call();

    return result.when(
      success: (order) {
        state = AdminOrderDetailState(order: order, loading: false);

        return null;
      },
      error: (failure) {
        state = state.copyWith(acting: false, error: failure);

        return failure.message;
      },
    );
  }
}
