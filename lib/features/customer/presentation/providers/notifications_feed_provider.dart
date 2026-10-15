import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/models/order.dart';
import 'customer_order_providers.dart';

part 'notifications_feed_provider.g.dart';

/// There is no notifications backend — every real notice goes to WhatsApp
/// (see `CLAUDE.md`). This reads the customer's own orders, newest first, as
/// a stand-in activity feed rather than inventing a parallel store.
@riverpod
Future<List<Order>> notificationsFeed(Ref ref) async {
  final result = await ref.read(customerOrderRepositoryProvider).list(openOnly: false);

  return result.when(success: (page) => page.items, error: (failure) => throw failure);
}
