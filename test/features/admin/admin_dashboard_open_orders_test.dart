import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/core/network/api_result.dart';
import 'package:tanker_app/features/admin/domain/admin_dashboard.dart';
import 'package:tanker_app/features/admin/domain/admin_dashboard_repository.dart';
import 'package:tanker_app/features/admin/presentation/providers/admin_providers.dart';
import 'package:tanker_app/features/admin/presentation/screens/admin_dashboard_screen.dart';

/// The owner's rule: a new order shows on the dashboard and leaves it once it
/// is delivered, while the Orders tab keeps every order.
///
/// The server decides that — the list it sends holds only open orders — so
/// what is tested here is that the screen renders whatever arrives, drops the
/// section when nothing is outstanding, and says when its list is capped.
class _FakeRepository implements AdminDashboardRepository {
  _FakeRepository(this.json);

  final Map<String, dynamic> json;

  @override
  Future<ApiResult<AdminDashboard>> summary() async =>
      Success(AdminDashboard.fromJson(json));
}

Map<String, dynamic> _payload({
  List<Map<String, dynamic>> openOrders = const [],
  int? openTotal,
}) =>
    <String, dynamic>{
      'tankers': 4,
      'drivers': 3,
      'customers': 20,
      'scheduled_tomorrow': 2,
      'orders_today': 6,
      'pending': 1,
      'delivered_today': 5,
      // Deliberately an int: PHP sends an integral float without its .0.
      'revenue_today': 12000,
      'tankers_delivered_today': 7,
      'open_orders': openOrders,
      'open_total': openTotal ?? openOrders.length,
    };

Map<String, dynamic> _order(int id, String orderNo, String status) => <String, dynamic>{
      'id': id,
      'order_no': orderNo,
      'status': status,
      'status_label': status,
      'is_open': true,
      'delivery_address': 'Kothrud, Pune',
      'order_amount': 1200,
      'customer_name': 'Rajesh Lahabar',
    };

void main() {
  Future<void> pump(WidgetTester tester, Map<String, dynamic> json) async {
    tester.view.physicalSize = const Size(411, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adminDashboardRepositoryProvider.overrideWithValue(_FakeRepository(json)),
        ],
        child: const MaterialApp(home: Scaffold(body: AdminDashboardScreen())),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('outstanding orders are listed under the counters', (tester) async {
    await pump(
      tester,
      _payload(openOrders: [
        _order(11, 'TNK-2026-00011', 'pending'),
        _order(12, 'TNK-2026-00012', 'out_for_delivery'),
      ]),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('ORDERS TO DELIVER'), findsOneWidget);
    expect(find.text('TNK-2026-00011  ·  Kothrud, Pune'), findsOneWidget);
    expect(find.text('TNK-2026-00012  ·  Kothrud, Pune'), findsOneWidget);
    // The counters still have to be there — the list was added beside them,
    // not instead of them.
    expect(find.text('Orders today'), findsOneWidget);
    expect(find.text('Revenue today'), findsOneWidget);
  });

  testWidgets('an empty list says so rather than showing a bare heading', (tester) async {
    await pump(tester, _payload());

    expect(tester.takeException(), isNull);
    expect(find.textContaining('Nothing outstanding'), findsOneWidget);
    // Nothing to see, so no point offering the jump to the Orders tab.
    expect(find.text('All orders'), findsNothing);
  });

  testWidgets('a capped list says how many are outstanding altogether', (tester) async {
    final orders = [
      for (var id = 1; id <= 10; id++) _order(id, 'TNK-2026-${id.toString().padLeft(5, '0')}', 'pending'),
    ];

    await pump(tester, _payload(openOrders: orders, openTotal: 23));

    expect(tester.takeException(), isNull);
    expect(find.text('Showing the latest 10 of 23 outstanding.'), findsOneWidget);
    expect(find.text('All orders'), findsOneWidget);
  });
}
