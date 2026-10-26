import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/shell_tab_bar.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../providers/order_detail_controller.dart';
import '../providers/my_orders_controller.dart';
import '../../../../shared/widgets/order_timeline.dart';

/// "Order tracking timeline" — pushed from a tile tap in My Orders or Home,
/// never a tab of its own.
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final int orderId;

  static final _dateFormat = DateFormat('d MMM yyyy');

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final reasonController = TextEditingController();

    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel this order?'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(labelText: 'Reason', hintText: 'Why are you cancelling?'),
          maxLines: 2,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back')),
          TextButton(
            onPressed: () => Navigator.pop(context, reasonController.text.trim()),
            child: const Text('Cancel order'),
          ),
        ],
      ),
    );

    if (reason == null || reason.isEmpty || !context.mounted) return;

    final message = await ref.read(orderDetailControllerProvider(orderId).notifier).cancel(reason);

    if (!context.mounted) return;

    ref.invalidate(myOrdersControllerProvider(true));
    ref.invalidate(myOrdersControllerProvider(false));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message ?? ref.read(orderDetailControllerProvider(orderId)).error?.message ?? 'Could not cancel the order.')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderDetailControllerProvider(orderId));
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
            onRefresh: () => ref.read(orderDetailControllerProvider(orderId).notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusChip(status: order.status, label: order.statusLabel),
                    Text(
                      order.amountLabel,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
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
                if (order.driver != null)
                  _detailRow(
                    Icons.local_shipping_outlined,
                    'Driver: ${order.driver!.fullName}'
                    '${order.driver!.mobile != null ? ' · ${order.driver!.mobile}' : ''}',
                  ),
                if (order.notes != null && order.notes!.isNotEmpty)
                  _detailRow(Icons.notes_outlined, order.notes!),
                if (order.cancelReason != null)
                  _detailRow(Icons.info_outline, 'Cancelled: ${order.cancelReason}'),
                const SizedBox(height: 24),
                const Text('Tracking', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 12),
                OrderTimeline(entries: order.timeline),
                if (order.isOpen) ...[
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: state.cancelling ? null : () => _cancel(context, ref),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    child: state.cancelling
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Cancel Order'),
                  ),
                ],
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
