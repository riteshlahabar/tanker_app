import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/core/network/api_result.dart';
import 'package:tanker_app/features/admin/domain/admin_order_filter.dart';
import 'package:tanker_app/features/admin/domain/admin_order_repository.dart';
import 'package:tanker_app/features/admin/presentation/providers/admin_providers.dart';
import 'package:tanker_app/features/admin/presentation/widgets/admin_order_filter_bar.dart';
import 'package:tanker_app/shared/models/order.dart';
import 'package:tanker_app/shared/models/order_status.dart';
import 'package:tanker_app/shared/models/paginated.dart';

import '../../support/order_fixture.dart';

/// Tapping the status chip threw `A RenderFlex overflowed by 35 pixels` on a
/// real phone: the sheet lists every status plus "Any status", which is seven
/// 56px rows under a heading — about 450px — and a bottom sheet opened without
/// `isScrollControlled` is capped at 9/16 of the screen (411.8px on a 732px
/// phone).
///
/// The sheet cannot be made to fit an arbitrarily short box, so the contract
/// tested here is that its rows scroll: the viewport is pinned to the one the
/// crash was reported at, and a seventh status added later must not reopen it.
class _FakeRepository implements AdminOrderRepository {
  @override
  Future<ApiResult<Paginated<Order>>> list(AdminOrderFilter filter, {int page = 1}) async =>
      Success(Paginated<Order>(
        items: [fixtureOrder()],
        currentPage: page,
        lastPage: 1,
        perPage: 20,
        total: 1,
        hasMore: false,
      ));

  @override
  Future<ApiResult<Order>> show(int orderId) => throw UnimplementedError();

  @override
  Future<ApiResult<Order>> create({
    required int customerId,
    required int driverId,
    required String deliveryAddress,
    required DateTime deliveryDate,
    int? spotId,
    double? tankerRate,
    int? deliverySlotId,
    int? tankerCount,
    String? notes,
  }) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<Order>> assign(int orderId, {required int driverId, int? spotId}) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<Order>> reassign(
    int orderId, {
    required int driverId,
    int? spotId,
    String? reason,
  }) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<Order>> cancel(int orderId, String reason) => throw UnimplementedError();
}

void main() {
  Future<void> openStatusSheet(WidgetTester tester, Size screen) async {
    tester.view.physicalSize = screen;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [adminOrderRepositoryProvider.overrideWithValue(_FakeRepository())],
        child: const MaterialApp(
          home: Scaffold(body: AdminOrderFilterBar()),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Any status'));
    await tester.pumpAndSettle();
  }

  testWidgets('the status sheet fits the phone the overflow was reported on', (tester) async {
    // 360x732 — exactly the geometry in the crash report.
    await openStatusSheet(tester, const Size(360, 732));

    expect(tester.takeException(), isNull);
    expect(find.text('Filter by status'), findsOneWidget);
  });

  testWidgets('the status sheet fits a short screen by scrolling', (tester) async {
    // Landscape, where no sheet height can hold seven rows.
    await openStatusSheet(tester, const Size(732, 360));

    expect(tester.takeException(), isNull);
    expect(find.byType(Scrollable), findsWidgets);
  });
  testWidgets('every status is reachable and choosing one closes the sheet', (tester) async {
    await openStatusSheet(tester, const Size(360, 732));

    // The sheet's own list, not the filter bar's horizontal chip strip.
    final sheetList = find.descendant(
      of: find.byType(ListView),
      matching: find.byType(ListTile),
    );
    expect(sheetList, findsNWidgets(OrderStatus.values.length + 1));

    // The last row sits below the fold on this phone — which is the whole
    // point of the fix, so it has to be scrolled to rather than assumed.
    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(ListView),
        matching: find.text(OrderStatus.cancelled.label),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Filter by status'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
