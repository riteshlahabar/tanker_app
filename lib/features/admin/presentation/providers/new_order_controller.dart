import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../shared/models/order.dart';
import 'admin_providers.dart';

part 'new_order_controller.g.dart';

class NewOrderState {
  const NewOrderState({this.submitting = false, this.failure, this.placedOrder});

  final bool submitting;
  final Failure? failure;
  final Order? placedOrder;
}

/// Backs the admin's "New Order" tab — a phone order typed in by hand, so
/// (unlike the customer's own form) the amount is a field here, not
/// server-computed.
@riverpod
class NewOrderController extends _$NewOrderController {
  @override
  NewOrderState build() => const NewOrderState();

  Future<void> submit({
    required int customerId,
    required String deliveryAddress,
    required DateTime deliveryDate,
    required double orderAmount,
    double? latitude,
    double? longitude,
    int? deliverySlotId,
    int? quantityLitres,
    String? notes,
  }) async {
    state = const NewOrderState(submitting: true);

    final result = await ref.read(adminOrderRepositoryProvider).create(
          customerId: customerId,
          deliveryAddress: deliveryAddress,
          deliveryDate: deliveryDate,
          orderAmount: orderAmount,
          latitude: latitude,
          longitude: longitude,
          deliverySlotId: deliverySlotId,
          quantityLitres: quantityLitres,
          notes: notes,
        );

    state = result.when(
      success: (order) => NewOrderState(placedOrder: order),
      error: (failure) => NewOrderState(failure: failure),
    );
  }

  void reset() => state = const NewOrderState();
}
