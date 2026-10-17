import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/core/providers/core_providers.dart';
import 'package:tanker_app/core/theme/app_theme.dart';
import 'package:tanker_app/features/auth/domain/auth_user.dart';
import 'package:tanker_app/features/auth/presentation/providers/session_controller.dart';
import 'package:tanker_app/features/auth/presentation/providers/session_state.dart';
import 'package:tanker_app/features/customer/presentation/screens/book_tanker_screen.dart';
import 'package:tanker_app/features/customer/presentation/screens/place_order_screen.dart';
import 'package:tanker_app/shared/models/delivery_slot.dart';
import 'package:tanker_app/shared/models/user_role.dart';

/// Signs the tree in without touching secure storage or the panel.
class _SignedInSession extends SessionController {
  _SignedInSession(this.user);

  final AuthUser user;

  @override
  SessionState build() => SessionSignedIn(user);

  /// The form re-reads the account on open, to pick up an address the admin
  /// added since sign-in. Stubbed out so a widget test never calls the panel.
  @override
  Future<void> refreshUser() async {}
}

void main() {
  AuthUser customer({bool canSelfOrder = true}) => AuthUser(
        id: 1,
        firstName: 'Test',
        lastName: 'Customer',
        fullName: 'Test Customer',
        role: UserRole.customer,
        status: true,
        canSelfOrder: canSelfOrder,
        mobile: '9000000000',
        address: '12 Market Road',
      );

  Widget wrap(Widget home, {bool canSelfOrder = true}) => ProviderScope(
        overrides: [
          sessionControllerProvider
              .overrideWith(() => _SignedInSession(customer(canSelfOrder: canSelfOrder))),
          deliverySlotOptionsProvider.overrideWith(
            (ref) async => const [
              DeliverySlot(
                id: 1,
                name: 'Morning',
                label: 'Morning (08:00 - 12:00)',
                startTime: '08:00',
                endTime: '12:00',
              ),
            ],
          ),
        ],
        child: MaterialApp(theme: AppThemeData.lightTheme, home: home),
      );

  testWidgets('the pushed Book a Tanker screen draws the form, Material and all',
      (tester) async {
    await tester.pumpWidget(
      wrap(
        Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const BookTankerScreen()),
              ),
              child: const Text('Book a Tanker'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Book a Tanker'));
    await tester.pumpAndSettle();

    // A pushed route has no Scaffold of its own unless the screen brings one,
    // and the form's fields throw "No Material widget found" without it.
    expect(tester.takeException(), isNull);
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Delivery address'), findsOneWidget);
    expect(find.text('Place Order'), findsOneWidget);
    // Defaulted to the address the admin entered for this customer.
    expect(find.text('12 Market Road'), findsOneWidget);
  });

  testWidgets('the Order tab body is the form alone, for the shell to wrap',
      (tester) async {
    await tester.pumpWidget(wrap(const Scaffold(body: PlaceOrderScreen())));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Delivery address'), findsOneWidget);
    expect(find.byType(AppBar), findsNothing);
  });

  testWidgets('a standing-order customer is told to ring the office instead',
      (tester) async {
    await tester.pumpWidget(wrap(const BookTankerScreen(), canSelfOrder: false));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Your deliveries are on a routine'), findsOneWidget);
    expect(find.text('Place Order'), findsNothing);
  });
}
