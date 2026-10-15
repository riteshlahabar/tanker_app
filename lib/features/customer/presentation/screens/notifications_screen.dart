import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../providers/notifications_feed_provider.dart';
import 'order_detail_screen.dart';

/// Notifications tab body. There is no in-app notification store — every
/// real notice is sent over WhatsApp — so this reads as an activity feed
/// derived from the customer's own orders rather than a true inbox.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  static final _dateTimeFormat = DateFormat('d MMM, h:mm a');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(notificationsFeedProvider);

    return feed.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => EmptyState(
        icon: Icons.error_outline,
        title: 'Could not load your activity',
        message: '$error',
      ),
      data: (orders) {
        if (orders.isEmpty) {
          return const EmptyState(
            icon: Icons.notifications_none,
            title: 'Nothing yet',
            message: 'Updates about your orders will show up here.',
          );
        }

        return RefreshIndicator(
          onRefresh: () => ref.refresh(notificationsFeedProvider.future),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: orders.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final order = orders[index];
              final at = order.deliveredAt ?? order.createdAt;

              return ListTile(
                leading: StatusChip(status: order.status, label: order.statusLabel),
                title: Text('${order.orderNo} is ${order.statusLabel.toLowerCase()}'),
                subtitle: at == null ? null : Text(_dateTimeFormat.format(at)),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: order.id)),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
