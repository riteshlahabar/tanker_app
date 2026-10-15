import '../../../core/network/api_result.dart';
import 'auth_session.dart';
import 'auth_user.dart';

/// What the auth feature needs from the outside world. The presentation layer
/// depends on this interface, never on the Dio implementation — so a provider
/// can be tested against a fake without a server.
abstract interface class AuthRepository {
  /// `username` is an email for the admin, a mobile number for a driver or
  /// customer; the panel works out which.
  Future<ApiResult<AuthSession>> login({
    required String username,
    required String password,
  });

  /// The signed-in account, re-read on startup to confirm the stored token is
  /// still good and the account is still active.
  Future<ApiResult<AuthUser>> me();

  /// Revokes this device's pair and clears local storage.
  Future<ApiResult<String>> logout();

  Future<ApiResult<String>> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  });

  /// Mobile, email, role and status are the admin's to change — only name
  /// and address are the account holder's own to edit.
  Future<ApiResult<AuthUser>> updateProfile({
    required String firstName,
    String? lastName,
    String? address,
  });
}
