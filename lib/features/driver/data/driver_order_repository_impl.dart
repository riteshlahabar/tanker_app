import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../shared/models/order.dart';
import '../../../shared/models/paginated.dart';
import '../../../shared/utils/json_read.dart';
import '../domain/driver_order_repository.dart';

class DriverOrderRepositoryImpl implements DriverOrderRepository {
  const DriverOrderRepositoryImpl({required ApiClient client}) : _client = client;

  final ApiClient _client;

  @override
  Future<ApiResult<Paginated<Order>>> list({required bool openOnly, int page = 1}) =>
      _client.list<Order>(
        '/driver/orders',
        query: {'page': page, if (openOnly) 'open_only': true},
        parse: Order.fromJson,
      );

  @override
  Future<ApiResult<Order>> show(int orderId) => _client.get<Order>(
        '/driver/orders/$orderId',
        parse: (data) => Order.fromJson(JsonRead.asMap(data)),
      );

  @override
  Future<ApiResult<Order>> startRefill(int orderId, {int? spotId, String? note}) => _client.post<Order>(
        '/driver/orders/$orderId/refill',
        body: {
          'spot_id': ?spotId,
          if (note != null && note.isNotEmpty) 'note': note,
        },
        parse: (data) => Order.fromJson(JsonRead.asMap(data)),
      );

  @override
  Future<ApiResult<Order>> markOutForDelivery(int orderId) => _client.post<Order>(
        '/driver/orders/$orderId/out-for-delivery',
        parse: (data) => Order.fromJson(JsonRead.asMap(data)),
      );

  @override
  Future<ApiResult<Order>> markDelivered(int orderId, {String? note}) => _client.post<Order>(
        '/driver/orders/$orderId/delivered',
        body: {if (note != null && note.isNotEmpty) 'note': note},
        parse: (data) => Order.fromJson(JsonRead.asMap(data)),
      );
}
