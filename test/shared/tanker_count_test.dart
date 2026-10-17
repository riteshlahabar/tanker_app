import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/shared/models/order.dart';
import 'package:tanker_app/shared/widgets/tanker_count_field.dart';

import '../support/order_fixture.dart';

void main() {
  test('an order names its quantity in tankers, singular and plural', () {
    expect(fixtureOrder().tankerLabel, '2 tankers');

    final single = Order.fromJson(<String, dynamic>{
      'id': 1,
      'order_no': 'TNK-2026-00001',
      'status': 'pending',
      'status_label': 'Pending',
      'is_open': true,
      'delivery_address': 'Test Address',
      'order_amount': 0,
      'tanker_count': 1,
    });

    expect(single.tankerLabel, '1 tanker');
  });

  testWidgets('the tanker count is a picker, so a volume can never be typed', (tester) async {
    var chosen = 1;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TankerCountField(value: chosen, onChanged: (value) => chosen = value),
      ),
    ));

    expect(find.text('1 tanker'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('3 tankers').last);
    await tester.pumpAndSettle();

    expect(chosen, 3);
  });
}
