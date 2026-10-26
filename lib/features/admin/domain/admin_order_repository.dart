import '../../../core/network/api_result.dart';
import '../../../shared/models/order.dart';
import '../../../shared/models/paginated.dart';
import 'admin_order_filter.dart';

/// Talks to `/api/admin/orders/*`.
abstract interface class AdminOrderRepository {
  Future<ApiResult<Paginated<Order>>> list(AdminOrderFilter filter, {int page = 1});

  Future<ApiResult<Order>> show(int orderId);

  /// Places *and assigns* in one step, exactly as the panel's New Order form
  /// does: the driver is named here because the price of the order is the rate
  /// of the tanker they hold. There is no amount to send — the server works it
  /// out from `tankerRate × tankerCount`, and `tankerRate` is only passed when
  /// the admin typed over the vehicle's own.
  Future<ApiResult<Order>> create({
    required int customerId,
    required int driverId,
    required String deliveryAddress,
    required DateTime deliveryDate,
    int? spotId,
    double? tankerRate,
    int? deliverySlotId,
    int? tankerCount,
    String? notes,
  });

  Future<ApiResult<Order>> assign(int orderId, {required int driverId, int? spotId});

  /// Hand an already-assigned order to a different driver — the absent-driver
  /// case. The server refuses it once the tanker is being filled.
  Future<ApiResult<Order>> reassign(
    int orderId, {
    required int driverId,
    int? spotId,
    String? reason,
  });

  Future<ApiResult<Order>> cancel(int orderId, String reason);
}
