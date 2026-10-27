import '../../shared/models/customer_option.dart';
import '../network/api_client.dart';
import '../network/api_result.dart';

/// Search-as-you-type over customers, for whichever role is writing an order.
///
/// Two endpoints answer the same shape, so this is one interface rather than a
/// repository per role:
///
/// * `/api/admin/customers` — the admin's full customer list;
/// * `/api/driver/customers` — the same search, gated on `customer.lookup`,
///   answering with the narrow `CustomerLookupResource` and leaving out
///   deactivated customers.
///
/// Which one a session talks to is decided once, in
/// `customerLookupRepositoryProvider`, from the signed-in role — not by each
/// screen, or the driver's form would end up calling an admin endpoint and
/// getting a 403 that looks like a bug in the picker.
abstract interface class CustomerLookupRepository {
  Future<ApiResult<List<CustomerOption>>> search(String query);
}

/// One implementation for both, differing only in the path it is given.
class CustomerLookupRepositoryImpl implements CustomerLookupRepository {
  const CustomerLookupRepositoryImpl({required ApiClient client, required String path})
      : _client = client,
        _path = path;

  final ApiClient _client;

  /// `/admin/customers` or `/driver/customers`.
  final String _path;

  @override
  Future<ApiResult<List<CustomerOption>>> search(String query) async {
    final result = await _client.list<CustomerOption>(
      _path,
      query: {'per_page': 20, if (query.isNotEmpty) 'search': query},
      parse: CustomerOption.fromJson,
    );

    return result.map((page) => page.items);
  }
}
