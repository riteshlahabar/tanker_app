import 'package:intl/intl.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../shared/models/order.dart';
import '../../../shared/models/paginated.dart';
import '../../../shared/utils/json_read.dart';
import '../domain/admin_order_filter.dart';
import '../domain/admin_order_repository.dart';

class AdminOrderRepositoryImpl implements AdminOrderRepository {
  const AdminOrderRepositoryImpl({required ApiClient client}) : _client = client;

  final ApiClient _client;

  static final _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Future<ApiResult<Paginated<Order>>> list(AdminOrderFilter filter, {int page = 1}) =>
      _client.list<Order>(
        '/admin/orders',
        query: {
          'page': page,
          if (filter.search != null && filter.search!.isNotEmpty) 'search': filter.search,
          'status': ?filter.status?.value,
          'driver_id': ?filter.driverId,
          if (filter.from != null) 'from': _dateFormat.format(filter.from!),
          if (filter.to != null) 'to': _dateFormat.format(filter.to!),
        },
        parse: Order.fromJson,
      );

  @override
  Future<ApiResult<Order>> show(int orderId) => _client.get<Order>(
        '/admin/orders/$orderId',
        parse: (data) => Order.fromJson(JsonRead.asMap(data)),
      );

  @override
  Future<ApiResult<Order>> create({
    required int customerId,
    required String deliveryAddress,
    required DateTime deliveryDate,
    required double orderAmount,
    double? latitude,
    double? longitude,
    int? deliverySlotId,
    int? tankerCount,
    String? notes,
  }) =>
      _client.post<Order>(
        '/admin/orders',
        body: {
          'customer_id': customerId,
          'delivery_address': deliveryAddress,
          'delivery_date': _dateFormat.format(deliveryDate),
          'order_amount': orderAmount,
          'latitude': ?latitude,
          'longitude': ?longitude,
          'delivery_slot_id': ?deliverySlotId,
          'tanker_count': ?tankerCount,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
        parse: (data) => Order.fromJson(JsonRead.asMap(data)),
      );

  @override
  Future<ApiResult<Order>> assign(int orderId, {required int driverId, int? spotId}) =>
      _client.post<Order>(
        '/admin/orders/$orderId/assign',
        body: {
          'driver_id': driverId,
          'spot_id': ?spotId,
        },
        parse: (data) => Order.fromJson(JsonRead.asMap(data)),
      );

  @override
  Future<ApiResult<Order>> reassign(
    int orderId, {
    required int driverId,
    int? spotId,
    String? reason,
  }) =>
      _client.post<Order>(
        '/admin/orders/$orderId/reassign',
        body: {
          'driver_id': driverId,
          'spot_id': ?spotId,
          'reason': ?reason,
        },
        parse: (data) => Order.fromJson(JsonRead.asMap(data)),
      );

  @override
  Future<ApiResult<Order>> cancel(int orderId, String reason) => _client.post<Order>(
        '/admin/orders/$orderId/cancel',
        body: {'cancel_reason': reason},
        parse: (data) => Order.fromJson(JsonRead.asMap(data)),
      );
}
