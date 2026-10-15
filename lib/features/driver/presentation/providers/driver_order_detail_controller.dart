import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_result.dart';
import '../../../../shared/models/order.dart';
import 'driver_providers.dart';

part 'driver_order_detail_controller.g.dart';

class DriverOrderDetailState {
  const DriverOrderDetailState({this.order, this.loading = true, this.error, this.acting = false});

  final Order? order;
  final bool loading;
  final Failure? error;

  /// True while refill/out-for-delivery/delivered is in flight.
  final bool acting;

  DriverOrderDetailState copyWith({Order? order, bool? loading, Failure? error, bool? acting}) =>
      DriverOrderDetailState(
        order: order ?? this.order,
        loading: loading ?? this.loading,
        error: error,
        acting: acting ?? this.acting,
      );
}

/// Backs the driver's Order Detail screen — the order itself, plus the one
/// status-advance action that applies at its current status.
@riverpod
class DriverOrderDetailController extends _$DriverOrderDetailController {
  @override
  DriverOrderDetailState build(int orderId) {
    unawaited(refresh());

    return const DriverOrderDetailState();
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true, error: null);

    final result = await ref.read(driverOrderRepositoryProvider).show(orderId);

    state = result.when(
      success: (order) => DriverOrderDetailState(order: order, loading: false),
      error: (failure) => state.copyWith(loading: false, error: failure),
    );
  }

  Future<String?> startRefill({int? spotId, String? note}) =>
      _act(() => ref.read(driverOrderRepositoryProvider).startRefill(orderId, spotId: spotId, note: note));

  Future<String?> markOutForDelivery() =>
      _act(() => ref.read(driverOrderRepositoryProvider).markOutForDelivery(orderId));

  Future<String?> markDelivered({String? note}) =>
      _act(() => ref.read(driverOrderRepositoryProvider).markDelivered(orderId, note: note));

  /// Runs one status-advance call and returns a message for a snackbar either
  /// way — a refusal (wrong spot, disallowed move) reads as the driver's
  /// mistake to correct, not a crash.
  Future<String?> _act(Future<ApiResult<Order>> Function() call) async {
    state = state.copyWith(acting: true, error: null);

    final result = await call();

    return result.when(
      success: (order) {
        state = DriverOrderDetailState(order: order, loading: false);

        return null;
      },
      error: (failure) {
        state = state.copyWith(acting: false, error: failure);

        return failure.message;
      },
    );
  }
}
