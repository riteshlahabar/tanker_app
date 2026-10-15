import 'package:dio/dio.dart';

import '../../shared/models/paginated.dart';
import '../../shared/utils/json_read.dart';
import '../errors/error_mapper.dart';
import '../errors/failure.dart';
import 'api_result.dart';

/// The one place the app talks HTTP.
///
/// Every panel response is `{ success, message, data }`, so unwrapping that
/// envelope — and turning a refusal into a [Failure] — happens here once
/// instead of in every repository.
class ApiClient {
  const ApiClient(this._dio);

  final Dio _dio;

  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(Object? data) parse,
  }) =>
      _send(() => _dio.get<dynamic>(path, queryParameters: query), parse);

  Future<ApiResult<T>> post<T>(
    String path, {
    Object? body,
    required T Function(Object? data) parse,
  }) =>
      _send(() => _dio.post<dynamic>(path, data: body), parse);

  Future<ApiResult<T>> put<T>(
    String path, {
    Object? body,
    required T Function(Object? data) parse,
  }) =>
      _send(() => _dio.put<dynamic>(path, data: body), parse);

  Future<ApiResult<T>> delete<T>(
    String path, {
    Object? body,
    required T Function(Object? data) parse,
  }) =>
      _send(() => _dio.delete<dynamic>(path, data: body), parse);

  /// A paginated list — `parse` handles one row, the meta is read for us.
  Future<ApiResult<Paginated<T>>> list<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(Map<String, dynamic> row) parse,
  }) =>
      get<Paginated<T>>(
        path,
        query: query,
        parse: (data) => Paginated<T>.fromJson(JsonRead.asMap(data), parse),
      );

  /// A call whose body we do not need — just whether it worked.
  Future<ApiResult<String>> command(
    String path, {
    Object? body,
  }) =>
      _send(() => _dio.post<dynamic>(path, data: body), (_) => '');

  Future<ApiResult<T>> _send<T>(
    Future<Response<dynamic>> Function() request,
    T Function(Object? data) parse,
  ) async {
    try {
      final response = await request();
      final body = JsonRead.asMap(response.data);

      // A 2xx can still carry `success: false` when a rule refused the call.
      if (body.containsKey('success') && !JsonRead.asBool(body['success'])) {
        return Error<T>(BusinessFailure(
          JsonRead.asString(body['message'], fallback: 'That is not allowed right now.'),
        ));
      }

      return Success<T>(parse(body['data']));
    } on DioException catch (error) {
      return Error<T>(ErrorMapper.from(error));
    } catch (_) {
      // A shape we did not expect is a server problem, not a crash.
      return const Error(ServerFailure('We could not read the server\'s reply.'));
    }
  }

  /// The message the panel sent with a successful call, for a toast.
  static String messageOf(Response<dynamic> response) =>
      JsonRead.asString(JsonRead.asMap(response.data)['message']);
}
