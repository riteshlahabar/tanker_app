import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/core/network/api_result.dart';
import 'package:tanker_app/core/providers/core_providers.dart';
import 'package:tanker_app/core/repositories/customer_lookup_repository.dart';
import 'package:tanker_app/features/driver/domain/driver_order_repository.dart';
import 'package:tanker_app/features/driver/domain/driver_repository.dart';
import 'package:tanker_app/features/driver/domain/driver_summary.dart';
import 'package:tanker_app/features/driver/domain/spot_repository.dart';
import 'package:tanker_app/features/driver/presentation/providers/driver_providers.dart';
import 'package:tanker_app/features/driver/presentation/screens/driver_new_order_screen.dart';
import 'package:tanker_app/shared/models/customer_option.dart';
import 'package:tanker_app/shared/models/order.dart';
import 'package:tanker_app/shared/models/paginated.dart';
import 'package:tanker_app/shared/models/spot.dart';
import 'package:tanker_app/shared/widgets/empty_state.dart';

import '../../support/order_fixture.dart';

/// A driver taking an order on the route.
///
/// Two claims are load-bearing and both are asserted here:
///
/// * **the request carries no `driver_id`** — the order goes to the token's
///   driver, decided server-side, and the screen must not invent a driver
///   field for it;
/// * **a driver holding no tanker is refused before the form**, not at submit,
///   because an order is priced from the vehicle that delivers it and
///   assignment refuses a driver with none.
class _FakeDriverRepository implements DriverRepository {
  _FakeDriverRepository({this.tanker});

  /// Null = this driver is between tankers.
  final Map<String, dynamic>? tanker;

  @override
  Future<ApiResult<DriverSummary>> summary() async => Success(
        DriverSummary.fromJson(<String, dynamic>{
          'driver': {'full_name': 'Ramesh Patil', 'tanker': tanker},
          'today': {'assigned': 0, 'delivered': 0, 'tankers': 0},
        }),
      );
}

class _FakeSpotRepository implements SpotRepository {
  @override
  Future<ApiResult<List<Spot>>> usable() async => Success(<Spot>[
        Spot.fromJson(const {
          'id': 7,
          'name': 'Hingna Road spot',
          'refill_charge': 200,
          'is_available': true,
          'status': true,
        }),
      ]);
}

class _FakeCustomerLookup implements CustomerLookupRepository {
  String? lastQuery;

  @override
  Future<ApiResult<List<CustomerOption>>> search(String query) async {
    lastQuery = query;

    return Success(<CustomerOption>[
      CustomerOption.fromJson(const {
        'id': 42,
        'full_name': 'Sunita Joshi',
        'mobile': '9333333333',
        'address': 'Flat 4, Kothrud',
      }),
    ]);
  }
}

/// Records the body the screen actually asked for.
class _RecordingOrderRepository implements DriverOrderRepository {
  int places = 0;
  int? lastCustomerId;
  String? lastAddress;
  int? lastTankerCount;
  double? lastTankerRate;
  int? lastSpotId;

  @override
  Future<ApiResult<Order>> place({
    required int customerId,
    required String deliveryAddress,
    required DateTime deliveryDate,
    int? deliverySlotId,
    int? spotId,
    int? tankerCount,
    double? tankerRate,
    String? notes,
  }) async {
    places++;
    lastCustomerId = customerId;
    lastAddress = deliveryAddress;
    lastTankerCount = tankerCount;
    lastTankerRate = tankerRate;
    lastSpotId = spotId;

    return Success(fixtureOrder());
  }

  @override
  Future<ApiResult<Order>> show(int orderId) async => Success(fixtureOrder(id: orderId));

  @override
  Future<ApiResult<Paginated<Order>>> list({required bool openOnly, int page = 1}) async =>
      const Success(Paginated<Order>.empty());

  @override
  Future<ApiResult<Order>> startRefill(int orderId, {int? spotId, String? note}) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<Order>> markOutForDelivery(int orderId) => throw UnimplementedError();

  @override
  Future<ApiResult<Order>> markDelivered(int orderId, {String? note}) => throw UnimplementedError();
}

const _pricedTanker = <String, dynamic>{
  'id': 3,
  'label': 'Tanker One (MH12AB1234)',
  'vehicle_number': 'MH12AB1234',
  // Deliberately an int: PHP sends an integral rate without its .0.
  'tanker_rate': 1500,
};

