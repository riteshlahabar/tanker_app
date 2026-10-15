import '../../../core/network/api_result.dart';
import '../../../shared/models/paginated.dart';
import 'admin_delivery_slot.dart';
import 'entity_list_filter.dart';

/// Talks to `/api/admin/delivery-slots/*`.
abstract interface class AdminDeliverySlotRepository {
  Future<ApiResult<Paginated<AdminDeliverySlot>>> list(EntityListFilter filter, {int page = 1});

  Future<ApiResult<AdminDeliverySlot>> create(Map<String, dynamic> fields);

  Future<ApiResult<AdminDeliverySlot>> update(int id, Map<String, dynamic> fields);

  Future<ApiResult<String>> delete(int id);
}
