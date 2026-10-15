import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../shared/models/paginated.dart';
import '../../../shared/utils/json_read.dart';
import '../domain/admin_delivery_slot.dart';
import '../domain/admin_delivery_slot_repository.dart';
import '../domain/entity_list_filter.dart';

class AdminDeliverySlotRepositoryImpl implements AdminDeliverySlotRepository {
  const AdminDeliverySlotRepositoryImpl({required ApiClient client}) : _client = client;

  final ApiClient _client;

  @override
  Future<ApiResult<Paginated<AdminDeliverySlot>>> list(EntityListFilter filter, {int page = 1}) =>
      _client.list<AdminDeliverySlot>(
        '/admin/delivery-slots',
        query: {
          'page': page,
          if (filter.search != null && filter.search!.isNotEmpty) 'search': filter.search,
          'status': ?filter.status,
        },
        parse: AdminDeliverySlot.fromJson,
      );

  @override
  Future<ApiResult<AdminDeliverySlot>> create(Map<String, dynamic> fields) =>
      _client.post<AdminDeliverySlot>(
        '/admin/delivery-slots',
        body: fields,
        parse: (data) => AdminDeliverySlot.fromJson(JsonRead.asMap(data)),
      );

  @override
  Future<ApiResult<AdminDeliverySlot>> update(int id, Map<String, dynamic> fields) =>
      _client.put<AdminDeliverySlot>(
        '/admin/delivery-slots/$id',
        body: fields,
        parse: (data) => AdminDeliverySlot.fromJson(JsonRead.asMap(data)),
      );

  @override
  Future<ApiResult<String>> delete(int id) =>
      _client.delete<String>('/admin/delivery-slots/$id', parse: (_) => '');
}
