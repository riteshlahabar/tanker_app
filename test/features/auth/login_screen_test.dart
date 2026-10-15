import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/core/errors/failure.dart';
import 'package:tanker_app/core/network/api_result.dart';
import 'package:tanker_app/core/theme/app_theme.dart';
import 'package:tanker_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:tanker_app/features/auth/presentation/screens/login_screen.dart';
import 'package:tanker_app/shared/widgets/primary_button.dart';

import '../../support/fake_auth_repository.dart';

void main() {
  Future<void> pumpLogin(WidgetTester tester, FakeAuthRepository repository) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: AppThemeData.lightTheme,
          home: const LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the design heading and one field for either identifier',
      (tester) async {
    await pumpLogin(tester, FakeAuthRepository());

    expect(find.text('Login'), findsAtLeastNWidgets(1));
    expect(find.text('Mobile number or e-mail'), findsOneWidget);
    expect(find.text('Enter Password'), findsOneWidget);
  });

  testWidgets('refuses to submit an empty form', (tester) async {
    final repository = FakeAuthRepository();
    await pumpLogin(tester, repository);

    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();

    expect(repository.loginCalls, 0);
    expect(find.text('Enter your mobile or e-mail'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
  });

  testWidgets('sends a trimmed username and signs in', (tester) async {
    final repository = FakeAuthRepository();
    await pumpLogin(tester, repository);

    await tester.enterText(find.byType(TextFormField).first, '  9876543210 ');
    await tester.enterText(find.byType(TextFormField).last, '12345678');
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();

    expect(repository.loginCalls, 1);
    expect(repository.lastUsername, '9876543210');
  });

  testWidgets("shows the panel's own refusal message", (tester) async {
    final repository = FakeAuthRepository(
      loginResult: const Error(UnauthorisedFailure('These credentials do not match.')),
    );
    await pumpLogin(tester, repository);

    await tester.enterText(find.byType(TextFormField).first, '9876543210');
    await tester.enterText(find.byType(TextFormField).last, 'wrong-password');
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();

    expect(find.text('These credentials do not match.'), findsOneWidget);
  });

  testWidgets('puts a 422 complaint under the field it belongs to', (tester) async {
    final repository = FakeAuthRepository(
      loginResult: const Error(
        ValidationFailure('Validation failed.', {
          'username': ['The username field is required.'],
        }),
      ),
    );
    await pumpLogin(tester, repository);

    await tester.enterText(find.byType(TextFormField).first, '9876543210');
    await tester.enterText(find.byType(TextFormField).last, '12345678');
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();

    expect(find.text('The username field is required.'), findsOneWidget);
  });
}
