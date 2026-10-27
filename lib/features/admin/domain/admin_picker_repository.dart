import '../../../core/network/api_result.dart';
import 'driver_option.dart';

/// Talks to `/api/admin/drivers`, lightly — just the search-as-you-type driver
/// picker on the Assign, New Order and standing-order screens.
///
/// Customer search left here for `/api/driver/customers` to share: it moved to
/// `core/repositories/customer_lookup_repository.dart`, because the driver's
/// order form asks the same question of a different endpoint.
abstract interface class AdminPickerRepository {
  Future<ApiResult<List<DriverOption>>> searchDrivers(String query);
}
