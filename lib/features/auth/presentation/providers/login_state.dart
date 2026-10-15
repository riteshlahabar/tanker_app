import '../../../../core/errors/failure.dart';

/// What the login form is doing. Immutable; the controller swaps it whole.
class LoginState {
  const LoginState({
    this.submitting = false,
    this.failure,
    this.obscurePassword = true,
  });

  final bool submitting;

  /// The last refusal, kept so the screen can show the panel's own wording.
  final Failure? failure;

  final bool obscurePassword;

  /// The field-level complaint for a 422, so the error sits under the input it
  /// belongs to rather than in a toast.
  String? errorFor(String field) =>
      failure is ValidationFailure ? (failure as ValidationFailure).forField(field) : null;

  /// A refusal that belongs to the form as a whole — wrong password, inactive
  /// account, no connection.
  String? get generalError => failure is ValidationFailure ? null : failure?.message;

  LoginState copyWith({
    bool? submitting,
    Failure? failure,
    bool clearFailure = false,
    bool? obscurePassword,
  }) =>
      LoginState(
        submitting: submitting ?? this.submitting,
        failure: clearFailure ? null : (failure ?? this.failure),
        obscurePassword: obscurePassword ?? this.obscurePassword,
      );
}
