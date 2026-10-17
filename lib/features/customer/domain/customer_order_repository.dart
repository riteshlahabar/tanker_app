import '../../../core/network/api_result.dart';
import '../../../shared/models/order.dart';
import '../../../shared/models/paginated.dart';

/// Talks to `/api/customer/orders/*`. A screen depends on this interface, not
/// the Dio implementation, so it can be driven by a fake in tests.
abstract interface class CustomerOrderRepository {
  /// `openOnly: true` is the Ongoing tab; `false` is History (everything).
  Future<ApiResult<Paginated<Order>>> list({required bool openOnly, int page = 1});

  Future<ApiResult<Order>> show(int orderId);

  Future<ApiResult<Order>> place({
    required String deliveryAddress,
    required DateTime deliveryDate,
    int? deliverySlotId,
    int? tankerCount,
    String? notes,
  });

  Future<ApiResult<Order>> cancel(int orderId, String reason);
}
