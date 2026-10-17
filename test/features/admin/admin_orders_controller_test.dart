import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/core/network/api_result.dart';
import 'package:tanker_app/features/admin/domain/admin_order_filter.dart';
import 'package:tanker_app/features/admin/domain/admin_order_repository.dart';
import 'package:tanker_app/features/admin/presentation/providers/admin_orders_controller.dart';
import 'package:tanker_app/features/admin/presentation/providers/admin_providers.dart';
import 'package:tanker_app/shared/models/order.dart';
import 'package:tanker_app/shared/models/paginated.dart';

import '../../support/order_fixture.dart';

class _FakeRepository implements AdminOrderRepository {
  int lists = 0;

  @override
  Future<ApiResult<Paginated<Order>>> list(AdminOrderFilter filter, {int page = 1}) async {
    lists++;

    return Success(Paginated<Order>(
      items: [fixtureOrder()],
      currentPage: page,
      lastPage: 1,
      perPage: 20,
      total: 1,
      hasMore: false,
    ));
  }

  @override
  Future<ApiResult<Order>> show(int orderId) => throw UnimplementedError();

  @override
  Future<ApiResult<Order>> create({
    required int customerId,
    required String deliveryAddress,
    required DateTime deliveryDate,
    required double orderAmount,
    double? latitude,
    double? longitude,
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
  test("the admin's order list fetches on open and stops loading", () async {
    final repository = _FakeRepository();

    final container = ProviderContainer(
      overrides: [adminOrderRepositoryProvider.overrideWithValue(repository)],
    );

    addTearDown(container.dispose);

    container.listen(adminOrdersControllerProvider, (_, _) {});

    await Future<void>.delayed(Duration.zero);

    expect(repository.lists, 1);
    expect(container.read(adminOrdersControllerProvider).loading, isFalse);
    expect(container.read(adminOrdersControllerProvider).paginated.items, hasLength(1));
  });
}
