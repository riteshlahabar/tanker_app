import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../shared/models/order.dart';
import 'driver_providers.dart';

part 'driver_new_order_controller.g.dart';

class DriverNewOrderState {
  const DriverNewOrderState({this.submitting = false, this.failure, this.placedOrder});

  final bool submitting;
  final Failure? failure;
  final Order? placedOrder;
}

/// Backs the driver's "New Order" tab — a job taken on the route.
///
/// Mirrors `NewOrderController`, the admin's, with **no `driverId` argument**:
/// the order always goes to the driver holding the token, decided server-side
/// in `DriverPlaceOrderRequest`. There is nothing for this controller to pass
/// and nothing a screen could get wrong.
///
/// The amount is not a field either. The rate of the driver's own tanker fills
/// itself in from `driverSummaryControllerProvider` and `rate × tankers` is the
/// total; only a rate typed over the vehicle's becomes an override.
@riverpod
class DriverNewOrderController extends _$DriverNewOrderController {
  @override
  DriverNewOrderState build() => const DriverNewOrderState();

  Future<void> submit({
    required int customerId,
    required String deliveryAddress,
    required DateTime deliveryDate,
    int? deliverySlotId,
    int? spotId,
    int? tankerCount,
    double? tankerRate,
    String? notes,
  }) async {
    state = const DriverNewOrderState(submitting: true);

    final result = await ref.read(driverOrderRepositoryProvider).place(
          customerId: customerId,
          deliveryAddress: deliveryAddress,
          deliveryDate: deliveryDate,
          deliverySlotId: deliverySlotId,
          spotId: spotId,
          tankerCount: tankerCount,
          tankerRate: tankerRate,
          notes: notes,
        );

    state = result.when(
      success: (order) => DriverNewOrderState(placedOrder: order),
      error: (failure) => DriverNewOrderState(failure: failure),
    );
  }

  void reset() => state = const DriverNewOrderState();
}
