import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/core/network/api_result.dart';
import 'package:tanker_app/features/driver/domain/driver_order_repository.dart';
import 'package:tanker_app/features/driver/presentation/providers/driver_order_detail_controller.dart';
import 'package:tanker_app/features/driver/presentation/providers/driver_providers.dart';
import 'package:tanker_app/shared/models/order.dart';
import 'package:tanker_app/shared/models/paginated.dart';

import '../../support/order_fixture.dart';

class _FakeRepository implements DriverOrderRepository {
  int shows = 0;

  @override
  Future<ApiResult<Order>> show(int orderId) async {
    shows++;

    return Success(fixtureOrder(id: orderId));
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
  Future<ApiResult<Order>> startRefill(int orderId, {int? spotId, String? note}) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<Order>> markOutForDelivery(int orderId) => throw UnimplementedError();

  @override
  Future<ApiResult<Order>> markDelivered(int orderId, {String? note}) => throw UnimplementedError();
}

void main() {
  test("the driver's order detail fetches on open and stops loading", () async {
    final repository = _FakeRepository();

    final container = ProviderContainer(
      overrides: [driverOrderRepositoryProvider.overrideWithValue(repository)],
    );

    addTearDown(container.dispose);

    container.listen(driverOrderDetailControllerProvider(3), (_, _) {});

    await Future<void>.delayed(Duration.zero);

    expect(repository.shows, 1);
    expect(container.read(driverOrderDetailControllerProvider(3)).loading, isFalse);
    expect(container.read(driverOrderDetailControllerProvider(3)).order?.orderNo, 'TNK-2026-00003');
  });
}
