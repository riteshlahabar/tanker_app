import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/core/network/api_result.dart';
import 'package:tanker_app/features/driver/domain/driver_order_repository.dart';
import 'package:tanker_app/features/driver/domain/spot_repository.dart';
import 'package:tanker_app/features/driver/presentation/providers/driver_providers.dart';
import 'package:tanker_app/features/driver/presentation/widgets/driver_status_action.dart';
import 'package:tanker_app/shared/models/order.dart';
import 'package:tanker_app/shared/models/paginated.dart';
import 'package:tanker_app/shared/models/spot.dart';
import 'package:tanker_app/shared/widgets/app_dropdown_field.dart';

import '../../support/order_fixture.dart';

/// Two faults, both reported from a real phone.
///
/// **The buttons were under the navigation bar.** After tapping **Start
/// Refill**, the sheet's own **Back** and **Start Refill** buttons sat
/// underneath the phone's system navigation bar and could not be pressed. The
/// sheet padded for the keyboard (`viewInsets.bottom`) and never for the
/// navigation bar, which only shows from Android 15: earlier versions let an
/// app opt out of edge-to-edge, so the system drew that bar on its own ground
/// and the gap was invisible. The real screen is driven here rather than the
/// padding alone, because the thing that was broken is reachability — a
/// button inside the window but under the bar is still unusable.
///
/// **It asked for a filling point the admin had already chosen.** When the
/// admin assigns an order and names the filling point, the driver tapping
/// Start Refill was asked to pick one all over again, which reads as though
/// the office's choice had not been recorded. It now starts straight away and
/// offers a Change link instead; the question is only asked when the order
/// genuinely carries no point.
class _FakeSpotRepository implements SpotRepository {
  _FakeSpotRepository({this.spots = const []});

  final List<Map<String, dynamic>> spots;

  @override
  Future<ApiResult<List<Spot>>> usable() async =>
      Success(spots.map(Spot.fromJson).toList());
}

/// Records what the screen actually posted, which is the whole point of the
/// two behaviour tests: whether `spot_id` was sent decides whether the
/// admin's filling point survives.
class _RecordingOrderRepository implements DriverOrderRepository {
  _RecordingOrderRepository(this.order);

  final Order order;

  int refills = 0;
  int? lastSpotId;
  String? lastNote;

  @override
  Future<ApiResult<Order>> show(int orderId) async => Success(order);

  @override
  Future<ApiResult<Order>> startRefill(int orderId, {int? spotId, String? note}) async {
    refills++;
    lastSpotId = spotId;
    lastNote = note;

    return Success(order);
  }

  @override
  Future<ApiResult<Paginated<Order>>> list({required bool openOnly, int page = 1}) =>
      throw UnimplementedError();

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
  }) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<Order>> markOutForDelivery(int orderId) => throw UnimplementedError();

  @override
  Future<ApiResult<Order>> markDelivered(int orderId, {String? note}) => throw UnimplementedError();
}

const _hingna = <String, dynamic>{
  'id': 1,
  'name': 'Hingna Road spot',
  'refill_charge': 200,
  'is_available': true,
  'status': true,
};

const _wadi = <String, dynamic>{
  'id': 2,
  'name': 'Wadi bore well',
  'refill_charge': 150,
  'is_available': true,
  'status': true,
};

