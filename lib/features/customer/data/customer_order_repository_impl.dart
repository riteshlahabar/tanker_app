import 'package:intl/intl.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../shared/models/order.dart';
import '../../../shared/models/paginated.dart';
import '../../../shared/utils/json_read.dart';
import '../domain/customer_order_repository.dart';

class CustomerOrderRepositoryImpl implements CustomerOrderRepository {
  const CustomerOrderRepositoryImpl({required ApiClient client}) : _client = client;

  final ApiClient _client;

  static final _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Future<ApiResult<Paginated<Order>>> list({required bool openOnly, int page = 1}) =>
      _client.list<Order>(
        '/customer/orders',
        query: {'page': page, if (openOnly) 'active_only': true},
        parse: Order.fromJson,
      );

  @override
  Future<ApiResult<Order>> show(int orderId) => _client.get<Order>(
        '/customer/orders/$orderId',
        parse: (data) => Order.fromJson(JsonRead.asMap(data)),
      );

  @override
  Future<ApiResult<Order>> place({
    required String deliveryAddress,
    required DateTime deliveryDate,
    int? deliverySlotId,
    int? quantityLitres,
    String? notes,
  }) =>
      _client.post<Order>(
        '/customer/orders',
        body: {
          'delivery_address': deliveryAddress,
          'delivery_date': _dateFormat.format(deliveryDate),
          'delivery_slot_id': ?deliverySlotId,
          'quantity_litres': ?quantityLitres,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
        parse: (data) => Order.fromJson(JsonRead.asMap(data)),
      );

  @override
  Future<ApiResult<Order>> cancel(int orderId, String reason) => _client.post<Order>(
        '/customer/orders/$orderId/cancel',
        body: {'cancel_reason': reason},
        parse: (data) => Order.fromJson(JsonRead.asMap(data)),
      );
}
