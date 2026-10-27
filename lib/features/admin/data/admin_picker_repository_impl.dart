import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../domain/admin_picker_repository.dart';
import '../domain/driver_option.dart';

class AdminPickerRepositoryImpl implements AdminPickerRepository {
  const AdminPickerRepositoryImpl({required ApiClient client}) : _client = client;

  final ApiClient _client;

  @override
  Future<ApiResult<List<DriverOption>>> searchDrivers(String query) async {
    final result = await _client.list<DriverOption>(
      '/admin/drivers',
      query: {'per_page': 20, if (query.isNotEmpty) 'search': query},
      parse: DriverOption.fromJson,
    );

    return result.map((page) => page.items);
  }
}
