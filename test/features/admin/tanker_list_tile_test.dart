import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/features/admin/domain/admin_tanker.dart';
import 'package:tanker_app/features/admin/presentation/widgets/tanker_list_tile.dart';

/// The Tankers list was restyled 2026-10-17. What is pinned here is the
/// information the card is *for* — the rate the owner still has to set, an
/// idle vehicle, and lapsed insurance — rather than its spacing.
AdminTanker tanker({
  double? rate,
  String? driver,
  bool status = true,
  DateTime? insuranceExpiry,
  int? capacity = 5000,
}) =>
    AdminTanker(
      id: 1,
      vehicleName: 'Water Tanker 1',
      vehicleNumber: 'MH12AB1234',
      label: 'Water Tanker 1 (MH12AB1234)',
      status: status,
      capacityLitres: capacity,
      tankerRate: rate,
      modelYear: 2019,
      currentDriver: driver,
      insuranceExpiry: insuranceExpiry,
    );

Future<void> pump(WidgetTester tester, AdminTanker value) async {
  tester.view.physicalSize = const Size(411, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: TankerListTile(tanker: value, onTap: () {}),
      ),
    ),
  );
}

void main() {
  testWidgets('the plate leads the row and the rate is shown per tanker', (tester) async {
    await pump(tester, tanker(rate: 1200, driver: 'Rajesh Lahabar'));

    expect(tester.takeException(), isNull);
    expect(find.text('MH12AB1234'), findsOneWidget);
    expect(find.text('₹ 1200 / tanker'), findsOneWidget);
    expect(find.text('Rajesh Lahabar'), findsOneWidget);
    // Litres are vehicle information, not price — they sit on the detail line.
    expect(find.text('Water Tanker 1  ·  5,000 L  ·  2019'), findsOneWidget);
  });

  testWidgets('a null rate says so rather than showing a confident zero', (tester) async {
    await pump(tester, tanker(driver: 'Rajesh Lahabar'));

    expect(find.text('Rate not set'), findsOneWidget);
    expect(find.textContaining('₹'), findsNothing);
  });

  testWidgets('a zero rate is treated the same as no rate', (tester) async {
    // The panel falls through to the Price per Tanker setting for both, so the
    // card must not claim a tanker costs nothing.
    await pump(tester, tanker(rate: 0));

    expect(find.text('Rate not set'), findsOneWidget);
    expect(find.text('₹ 0 / tanker'), findsNothing);
  });

  testWidgets('an idle tanker says no driver is assigned', (tester) async {
    await pump(tester, tanker(rate: 1200));

    expect(find.text('No driver assigned'), findsOneWidget);
  });

  testWidgets('an inactive tanker is badged', (tester) async {
    await pump(tester, tanker(rate: 1200, status: false));

    expect(find.text('Inactive'), findsOneWidget);
  });

  testWidgets('an active tanker carries no badge, only the green spine', (tester) async {
    await pump(tester, tanker(rate: 1200));

    expect(find.text('Inactive'), findsNothing);
    expect(find.text('Active'), findsNothing);
  });

  testWidgets('lapsed insurance earns a line of its own', (tester) async {
    await pump(
      tester,
      tanker(rate: 1200, insuranceExpiry: DateTime.now().subtract(const Duration(days: 40))),
    );

    expect(find.textContaining('Insurance expired'), findsOneWidget);
  });

  testWidgets('insurance expiring within a month warns, further out stays quiet', (tester) async {
    await pump(
      tester,
      tanker(rate: 1200, insuranceExpiry: DateTime.now().add(const Duration(days: 10))),
    );

    expect(find.textContaining('Insurance expires in 10 days'), findsOneWidget);

    await pump(
      tester,
      tanker(rate: 1200, insuranceExpiry: DateTime.now().add(const Duration(days: 200))),
    );

    // A year out is paperwork, not news — the row stays clean.
    expect(find.textContaining('Insurance'), findsNothing);
  });

  testWidgets('a tanker with no optional fields still renders', (tester) async {
    await pump(
      tester,
      const AdminTanker(
        id: 2,
        vehicleName: 'Spare',
        vehicleNumber: 'MH14ZZ9999',
        label: 'Spare (MH14ZZ9999)',
        status: true,
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Spare'), findsOneWidget);
    expect(find.text('Rate not set'), findsOneWidget);
  });
}
