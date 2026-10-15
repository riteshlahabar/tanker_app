import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../shared/models/order.dart';
import 'customer_order_providers.dart';

part 'place_order_controller.g.dart';

class PlaceOrderState {
  const PlaceOrderState({this.submitting = false, this.failure, this.placedOrder});

  final bool submitting;
  final Failure? failure;
  final Order? placedOrder;
}

@riverpod
class PlaceOrderController extends _$PlaceOrderController {
  @override
  PlaceOrderState build() => const PlaceOrderState();

  Future<void> submit({
    required String deliveryAddress,
    required DateTime deliveryDate,
    int? deliverySlotId,
    int? quantityLitres,
    String? notes,
  }) async {
    state = const PlaceOrderState(submitting: true);

    final result = await ref.read(customerOrderRepositoryProvider).place(
          deliveryAddress: deliveryAddress,
          deliveryDate: deliveryDate,
          deliverySlotId: deliverySlotId,
          quantityLitres: quantityLitres,
          notes: notes,
        );

    state = result.when(
      success: (order) => PlaceOrderState(placedOrder: order),
      error: (failure) => PlaceOrderState(failure: failure),
    );
  }

  /// So the form can be used again after a successful order without the
  /// screen staying on a "placed" state when the customer navigates back.
  void reset() => state = const PlaceOrderState();
}
