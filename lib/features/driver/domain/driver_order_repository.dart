import '../../../core/network/api_result.dart';
import '../../../shared/models/order.dart';
import '../../../shared/models/paginated.dart';

/// Talks to `/api/driver/orders/*`.
abstract interface class DriverOrderRepository {
  Future<ApiResult<Paginated<Order>>> list({required bool openOnly, int page = 1});

  Future<ApiResult<Order>> show(int orderId);

  /// A job the driver was given on the route. Placed **and assigned to them**
  /// server-side in one step — there is no driver argument, because
  /// `DriverPlaceOrderRequest` takes it from the token and would ignore one.
  Future<ApiResult<Order>> place({
    required int customerId,
    required String deliveryAddress,
    required DateTime deliveryDate,
    int? deliverySlotId,
    int? spotId,
    int? tankerCount,
    double? tankerRate,
    String? notes,
  });

  Future<ApiResult<Order>> startRefill(int orderId, {int? spotId, String? note});

  Future<ApiResult<Order>> markOutForDelivery(int orderId);

  Future<ApiResult<Order>> markDelivered(int orderId, {String? note});
}
