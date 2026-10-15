import '../../../core/network/api_result.dart';
import '../../../shared/models/order.dart';
import '../../../shared/models/paginated.dart';

/// Talks to `/api/driver/orders/*`.
abstract interface class DriverOrderRepository {
  Future<ApiResult<Paginated<Order>>> list({required bool openOnly, int page = 1});

  Future<ApiResult<Order>> show(int orderId);

  Future<ApiResult<Order>> startRefill(int orderId, {int? spotId, String? note});

  Future<ApiResult<Order>> markOutForDelivery(int orderId);

  Future<ApiResult<Order>> markDelivered(int orderId, {String? note});
}