void main() {
  /// Pumps the driver's status action for [order] on a phone with a
  /// [navigationBar]-tall system bar at the bottom.
  Future<_RecordingOrderRepository> pumpAction(
    WidgetTester tester, {
    required Order order,
    List<Map<String, dynamic>> spots = const [_hingna],
    Size screen = const Size(360, 732),
    double navigationBar = 48,
  }) async {
    tester.view.physicalSize = screen;
    tester.view.devicePixelRatio = 1.0;
    tester.view.padding = FakeViewPadding(bottom: navigationBar);
    tester.view.viewPadding = FakeViewPadding(bottom: navigationBar);
    addTearDown(tester.view.reset);

    final orders = _RecordingOrderRepository(order);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          spotRepositoryProvider.overrideWithValue(_FakeSpotRepository(spots: spots)),
          driverOrderRepositoryProvider.overrideWithValue(orders),
        ],
        child: MaterialApp(
          home: Scaffold(body: DriverStatusAction(order: order, acting: false)),
        ),
      ),
    );

    await tester.pumpAndSettle();

    return orders;
  }

  /// Taps the screen's own action. Scoped to the [PrimaryButton]'s text so it
  /// is not confused with the sheet's confirm, which carries the same words.
  Future<void> tapStartRefill(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(ElevatedButton, 'Start Refill'));
    await tester.pumpAndSettle();
  }

  group('an order with no filling point', () {
    testWidgets('the refill sheet buttons clear the system navigation bar', (tester) async {
      await pumpAction(tester, order: fixtureOrder());
      await tapStartRefill(tester);

      expect(tester.takeException(), isNull);

      // Both scoped to the sheet: the screen's PrimaryButton carries the same
      // words, and the sheet's heading differs only in its lower-case
      // "refill".
      final confirm = find.widgetWithText(FilledButton, 'Start Refill');
      final back = find.widgetWithText(TextButton, 'Back');

      expect(confirm, findsOneWidget);
      expect(back, findsOneWidget);

      // 732 tall with a 48px bar leaves 684 usable.
      expect(tester.getBottomLeft(confirm).dy, lessThanOrEqualTo(684));
      expect(tester.getBottomLeft(back).dy, lessThanOrEqualTo(684));
    });

    testWidgets('the sheet still sits at the bottom when there is no navigation bar', (tester) async {
      // An inset of its own must not be invented where the platform reports
      // none, or the sheet floats above the edge on a device with buttons off
      // screen.
      await pumpAction(tester, order: fixtureOrder(), navigationBar: 0);
      await tapStartRefill(tester);

      final confirm = find.widgetWithText(FilledButton, 'Start Refill');

      expect(tester.getBottomLeft(confirm).dy, greaterThan(684));
      expect(tester.getBottomLeft(confirm).dy, lessThanOrEqualTo(732));
    });

    testWidgets('will not start until a point is picked, then sends it', (tester) async {
      final orders = await pumpAction(tester, order: fixtureOrder(), spots: [_hingna, _wadi]);
      await tapStartRefill(tester);

      // Nothing is pre-selected, so the refill cannot be started blind — the
      // sheet used to offer a null "use the assigned filling point" option on
      // an order that had none.
      final confirm = find.widgetWithText(FilledButton, 'Start Refill');

      expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
      expect(orders.refills, 0);

      await tester.tap(find.byType(AppDropdownField<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Wadi bore well').last);
      await tester.pumpAndSettle();

      await tester.tap(confirm);
      await tester.pumpAndSettle();

      expect(orders.refills, 1);
      expect(orders.lastSpotId, 2);
    });
  });

  group('an order the admin already chose a filling point for', () {
    testWidgets('starts the refill without asking, and sends no spot', (tester) async {
      final orders = await pumpAction(
        tester,
        order: fixtureOrder(spotId: 1, spotName: 'Hingna Road spot'),
      );

      await tapStartRefill(tester);

      // No sheet: the heading would be here if one had opened.
      expect(find.text('Start refill'), findsNothing);
      expect(orders.refills, 1);

      // The decisive assertion. Sending a spot_id would re-snapshot
      // `refill_charge` from it; sending none leaves the admin's point and
      // charge exactly as they were.
      expect(orders.lastSpotId, isNull);
    });

    testWidgets('the driver can still change where they are filling', (tester) async {
      final orders = await pumpAction(
        tester,
        order: fixtureOrder(spotId: 1, spotName: 'Hingna Road spot'),
        spots: [_hingna, _wadi],
      );

      // The link names the point so the driver knows what they are changing
      // from.
      await tester.tap(find.text('Filling at Hingna Road spot · Change'));
      await tester.pumpAndSettle();

      expect(find.text('Change filling point'), findsOneWidget);

      await tester.tap(find.byType(AppDropdownField<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Wadi bore well').last);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Start Refill'));
      await tester.pumpAndSettle();

      expect(orders.refills, 1);
      expect(orders.lastSpotId, 2);
    });

    testWidgets('the change link is gone once the order is refilling', (tester) async {
      // The spot is snapshotted when the refill starts, so from `refilling`
      // on there is nothing here left to change.
      await pumpAction(
        tester,
        order: fixtureOrder(status: 'refilling', spotId: 1, spotName: 'Hingna Road spot'),
      );

      expect(find.textContaining('Change'), findsNothing);
      expect(find.widgetWithText(ElevatedButton, 'Out for Delivery'), findsOneWidget);
    });
  });
}
