import '../../shared/models/customer_option.dart';
import '../../shared/models/paginated.dart';
import '../network/api_client.dart';
import '../network/api_result.dart';

/// The customer book, for whichever role is writing an order.
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
///
/// **A blank query is a browse, not a no-op.** The picker opens on the whole
/// list, so an admin or driver who does not remember a name can scroll to it;
/// typing only narrows what is already on screen.
abstract interface class CustomerLookupRepository {
  Future<ApiResult<Paginated<CustomerOption>>> search(String query);
}

/// One implementation for both, differing only in the path it is given.
class CustomerLookupRepositoryImpl implements CustomerLookupRepository {
  const CustomerLookupRepositoryImpl({required ApiClient client, required String path})
      : _client = client,
        _path = path;

  /// 100 is the API's own clamp on `per_page`, so a browse asks for as much of
  /// the book as the server will ever hand over in one page; a typed search is
  /// narrow by definition, and 20 keeps it quick. The page's `has_more`
  /// travels back with it so the field can admit when the list is not
  /// everybody.
  static const _browsePerPage = 100;
  static const _searchPerPage = 20;

  final ApiClient _client;

  /// `/admin/customers` or `/driver/customers`.
  final String _path;

  @override
  Future<ApiResult<Paginated<CustomerOption>>> search(String query) => _client.list<CustomerOption>(
        _path,
        query: {
          'per_page': query.isEmpty ? _browsePerPage : _searchPerPage,
          if (query.isNotEmpty) 'search': query,
        },
        parse: CustomerOption.fromJson,
      );
}
