import '../../../core/network/api_result.dart';
import '../../../shared/models/delivery_slot.dart';

/// Talks to `/api/delivery-slots` — the same windows the admin panel offers.
abstract interface class DeliverySlotRepository {
  Future<ApiResult<List<DeliverySlot>>> active();
}
