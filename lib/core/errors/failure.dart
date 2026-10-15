/// Every way a call can fail, as data rather than an exception thrown across
/// layers. A repository returns one of these; the UI switches on it.
sealed class Failure {
  const Failure(this.message);

  final String message;
}

/// The server answered, but refused: `success: false`, reason in `message`.
/// This is the 400 the API returns when a business rule says no.
final class BusinessFailure extends Failure {
  const BusinessFailure(super.message);
}

/// 422 — the fields the server rejected, keyed by field name.
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message, this.errors);

  final Map<String, List<String>> errors;

  /// The first complaint about one field, for an inline form error.
  String? forField(String field) => errors[field]?.firstOrNull;
}

/// 401 — no token, a bad one, or a refresh that could not be rescued.
final class UnauthorisedFailure extends Failure {
  const UnauthorisedFailure([super.message = 'Please sign in again.']);
}

/// 403 — wrong role, or someone else's record.
final class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = 'This action is not allowed.']);
}

/// 404 — unknown id.
final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found.']);
}

/// No usable connection, or the request timed out.
final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

/// 5xx, or a response we could not parse.
final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong. Please try again.']);
}
