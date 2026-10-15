import 'package:tanker_app/core/errors/failure.dart';
import 'package:tanker_app/core/network/api_result.dart';
import 'package:tanker_app/features/auth/domain/auth_repository.dart';
import 'package:tanker_app/features/auth/domain/auth_session.dart';
import 'package:tanker_app/features/auth/domain/auth_user.dart';
import 'package:tanker_app/shared/models/user_role.dart';

/// Stands in for the panel. Because the presentation layer depends on the
/// [AuthRepository] interface rather than the Dio implementation, a screen can
/// be driven without a server.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.loginResult, this.meResult});

  ApiResult<AuthSession>? loginResult;
  ApiResult<AuthUser>? meResult;

  int loginCalls = 0;
  String? lastUsername;

  static AuthUser userOf(UserRole role) => AuthUser(
        id: 1,
        firstName: 'Test',
        lastName: 'User',
        fullName: 'Test User',
        role: role,
        status: true,
        canSelfOrder: true,
        mobile: '9000000000',
      );

  static AuthSession sessionOf(UserRole role) => AuthSession(
        user: userOf(role),
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        expiresIn: 7200,
        abilities: const ['order:view'],
      );

  @override
  Future<ApiResult<AuthSession>> login({
    required String username,
    required String password,
  }) async {
    loginCalls++;
    lastUsername = username;

    return loginResult ?? Success(sessionOf(UserRole.customer));
  }

  @override
  Future<ApiResult<AuthUser>> me() async =>
      meResult ?? const Error(UnauthorisedFailure());

  @override
  Future<ApiResult<String>> logout() async => const Success('');

  @override
  Future<ApiResult<String>> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async =>
      const Success('');

  @override
  Future<ApiResult<AuthUser>> updateProfile({
    required String firstName,
    String? lastName,
    String? address,
  }) async =>
      Success(userOf(UserRole.customer));
}
