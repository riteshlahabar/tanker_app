import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../shared/models/delivery_slot.dart';
import '../../../shared/utils/json_read.dart';
import '../domain/delivery_slot_repository.dart';

class DeliverySlotRepositoryImpl implements DeliverySlotRepository {
  const DeliverySlotRepositoryImpl({required ApiClient client}) : _client = client;

  final ApiClient _client;

  @override
  Future<ApiResult<List<DeliverySlot>>> active() => _client.get<List<DeliverySlot>>(
        '/delivery-slots',
        parse: (data) => JsonRead.asMapList(data).map(DeliverySlot.fromJson).toList(),
      );
}
