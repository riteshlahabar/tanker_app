import 'package:tanker_app/shared/models/order.dart';

/// One order in the shape the panel's `OrderResource` sends, for a fake
/// repository to answer with.
Order fixtureOrder({int id = 3, String orderNo = 'TNK-2026-00003'}) =>
    Order.fromJson(<String, dynamic>{
      'id': id,
      'order_no': orderNo,
      'status': 'assigned',
      'status_label': 'Assigned',
      'is_open': true,
      'delivery_address': 'Test Address 12, Nagpur',
      // Deliberately an int: PHP sends an integral float without its .0.
      'order_amount': 0,
      // Water is sold by the tanker-load, so this is a count, not a volume.
      'tanker_count': 2,
    });
