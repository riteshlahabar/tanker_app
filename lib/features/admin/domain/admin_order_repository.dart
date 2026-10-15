import '../../../core/network/api_result.dart';
import '../../../shared/models/order.dart';
import '../../../shared/models/paginated.dart';
import 'admin_order_filter.dart';

/// Talks to `/api/admin/orders/*`.
abstract interface class AdminOrderRepository {
  Future<ApiResult<Paginated<Order>>> list(AdminOrderFilter filter, {int page = 1});

  Future<ApiResult<Order>> show(int orderId);

  Future<ApiResult<Order>> create({
    required int customerId,
    required String deliveryAddress,
    required DateTime deliveryDate,
    required double orderAmount,
    double? latitude,
    double? longitude,
    int? deliverySlotId,
    int? quantityLitres,
    String? notes,
  });

  Future<ApiResult<Order>> assign(int orderId, {required int driverId, int? spotId});

  Future<ApiResult<Order>> cancel(int orderId, String reason);
}
