import '../../shared/models/delivery_slot.dart';
import '../network/api_result.dart';

/// Talks to `/api/delivery-slots` — the same windows the admin panel offers.
/// Lives in `core/` rather than a feature, because more than one role reads
/// the same slot list (the customer's order form, the admin's New Order).
abstract interface class DeliverySlotRepository {
  Future<ApiResult<List<DeliverySlot>>> active();
}
