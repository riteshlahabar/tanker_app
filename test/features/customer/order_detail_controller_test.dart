import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/core/network/api_result.dart';
import 'package:tanker_app/features/customer/domain/customer_order_repository.dart';
import 'package:tanker_app/features/customer/presentation/providers/customer_order_providers.dart';
import 'package:tanker_app/features/customer/presentation/providers/order_detail_controller.dart';
import 'package:tanker_app/shared/models/order.dart';
import 'package:tanker_app/shared/models/paginated.dart';

/// A repository that answers at once, so a controller that never fetches is
/// the only way the screen can be left spinning.
class _FakeRepository implements CustomerOrderRepository {
  int shows = 0;

  @override
  Future<ApiResult<Order>> show(int orderId) async {
    shows++;

    return Success(Order.fromJson(<String, dynamic>{
      'id': orderId,
      'order_no': 'TNK-2026-00002',
      'status': 'pending',
      'status_label': 'Pending',
      'is_open': true,
      'delivery_address': 'Test Address 12',
      'order_amount': 0,
    }));
  }

  @override
  Future<ApiResult<Paginated<Order>>> list({required bool openOnly, int page = 1}) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<Order>> place({
    required String deliveryAddress,
    required DateTime deliveryDate,
    int? deliverySlotId,
    int? tankerCount,
    String? notes,
  }) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<Order>> cancel(int orderId, String reason) => throw UnimplementedError();
}

void main() {
  test('opening an order detail fetches it and stops loading', () async {
    final repository = _FakeRepository();

    final container = ProviderContainer(
      overrides: [customerOrderRepositoryProvider.overrideWithValue(repository)],
    );

    addTearDown(container.dispose);

    // Listening is what a screen does; it also keeps the autoDispose provider alive.
    container.listen(orderDetailControllerProvider(2), (_, _) {});

    expect(container.read(orderDetailControllerProvider(2)).loading, isTrue);

    await Future<void>.delayed(Duration.zero);

    expect(repository.shows, 1, reason: 'build() must actually start the fetch');

    final state = container.read(orderDetailControllerProvider(2));

    expect(state.loading, isFalse, reason: 'a finished fetch must clear the spinner');
    expect(state.order?.orderNo, 'TNK-2026-00002');
  });
}
