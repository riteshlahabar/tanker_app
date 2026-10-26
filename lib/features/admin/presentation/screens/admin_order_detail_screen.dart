import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/models/order.dart';
import '../../../../shared/models/order_status.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/order_timeline.dart';
import '../../../../shared/widgets/shell_tab_bar.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../providers/admin_order_detail_controller.dart';
import '../providers/admin_orders_controller.dart';
import '../widgets/assign_order_sheet.dart';
import '../widgets/reassign_order_sheet.dart';

/// Order detail for the admin — the same tracking timeline, plus Assign
/// (while unassigned), Change Driver (while assigned, for an absent driver)
/// and Cancel (from any open status — the admin's policy is wider than the
/// customer's own "pending only" rule).
class AdminOrderDetailScreen extends ConsumerWidget {
  const AdminOrderDetailScreen({super.key, required this.orderId});

  final int orderId;

  static final _dateFormat = DateFormat('d MMM yyyy');

  Future<void> _assign(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => AssignOrderSheet(orderId: orderId),
      );

  /// Offered only while the order is `assigned`: once the driver starts
  /// refilling, the server refuses the handover because the water has been
  /// bought against them.
  Future<void> _reassign(BuildContext context, Order order) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => ReassignOrderSheet(
          orderId: orderId,
          currentDriverId: order.driver?.id,
          currentDriverName: order.driver?.fullName ?? order.driverName,
          isStandingOrder: order.isScheduled,
        ),
      );

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final reasonController = TextEditingController();

    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel this order?'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(labelText: 'Reason'),
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

    final message = await ref.read(adminOrderDetailControllerProvider(orderId).notifier).cancel(reason);

    if (!context.mounted) return;

    ref.invalidate(adminOrdersControllerProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message ?? 'Could not cancel the order.')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminOrderDetailControllerProvider(orderId));
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
            onRefresh: () => ref.read(adminOrderDetailControllerProvider(orderId).notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusChip(status: order.status, label: order.statusLabel),
                    Text(
                      '₹ ${order.orderAmount.toStringAsFixed(0)}',
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
                if (order.driverName != null)
                  _detailRow(Icons.local_shipping_outlined, 'Driver: ${order.driverName}'),
                if (order.spotName != null)
                  _detailRow(Icons.water_drop_outlined, 'Filling point: ${order.spotName}'),
                if (order.notes != null && order.notes!.isNotEmpty)
                  _detailRow(Icons.notes_outlined, order.notes!),
                if (order.isScheduled)
                  _detailRow(Icons.event_repeat_outlined, 'From a standing order'),
                if (order.cancelReason != null)
                  _detailRow(Icons.info_outline, 'Cancelled: ${order.cancelReason}'),
                const SizedBox(height: 24),
                const Text('Tracking', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 12),
                OrderTimeline(entries: order.timeline),
                const SizedBox(height: 16),
                if (order.driverName == null && order.isOpen)
                  FilledButton(
                    onPressed: state.acting ? null : () => _assign(context),
                    child: const Text('Assign Driver'),
                  ),
                if (order.status == OrderStatus.assigned) ...[
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: state.acting ? null : () => _reassign(context, order),
                    child: const Text('Change Driver'),
                  ),
                ],
                if (order.isOpen) ...[
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: state.acting ? null : () => _cancel(context, ref),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Cancel Order'),
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
