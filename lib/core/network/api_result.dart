import '../errors/failure.dart';

/// The result of a call: the value, or why there isn't one. Sealed, so the
/// compiler makes the UI handle both — there is no "null means error" guessing.
sealed class ApiResult<T> {
  const ApiResult();

  bool get isSuccess => this is Success<T>;

  T? get valueOrNull => this is Success<T> ? (this as Success<T>).value : null;

  Failure? get failureOrNull => this is Error<T> ? (this as Error<T>).failure : null;

  /// Fold both arms into one value — what a widget's `build` wants.
  R when<R>({
    required R Function(T value) success,
    required R Function(Failure failure) error,
  }) {
    final self = this;

    return switch (self) {
      Success<T>() => success(self.value),
      Error<T>() => error(self.failure),
    };
  }

  /// Re-wrap the value, keeping a failure untouched.
  ApiResult<R> map<R>(R Function(T value) transform) {
    final self = this;

    return switch (self) {
      Success<T>() => Success<R>(transform(self.value)),
      Error<T>() => Error<R>(self.failure),
    };
  }
}

final class Success<T> extends ApiResult<T> {
  const Success(this.value);

  final T value;
}

final class Error<T> extends ApiResult<T> {
  const Error(this.failure);

  final Failure failure;
}
