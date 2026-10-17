import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/core/theme/app_theme.dart';
import 'package:tanker_app/features/auth/domain/auth_user.dart';
import 'package:tanker_app/features/auth/presentation/providers/session_controller.dart';
import 'package:tanker_app/features/auth/presentation/providers/session_state.dart';
import 'package:tanker_app/shared/models/user_role.dart';
import 'package:tanker_app/shared/screens/account_profile_screen.dart';

/// Signs the tree in without touching secure storage or the panel.
class _SignedInSession extends SessionController {
  _SignedInSession(this.user);

  final AuthUser user;

  @override
  SessionState build() => SessionSignedIn(user);

  @override
  Future<void> refreshUser() async {}
}

void main() {
  AuthUser user({required UserRole role, double? monthlySalary}) => AuthUser(
        id: 1,
        firstName: 'Test',
        lastName: 'Person',
        fullName: 'Test Person',
        role: role,
        status: true,
        canSelfOrder: true,
        mobile: '9000000000',
        address: '12 Market Road',
        monthlySalary: monthlySalary,
      );

  Widget wrap(AuthUser signedIn) => ProviderScope(
        overrides: [
          sessionControllerProvider.overrideWith(() => _SignedInSession(signedIn)),
        ],
        child: MaterialApp(
          theme: AppThemeData.lightTheme,
          home: const Scaffold(body: AccountProfileScreen()),
        ),
      );

  testWidgets('a driver sees their monthly salary, read-only', (tester) async {
    await tester.pumpWidget(wrap(user(role: UserRole.driver, monthlySalary: 15000)));
    await tester.pump();

    expect(find.text('Monthly salary'), findsOneWidget);
    expect(find.text('₹ 15000'), findsOneWidget);
  });

  testWidgets('a customer sees no salary row at all, not a salary of zero', (tester) async {
    // Profile is one screen shared by all three roles, so the null the panel
    // sends for a non-driver is what keeps the row off their screen.
    await tester.pumpWidget(wrap(user(role: UserRole.customer)));
    await tester.pump();

    expect(find.text('Monthly salary'), findsNothing);
    expect(find.text('₹ 0'), findsNothing);
  });

  test('a salary that arrives as an int is still read as a double', () {
    // PHP's json_encode emits an integral float as 15000, not 15000.0.
    final driver = AuthUser.fromJson(const {
      'id': 1,
      'first_name': 'Ramesh',
      'last_name': '',
      'full_name': 'Ramesh',
      'role': 'driver',
      'status': true,
      'can_self_order': true,
      'monthly_salary': 15000,
    });

    expect(driver.monthlySalary, 15000.0);
  });

  test('a customer carries no salary, so the field stays null', () {
    final customer = AuthUser.fromJson(const {
      'id': 2,
      'first_name': 'Sunita',
      'last_name': '',
      'full_name': 'Sunita',
      'role': 'customer',
      'status': true,
      'can_self_order': true,
      'monthly_salary': null,
    });

    expect(customer.monthlySalary, isNull);
  });
}
