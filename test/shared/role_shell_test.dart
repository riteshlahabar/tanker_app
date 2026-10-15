import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/core/theme/app_theme.dart';
import 'package:tanker_app/shared/models/nav_tab.dart';
import 'package:tanker_app/shared/widgets/app_bottom_nav.dart';
import 'package:tanker_app/shared/widgets/role_shell.dart';

/// The owner's navigation rules, pinned down: a bottom bar on every shell, an
/// app bar on every screen, a drawer on the admin shell only, and back on a
/// non-home tab returning to the home tab instead of leaving the app.
void main() {
  // Labels and titles are deliberately different strings: the bottom bar
  // builds a Text for a hidden label too, so a shared string would match twice
  // and the assertions would not be telling us what we think.
  const tabs = [
    NavTab(label: 'HomeTab', icon: Icons.home, title: 'Home Title', body: Text('home body')),
    NavTab(label: 'OrdersTab', icon: Icons.list, title: 'Orders Title', body: Text('orders body')),
  ];

  Finder appBarTitle(String text) => find.descendant(
        of: find.byType(AppBar),
        matching: find.text(text),
      );

  Future<void> pumpShell(WidgetTester tester, {Widget? drawer}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemeData.lightTheme,
        home: RoleShell(tabs: tabs, drawer: drawer),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('every shell has an app bar and a bottom bar', (tester) async {
    await pumpShell(tester);

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(AppBottomNav), findsOneWidget);
    expect(appBarTitle('Home Title'), findsOneWidget);
  });

  testWidgets('the app bar title follows the selected tab', (tester) async {
    await pumpShell(tester);

    await tester.tap(find.byIcon(Icons.list));
    await tester.pumpAndSettle();

    expect(appBarTitle('Orders Title'), findsOneWidget);
    expect(appBarTitle('Home Title'), findsNothing);
  });

  testWidgets('tab bodies stay alive across a switch', (tester) async {
    await pumpShell(tester);

    await tester.tap(find.byIcon(Icons.list));
    await tester.pumpAndSettle();

    // IndexedStack keeps both mounted, which is what preserves a tab's scroll
    // position and already-loaded list.
    expect(find.text('home body', skipOffstage: false), findsOneWidget);
    expect(find.text('orders body', skipOffstage: false), findsOneWidget);
  });

  testWidgets('back on a non-home tab returns to the home tab', (tester) async {
    await pumpShell(tester);

    await tester.tap(find.byIcon(Icons.list));
    await tester.pumpAndSettle();
    expect(appBarTitle('Orders Title'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(appBarTitle('Home Title'), findsOneWidget);
    expect(find.text('Leave the app?'), findsNothing);
  });

  testWidgets('back on the home tab asks before leaving', (tester) async {
    await pumpShell(tester);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Leave the app?'), findsOneWidget);

    await tester.tap(find.text('Stay'));
    await tester.pumpAndSettle();

    expect(find.text('Leave the app?'), findsNothing);
    expect(appBarTitle('Home Title'), findsOneWidget);
  });

  testWidgets('no drawer unless the shell is given one', (tester) async {
    await pumpShell(tester);
    expect(
      Scaffold.of(tester.element(find.byType(IndexedStack))).hasDrawer,
      isFalse,
      reason: 'driver and customer shells must have no drawer',
    );

    await pumpShell(tester, drawer: const Drawer(child: Text('admin menu')));
    expect(
      Scaffold.of(tester.element(find.byType(IndexedStack))).hasDrawer,
      isTrue,
      reason: 'the admin shell is the one that gets a drawer',
    );
  });
}