void main() {
  Future<_RecordingOrderRepository> pumpForm(
    WidgetTester tester, {
    Map<String, dynamic>? tanker = _pricedTanker,
  }) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final orders = _RecordingOrderRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          driverRepositoryProvider.overrideWithValue(_FakeDriverRepository(tanker: tanker)),
          driverOrderRepositoryProvider.overrideWithValue(orders),
          spotRepositoryProvider.overrideWithValue(_FakeSpotRepository()),
          customerLookupRepositoryProvider.overrideWithValue(_FakeCustomerLookup()),
          // The slot dropdown would otherwise reach the network.
          deliverySlotOptionsProvider.overrideWith((ref) async => []),
        ],
        child: const MaterialApp(
          home: Scaffold(body: DriverNewOrderScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    return orders;
  }

  /// Types a name, waits out the picker's 400 ms debounce, and taps the result.
  Future<void> chooseCustomer(WidgetTester tester) async {
    await tester.enterText(find.widgetWithText(TextField, 'Customer'), 'Sunita');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sunita Joshi').last);
    await tester.pumpAndSettle();
  }

  testWidgets('a driver with no tanker is refused before the form', (tester) async {
    await pumpForm(tester, tanker: null);

    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('No tanker assigned to you'), findsOneWidget);
    // No form to fill in, so no way to reach a submit that could only 400.
    expect(find.text('Place Order'), findsNothing);
  });

  testWidgets('there is no driver field — the order can only be theirs', (tester) async {
    await pumpForm(tester);

    // The admin's form has a "Driver" picker right here; the driver's must not,
    // because the server takes the driver from the token and would ignore one.
    expect(find.text('Driver'), findsNothing);
    expect(find.text('Who is delivering?'), findsNothing);

    // Instead it states which vehicle, read-only.
    expect(find.text('Tanker One (MH12AB1234)'), findsOneWidget);
    expect(find.text('You are delivering'), findsOneWidget);
  });

  testWidgets('the rate pre-fills from their own tanker and totals live', (tester) async {
    await pumpForm(tester);

    // 1500 arrived as an int and still reads as a rate (CLAUDE.md rule 7).
    expect(find.text('₹ 1500 per tanker'), findsOneWidget);
    expect(find.text('1 × ₹ 1500.00'), findsOneWidget);
    expect(find.text('₹ 1500.00'), findsOneWidget);
  });

  testWidgets('choosing a customer fills in their registered address', (tester) async {
    await pumpForm(tester);
    await chooseCustomer(tester);

    expect(
      tester.widget<TextField>(find.widgetWithText(TextField, 'Delivery address')).controller?.text,
      'Flat 4, Kothrud',
    );
  });

  testWidgets('submitting sends the customer and count but no rate override', (tester) async {
    final orders = await pumpForm(tester);
    await chooseCustomer(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Place Order'));
    await tester.pumpAndSettle();

    expect(orders.places, 1);
    expect(orders.lastCustomerId, 42);
    expect(orders.lastAddress, 'Flat 4, Kothrud');
    expect(orders.lastTankerCount, 1);

    // The decisive one: the field was pre-filled with the vehicle's own rate,
    // so leaving it alone must NOT be sent as an override — a `rate_fixed`
    // order can never be re-priced by the office.
    expect(orders.lastTankerRate, isNull);
  });

  testWidgets('a rate typed over the vehicle\'s is sent as an override', (tester) async {
    final orders = await pumpForm(tester);
    await chooseCustomer(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Rate per tanker (₹)'), '1200');
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Place Order'));
    await tester.pumpAndSettle();

    expect(orders.lastTankerRate, 1200);
  });

  testWidgets('without a customer it says so instead of posting', (tester) async {
    final orders = await pumpForm(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Place Order'));
    await tester.pumpAndSettle();

    expect(find.text('Choose a customer first.'), findsOneWidget);
    expect(orders.places, 0);
  });

  testWidgets('an unpriced tanker reads "Not priced yet", never ₹ 0', (tester) async {
    await pumpForm(tester, tanker: const <String, dynamic>{
      'id': 3,
      'label': 'Tanker One (MH12AB1234)',
      'vehicle_number': 'MH12AB1234',
      'tanker_rate': null,
    });

    expect(find.text('No rate set on this tanker'), findsOneWidget);
    expect(find.text('Not priced yet'), findsOneWidget);
    expect(find.text('₹ 0.00'), findsNothing);
    // And it says what to do about it rather than just showing a blank.
    expect(find.textContaining('saves unpriced unless you'), findsOneWidget);
  });
}
