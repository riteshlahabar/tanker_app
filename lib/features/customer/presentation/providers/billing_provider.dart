import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/models/order.dart';
import '../../domain/billing_summary.dart';
import 'customer_order_providers.dart';

part 'billing_provider.g.dart';

/// How many pages of history the billing screen will walk.
///
/// The list endpoint is paginated at 20, and a customer on a daily routine
/// reaches a year in about 18 pages. Ten is roughly six months of daily
/// deliveries and is a cap, not a target — [BillingSummary.truncated] says so
/// on screen rather than quietly showing an understated total, which is the
/// one thing a bill must never do.
const _maxPages = 10;

/// Every order the customer has, folded into months and days.
///
/// Built here rather than asked of the server because there is no billing
/// endpoint — and there does not need to be one: the orders already carry the
/// whole price rule (`tanker_rate × tanker_count = order_amount`), so the
/// arithmetic the customer wants to check is the arithmetic already on the
/// wire.
@riverpod
Future<BillingSummary> customerBilling(Ref ref) async {
  final repository = ref.read(customerOrderRepositoryProvider);
  final orders = <Order>[];

  for (var page = 1; page <= _maxPages; page++) {
    final result = await repository.list(openOnly: false, page: page);

    final fetched = result.when(
      success: (value) => value,
      error: (failure) => throw failure,
    );

    orders.addAll(fetched.items);

    if (!fetched.hasMore) return BillingSummary.fromOrders(orders);
  }

  return BillingSummary.fromOrders(orders, truncated: true);
}
