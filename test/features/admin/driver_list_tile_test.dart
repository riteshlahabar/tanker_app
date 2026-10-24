import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/features/admin/domain/admin_driver.dart';
import 'package:tanker_app/features/admin/presentation/widgets/driver_list_tile.dart';
import 'package:tanker_app/shared/models/tanker_info.dart';

/// The restyled Drivers card. What is asserted here is the *information* the
/// row now carries that the old `EntityListTile` subtitle could not — above
/// all the difference between a salary that is set and one still sitting at
/// zero, which is the figure the owner has to go and fill in.
void main() {
  AdminDriver driver({
    String fullName = 'Manoj Khedkar',
    String mobile = '9766697520',
    String? address,
    double monthlySalary = 15000,
    bool status = true,
    TankerInfo? tanker,
  }) =>
      AdminDriver(
        id: 1,
        firstName: fullName.split(' ').first,
        lastName: fullName.split(' ').last,
        fullName: fullName,
        mobile: mobile,
        address: address,
        monthlySalary: monthlySalary,
        status: status,
        tanker: tanker,
      );

  const tanker = TankerInfo(
    id: 3,
    label: 'Water Tanker 1 (MH12AB1234)',
    vehicleNumber: 'MH12AB1234',
  );

  Future<void> pump(WidgetTester tester, AdminDriver value, {double width = 320}) async {
    tester.view.physicalSize = Size(width, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DriverListTile(driver: value, onTap: () {}),
        ),
      ),
    );
  }

  testWidgets('the name leads and the mobile reads under it', (tester) async {
    await pump(tester, driver(address: 'Shivaji Nagar'));

    expect(tester.takeException(), isNull);
    expect(find.text('Manoj Khedkar'), findsOneWidget);
    expect(find.text('9766697520  ·  Shivaji Nagar'), findsOneWidget);
  });

  testWidgets('a driver with no address shows the mobile alone', (tester) async {
    await pump(tester, driver());

    expect(find.text('9766697520'), findsOneWidget);
  });

  testWidgets('the monthly salary is grouped Indian-style', (tester) async {
    await pump(tester, driver(monthlySalary: 120000));

    expect(find.text('₹ 1,20,000 / mo'), findsOneWidget);
  });

  testWidgets('a zero salary reads as not set, never as ₹ 0', (tester) async {
    await pump(tester, driver(monthlySalary: 0));

    expect(find.text('Salary not set'), findsOneWidget);
    expect(find.textContaining('₹ 0'), findsNothing);
  });

  testWidgets('a driver with no tanker is called out, not left blank', (tester) async {
    await pump(tester, driver());

    expect(find.text('No tanker assigned'), findsOneWidget);
  });

  testWidgets('an assigned tanker shows its label', (tester) async {
    await pump(tester, driver(tanker: tanker));

    expect(find.text('Water Tanker 1 (MH12AB1234)'), findsOneWidget);
    expect(find.text('No tanker assigned'), findsNothing);
  });

  testWidgets('inactive wears a pill and active wears none', (tester) async {
    await pump(tester, driver(status: false));
    expect(find.text('Inactive'), findsOneWidget);

    await pump(tester, driver());
    expect(find.text('Inactive'), findsNothing);
    expect(find.text('Active'), findsNothing);
  });

  testWidgets('a row with everything missing at once still lays out', (tester) async {
    await pump(tester, driver(address: '', monthlySalary: 0, status: false));

    expect(tester.takeException(), isNull);
    expect(find.text('Salary not set'), findsOneWidget);
    expect(find.text('No tanker assigned'), findsOneWidget);
  });

  testWidgets('a long name and a long tanker label do not overflow a narrow phone',
      (tester) async {
    await pump(
      tester,
      driver(
        fullName: 'Chandrashekhar Vishwanath Deshpande',
        address: 'Plot 14, Behind the water works, Shivaji Nagar, Pune 411005',
        tanker: const TankerInfo(
          id: 4,
          label: 'Municipal Water Tanker Number Four (MH14ZZ9999)',
          vehicleNumber: 'MH14ZZ9999',
        ),
      ),
      width: 320,
    );

    expect(tester.takeException(), isNull);
  });
}
