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

/// Backs the admin's "New Order" tab — a phone order written down by hand.
///
/// The amount is **not** a field: the admin picks the driver, the rate of the
/// tanker that driver holds fills itself in, and `rate × tankers` is the
/// total. Only a rate the admin types over becomes an override.
@riverpod
class NewOrderController extends _$NewOrderController {
  @override
  NewOrderState build() => const NewOrderState();

  Future<void> submit({
    required int customerId,
    required int driverId,
    required String deliveryAddress,
    required DateTime deliveryDate,
    int? spotId,
    double? tankerRate,
    int? deliverySlotId,
    int? tankerCount,
    String? notes,
  }) async {
    state = const NewOrderState(submitting: true);

    final result = await ref.read(adminOrderRepositoryProvider).create(
          customerId: customerId,
          driverId: driverId,
          deliveryAddress: deliveryAddress,
          deliveryDate: deliveryDate,
          spotId: spotId,
          tankerRate: tankerRate,
          deliverySlotId: deliverySlotId,
          tankerCount: tankerCount,
          notes: notes,
        );

    state = result.when(
      success: (order) => NewOrderState(placedOrder: order),
      error: (failure) => NewOrderState(failure: failure),
    );
  }

  void reset() => state = const NewOrderState();
}
