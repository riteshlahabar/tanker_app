import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/shell_tab_bar.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../../../shared/widgets/order_timeline.dart';
import '../providers/driver_order_detail_controller.dart';
import '../widgets/driver_status_action.dart';

/// Order detail for a driver — the same tracking timeline the customer sees,
/// plus the one status-advance action that applies right now. No Cancel
/// button: the driver role doesn't carry `order.cancel`.
class DriverOrderDetailScreen extends ConsumerWidget {
  const DriverOrderDetailScreen({super.key, required this.orderId});

  final int orderId;

  static final _dateFormat = DateFormat('d MMM yyyy');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(driverOrderDetailControllerProvider(orderId));
    final order = state.order;

    return Scaffold(
      appBar: AppBar(title: Text(order?.orderNo ?? 'Order')),
      body: switch ((state.loading, order)) {
        (true, null) => const Center(child: CircularProgressIndicator()),
        (_, null) => EmptyState(
            icon: Icons.error_outline,
            title: 'Could not load this order',
            message: state.error?.message,
          ),
        (_, final order!) => RefreshIndicator(
            onRefresh: () => ref.read(driverOrderDetailControllerProvider(orderId).notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Both Flexible: "Out for delivery" beside "Not priced
                    // yet" overflowed a 400px phone, and both are real labels
                    // — the amount reads as words, not a number, until a
                    // tanker has been chosen.
                    Flexible(
                      child: StatusChip(status: order.status, label: order.statusLabel),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        order.amountLabel,
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _detailRow(Icons.location_on_outlined, order.deliveryAddress),
                if (order.deliveryDate != null)
                  _detailRow(
                    Icons.calendar_today_outlined,
                    '${_dateFormat.format(order.deliveryDate!)}'
                    '${order.deliverySlot != null ? ' · ${order.deliverySlot}' : ''}',
                  ),
                if (order.tankerCount != null)
                  _detailRow(Icons.water_drop_outlined, order.tankerLabel),
                // Where to fill, when the office has already said. Without
                // this the driver had no way to see the point chosen for them,
                // which is half of why the app kept asking for one. The
                // "not chosen" line is only worth showing while the order is
                // still open — on a finished delivery it reads as a fault.
                if (order.spotName != null)
                  _detailRow(Icons.local_drink_outlined, order.spotName!)
                else if (order.isOpen)
                  _detailRow(Icons.local_drink_outlined, 'Filling point not chosen yet'),
                if (order.notes != null && order.notes!.isNotEmpty)
                  _detailRow(Icons.notes_outlined, order.notes!),
                const SizedBox(height: 24),
                const Text('Tracking', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 12),
                OrderTimeline(entries: order.timeline),
                const SizedBox(height: 16),
                DriverStatusAction(order: order, acting: state.acting),
              ],
            ),
          ),
      },
      bottomNavigationBar: const ShellTabBar(),
    );
  }

  Widget _detailRow(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: Colors.grey),
            const SizedBox(width: 10),
            Expanded(child: Text(text)),
          ],
        ),
      );
}
