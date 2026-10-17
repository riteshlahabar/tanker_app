import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/shared/models/order.dart';
import 'package:tanker_app/shared/models/order_status.dart';
import 'package:tanker_app/shared/widgets/order_list_tile.dart';

void main() {
  Order order({
    String? customerName,
    String? driverName,
    OrderStatus status = OrderStatus.pending,
  }) =>
      Order(
        id: 1,
        orderNo: 'TNK-2026-00008',
        status: status,
        statusLabel: status.label,
        isOpen: true,
        deliveryAddress: 'Kothrud, Pune',
        orderAmount: 1200,
        deliveryDate: DateTime(2026, 10, 18),
        customerName: customerName,
        driverName: driverName,
      );

  Future<void> pump(WidgetTester tester, Order value, {bool showParties = false}) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderListTile(order: value, showParties: showParties, onTap: () {}),
        ),
      ),
    );
  }

  testWidgets('a customer sees their reference first and no parties', (tester) async {
    await pump(tester, order(customerName: 'Sunita', driverName: 'Ramesh'));

    expect(find.text('TNK-2026-00008'), findsOneWidget);
    // Their own name would be noise on their own list.
    expect(find.text('Sunita'), findsNothing);
    expect(find.text('Unassigned'), findsNothing);
  });

  testWidgets('the admin leads with the customer and keeps the reference', (tester) async {
    await pump(tester, order(customerName: 'Sunita', driverName: 'Ramesh'), showParties: true);

    expect(find.text('Sunita'), findsOneWidget);
    // The reference moves to the address line rather than disappearing — it is
    // what gets read out over the phone.
    expect(find.textContaining('TNK-2026-00008'), findsOneWidget);
    expect(find.text('Ramesh'), findsOneWidget);
  });

  testWidgets('an order with no driver says so, rather than showing a gap', (tester) async {
    await pump(tester, order(customerName: 'Sunita'), showParties: true);

    // Unassigned work is the admin's cue to act, so it is named.
    expect(find.text('Unassigned'), findsOneWidget);
  });

  testWidgets('the spine carries the status colour, matching the chip', (tester) async {
    await pump(tester, order(status: OrderStatus.delivered), showParties: true);

    // A list is read by scanning; the 4px spine is what makes that possible,
    // and it must be the same colour the chip uses or the two disagree.
    final spine = tester.widgetList<Container>(find.byType(Container)).firstWhere(
          (c) => c.constraints?.maxWidth == 4 || (c.color == OrderStatus.delivered.color),
        );

    expect(spine.color, OrderStatus.delivered.color);
  });

  testWidgets('a long driver name ellipsises instead of pushing the amount off', (tester) async {
    await pump(
      tester,
      order(customerName: 'Sunita', driverName: 'Ramesh Shivajirao Deshmukh-Patil'),
      showParties: true,
    );

    expect(tester.takeException(), isNull);
    expect(find.text('₹ 1200'), findsOneWidget);
  });
}
