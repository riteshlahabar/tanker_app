import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/core/network/api_result.dart';
import 'package:tanker_app/features/driver/domain/spot_repository.dart';
import 'package:tanker_app/features/driver/presentation/providers/driver_providers.dart';
import 'package:tanker_app/features/driver/presentation/widgets/driver_status_action.dart';
import 'package:tanker_app/shared/models/spot.dart';

import '../../support/order_fixture.dart';

/// The driver reported that after tapping **Start Refill**, the sheet's own
/// **Back** and **Start Refill** buttons sat underneath the phone's system
/// navigation bar and could not be pressed.
///
/// The sheet padded for the keyboard (`viewInsets.bottom`) and never for the
/// navigation bar, which only shows from Android 15: earlier versions let an
/// app opt out of edge-to-edge, so the system drew that bar on its own ground
/// and the gap was invisible.
///
/// The real screen is driven here rather than the padding alone, because the
/// thing that was broken is reachability — a button inside the window but
/// under the bar is still unusable.
class _FakeSpotRepository implements SpotRepository {
  @override
  Future<ApiResult<List<Spot>>> usable() async => Success(<Spot>[
        Spot.fromJson(const {
          'id': 1,
          'name': 'Hingna Road spot',
          'refill_charge': 200,
          'is_available': true,
          'status': true,
        }),
      ]);

  @override
  Future<ApiResult<List<Spot>>> nearby({
    required double latitude,
    required double longitude,
    int limit = 10,
  }) =>
      throw UnimplementedError();
}

void main() {
  /// Opens the Start Refill sheet on a phone with a [navigationBar]-tall
  /// system bar at the bottom.
  Future<void> openRefillSheet(
    WidgetTester tester, {
    Size screen = const Size(360, 732),
    double navigationBar = 48,
  }) async {
    tester.view.physicalSize = screen;
    tester.view.devicePixelRatio = 1.0;
    tester.view.padding = FakeViewPadding(bottom: navigationBar);
    tester.view.viewPadding = FakeViewPadding(bottom: navigationBar);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [spotRepositoryProvider.overrideWithValue(_FakeSpotRepository())],
        child: MaterialApp(
          home: Scaffold(
            body: DriverStatusAction(order: fixtureOrder(), acting: false),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // The screen's own action, not the sheet's confirm — the sheet is not open
    // yet, so there is only one.
    await tester.tap(find.text('Start Refill'));
    await tester.pumpAndSettle();
  }

  testWidgets('the refill sheet buttons clear the system navigation bar', (tester) async {
    await openRefillSheet(tester);

    expect(tester.takeException(), isNull);

    // Both scoped to the sheet: the screen's PrimaryButton carries the same
    // words, and the sheet's heading differs only in its lower-case "refill".
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
    await openRefillSheet(tester, navigationBar: 0);

    final confirm = find.widgetWithText(FilledButton, 'Start Refill');

    expect(tester.getBottomLeft(confirm).dy, greaterThan(684));
    expect(tester.getBottomLeft(confirm).dy, lessThanOrEqualTo(732));
  });
}
