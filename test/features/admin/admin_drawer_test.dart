import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/features/admin/presentation/widgets/admin_drawer.dart';
import 'package:tanker_app/features/auth/domain/auth_user.dart';
import 'package:tanker_app/features/auth/presentation/providers/session_controller.dart';
import 'package:tanker_app/features/auth/presentation/providers/session_state.dart';
import 'package:tanker_app/shared/models/user_role.dart';

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
  const owner = AuthUser(
    id: 1,
    firstName: 'Ritesh',
    lastName: 'Lahabar',
    fullName: 'Ritesh Lahabar',
    role: UserRole.admin,
    status: true,
    canSelfOrder: true,
    email: 'admin@gmail.com',
  );

  Future<void> pumpDrawer(WidgetTester tester, {double height = 640}) async {
    tester.view.physicalSize = Size(400, height);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sessionControllerProvider.overrideWith(() => _SignedInSession(owner))],
        child: const MaterialApp(home: Scaffold(drawer: AdminDrawer(), body: SizedBox())),
      ),
    );

    tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
    await tester.pumpAndSettle();
  }

  testWidgets('the header puts the name and email beside the avatar', (tester) async {
    await pumpDrawer(tester);

    expect(find.text('Ritesh Lahabar'), findsOneWidget);
    expect(find.text('admin@gmail.com'), findsOneWidget);

    // Beside, not below: the avatar's initials and the name share a row, so
    // their vertical centres line up rather than stacking.
    final avatar = tester.getCenter(find.text('RL'));
    final name = tester.getCenter(find.text('Ritesh Lahabar'));

    expect(name.dx, greaterThan(avatar.dx));
    expect((name.dy - avatar.dy).abs(), lessThan(24));
  });

  testWidgets('the header stays short enough to leave the menu visible', (tester) async {
    await pumpDrawer(tester);

    // UserAccountsDrawerHeader ran to ~160px and pushed the last rows off a
    // short phone. The strip that replaced it must stay well under that.
    final header = tester.getRect(find.byType(CircleAvatar).first);
    final firstRow = tester.getRect(find.text('Tankers'));

    expect(firstRow.top, lessThan(110));
    expect(header.height, lessThanOrEqualTo(48));
  });

  testWidgets('every section the owner needs is reachable, Driver Expenses included',
      (tester) async {
    await pumpDrawer(tester, height: 900);

    for (final label in [
      'Tankers',
      'Drivers',
      'Customers',
      'Filling Points',
      'Standing Orders',
      'Delivery Slots',
      'Driver Expenses',
      'Settings',
    ]) {
      expect(find.text(label), findsOneWidget, reason: '$label is missing from the drawer');
    }
  });
}
