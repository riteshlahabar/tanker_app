import 'package:dio/dio.dart';

import '../../shared/utils/json_read.dart';
import 'failure.dart';

/// Turns a Dio exception into one of our [Failure]s, reading the reason the
/// panel gave rather than showing a raw status code.
///
/// The panel answers every call as `{ success, message, data }`, and on a 422
/// puts the field errors in `data.errors` — so the message a user sees is the
/// one the server wrote.
class ErrorMapper {
  const ErrorMapper._();

  static Failure from(Object error) {
    if (error is! DioException) return const ServerFailure();

    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const NetworkFailure('The server took too long to answer.'),
      DioExceptionType.connectionError => const NetworkFailure(),
      DioExceptionType.cancel => const NetworkFailure('Request cancelled.'),
      DioExceptionType.badCertificate => const NetworkFailure('The connection is not secure.'),
      DioExceptionType.badResponse => _fromResponse(error.response),
      DioExceptionType.transformTimeout => const NetworkFailure('The server took too long to answer.'),
      DioExceptionType.unknown => const ServerFailure(),
    };
  }

  static Failure _fromResponse(Response<dynamic>? response) {
    final body = JsonRead.asMap(response?.data);
    final message = JsonRead.asStringOrNull(body['message']);

    return switch (response?.statusCode) {
      400 => BusinessFailure(message ?? 'That is not allowed right now.'),
      401 => UnauthorisedFailure(message ?? 'Please sign in again.'),
      403 => ForbiddenFailure(message ?? 'This action is not allowed.'),
      404 => NotFoundFailure(message ?? 'Not found.'),
      422 => ValidationFailure(message ?? 'Please check the form.', _errors(body)),
      _ => ServerFailure(message ?? 'Something went wrong. Please try again.'),
    };
  }

  /// `data.errors` is `{ field: ["first complaint", ...] }`.
  static Map<String, List<String>> _errors(Map<String, dynamic> body) {
    final raw = JsonRead.asMap(JsonRead.asMap(body['data'])['errors']);

    return raw.map(
      (field, messages) => MapEntry(
        field,
        messages is List
            ? messages.map((m) => m.toString()).toList(growable: false)
            : <String>[messages.toString()],
      ),
    );
  }
}
