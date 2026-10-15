import '../../../core/network/api_result.dart';
import 'customer_option.dart';
import 'driver_option.dart';

/// Talks to `/api/admin/drivers` and `/api/admin/customers`, lightly — just
/// the search-as-you-type pickers on the Orders and New Order screens.
abstract interface class AdminPickerRepository {
  Future<ApiResult<List<DriverOption>>> searchDrivers(String query);

  Future<ApiResult<List<CustomerOption>>> searchCustomers(String query);
}
