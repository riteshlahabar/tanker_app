import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/core/theme/app_theme.dart';
import 'package:tanker_app/shared/models/nav_tab.dart';
import 'package:tanker_app/shared/widgets/app_bottom_nav.dart';
import 'package:tanker_app/shared/widgets/role_shell.dart';
import 'package:tanker_app/shared/widgets/shell_tab_bar.dart';

/// The owner's rule: the bottom bar is on *every* screen, pushed detail
/// screens included — and tapping a tab there goes to that section rather
/// than opening a second copy of it on top of the stack.
void main() {
  /// Stands in for any pushed screen: its own app bar, and the shared bar.
  Widget detail(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Detail Title')),
        body: const Center(child: Text('detail body')),
        bottomNavigationBar: const ShellTabBar(),
      );

  late List<NavTab> tabs;

  setUp(() {
    tabs = [
      NavTab(
        label: 'HomeTab',
        icon: Icons.home,
        title: 'Home Title',
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: detail),
            ),
            child: const Text('open detail'),
          ),
        ),
      ),
      const NavTab(
        label: 'OrdersTab',
        icon: Icons.list,
        title: 'Orders Title',
        body: Text('orders body'),
      ),
    ];
  });

  Future<void> pumpAndPush(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppThemeData.lightTheme,
          home: RoleShell(tabs: tabs),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('open detail'));
    await tester.pumpAndSettle();
  }

  testWidgets('a pushed screen carries the bottom bar too', (tester) async {
    await pumpAndPush(tester);

    expect(find.text('detail body'), findsOneWidget);
    expect(find.byType(AppBottomNav), findsOneWidget);
  });

  testWidgets('tapping a tab from a pushed screen returns to the shell on that tab',
      (tester) async {
    await pumpAndPush(tester);

    await tester.tap(find.byIcon(Icons.list));
    await tester.pumpAndSettle();

    // Back on the shell — the pushed screen is gone, not buried under a tab.
    expect(find.text('detail body'), findsNothing);
    expect(find.text('orders body'), findsOneWidget);
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Orders Title')),
      findsOneWidget,
    );
  });
}
