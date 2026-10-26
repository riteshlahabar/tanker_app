import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/core/network/api_result.dart';
import 'package:tanker_app/features/admin/domain/admin_order_filter.dart';
import 'package:tanker_app/features/admin/domain/admin_order_repository.dart';
import 'package:tanker_app/features/admin/presentation/providers/admin_order_detail_controller.dart';
import 'package:tanker_app/features/admin/presentation/providers/admin_providers.dart';
import 'package:tanker_app/shared/models/order.dart';
import 'package:tanker_app/shared/models/paginated.dart';

import '../../support/order_fixture.dart';

class _FakeRepository implements AdminOrderRepository {
  int? sentDriverId;
  int? sentSpotId;
  String? sentReason;
  int reassigns = 0;

  @override
  Future<ApiResult<Order>> show(int orderId) async => Success(fixtureOrder(id: orderId));

  @override
  Future<ApiResult<Order>> reassign(
    int orderId, {
    required int driverId,
    int? spotId,
    String? reason,
  }) async {
    reassigns++;
    sentDriverId = driverId;
    sentSpotId = spotId;
    sentReason = reason;

    return Success(fixtureOrder(id: orderId));
  }

  @override
  Future<ApiResult<Paginated<Order>>> list(AdminOrderFilter filter, {int page = 1}) =>
      throw UnimplementedError();

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
  Future<ApiResult<Order>> cancel(int orderId, String reason) => throw UnimplementedError();
}

void main() {
  test('changing the driver sends the new driver and the reason', () async {
    final repository = _FakeRepository();

    final container = ProviderContainer(
      overrides: [adminOrderRepositoryProvider.overrideWithValue(repository)],
    );

    addTearDown(container.dispose);
    container.listen(adminOrderDetailControllerProvider(3), (_, _) {});

    await Future<void>.delayed(Duration.zero);

    final message = await container
        .read(adminOrderDetailControllerProvider(3).notifier)
        .reassign(driverId: 9, reason: 'Driver absent');

    expect(repository.reassigns, 1);
    expect(repository.sentDriverId, 9);
    // Left out means "keep the spot the order already has", so nothing is sent.
    expect(repository.sentSpotId, isNull);
    expect(repository.sentReason, 'Driver absent');
    // A null message is this controller's way of saying the call succeeded.
    expect(message, isNull);
  });
}
