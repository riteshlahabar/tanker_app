import '../network/api_client.dart';
import '../network/api_result.dart';
import '../../shared/models/order.dart';
import '../../shared/utils/json_read.dart';
import 'order_alerts_repository.dart';

class OrderAlertsRepositoryImpl implements OrderAlertsRepository {
  const OrderAlertsRepositoryImpl({
    required ApiClient client,
    required String path,
  })  : _client = client,
        _path = path;

  final ApiClient _client;

  /// `/driver` or `/admin` — see `orderAlertsRepositoryProvider`.
  final String _path;

  @override
  Future<ApiResult<List<Order>>> pending() => _client.get<List<Order>>(
        '$_path/orders/alerts',
        // `{ items, count }`, not the usual `{ items, meta }`: the list is
        // capped rather than paged, so Paginated would have nothing to read.
        parse: (data) => JsonRead.asMapList(JsonRead.asMap(data)['items'])
            .map(Order.fromJson)
            .toList(growable: false),
      );

  @override
  Future<ApiResult<String>> markSeen(int orderId) =>
      _client.command('$_path/orders/$orderId/seen');
}
