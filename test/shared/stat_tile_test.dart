import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/core/theme/colors.dart';
import 'package:tanker_app/shared/widgets/stat_tile.dart';

/// The dashboard puts StatTile in a fixed-height grid cell, so anything that
/// does not fit is clipped rather than scrolled — a `childAspectRatio` too
/// tight for the content threw a RenderFlex overflow on a real phone.
///
/// The tile cannot be made to fit an arbitrarily short cell: the value plus a
/// one-line label needs roughly 66px whatever it does. So the contract tested
/// here is the grid's, not just the widget's.
void main() {
  /// Every tile the admin dashboard renders, with its real label and colour.
  const dashboardTiles = <StatTile>[
    StatTile(label: 'Orders today', value: '31', color: appColorPrimary, icon: Icons.receipt_outlined),
    StatTile(label: 'Pending', value: '3', color: statusPendingColor, icon: Icons.hourglass_empty),
    StatTile(
      label: 'Delivered today',
      value: '28',
      color: statusDeliveredColor,
      icon: Icons.check_circle_outline,
    ),
    StatTile(
      label: 'Tankers delivered',
      value: '34',
      color: statusDeliveredColor,
      icon: Icons.water_drop_outlined,
    ),
    StatTile(
      label: 'Scheduled tomorrow',
      value: '12',
      color: statusRefillingColor,
      icon: Icons.event_outlined,
    ),
    StatTile(
      label: 'Active customers',
      value: '128',
      color: appetitBrownColor,
      icon: Icons.people_outline,
    ),
  ];

  Future<void> pumpDashboardGrid(WidgetTester tester, double screenWidth) async {
    tester.view.physicalSize = Size(screenWidth, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 2,
              // Must match AdminDashboardScreen's _Grid — this is the number
              // that broke, and the reason this test exists.
              childAspectRatio: 1.95,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: dashboardTiles,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('the dashboard grid fits every tile on a narrow phone', (tester) async {
    await pumpDashboardGrid(tester, 320);

    expect(tester.takeException(), isNull);
    expect(find.text('Scheduled tomorrow'), findsOneWidget);
  });

  testWidgets('the dashboard grid fits on an ordinary phone too', (tester) async {
    await pumpDashboardGrid(tester, 411);

    expect(tester.takeException(), isNull);
  });

  testWidgets('a long money value shrinks rather than wrapping mid-number', (tester) async {
    // "₹ 1,20," on one line and "000" on the next reads as nonsense, so the
    // value scales down instead of wrapping.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 170,
              height: 70,
              child: StatTile(
                label: 'Revenue today',
                value: '₹ 12,34,567',
                color: appetitBrownColor,
                icon: Icons.currency_rupee,
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);

    final text = tester.widget<Text>(find.text('₹ 12,34,567'));
    expect(text.maxLines, 1);
  });

  testWidgets('a report total keeps its plain card and a two-line label', (tester) async {
    // No colour and no icon: the report screen shows a dozen of these at once,
    // where tinting every one would be noise. Its totals keys are wordy, so
    // the label gets two lines there.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Wrap(
            children: [
              SizedBox(
                width: 170,
                child: StatTile(
                  label: 'Salary per month (not for the range)',
                  value: '₹ 35,000.00',
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);

    final label = tester.widget<Text>(find.text('Salary per month (not for the range)'));
    expect(label.maxLines, 2);
    expect(label.overflow, TextOverflow.ellipsis);
  });

  testWidgets('it still sizes naturally where the height is unbounded', (tester) async {
    // The report screen lays these out in a Wrap, so the column must be
    // mainAxisSize.min or it would try to be infinitely tall.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Wrap(
            children: [
              SizedBox(
                width: 160,
                child: StatTile(label: 'Expenses in the range', value: '₹ 2,000.00'),
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Expenses in the range'), findsOneWidget);
  });
}
