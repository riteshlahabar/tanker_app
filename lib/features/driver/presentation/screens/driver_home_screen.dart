import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/order_list_tile.dart';
import '../providers/driver_orders_controller.dart';
import '../providers/driver_summary_controller.dart';
import 'driver_order_detail_screen.dart';

class DriverHomeScreen extends ConsumerWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryState = ref.watch(driverSummaryControllerProvider);
    final today = ref.watch(driverOrdersControllerProvider(true));
    final summary = summaryState.summary;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(driverSummaryControllerProvider.notifier).refresh();
        await ref.read(driverOrdersControllerProvider(true).notifier).refresh();
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          if (summaryState.loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (summary != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Hello, ${summary.fullName}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ),
            if (summary.tanker != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Tanker: ${summary.tanker!.label}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                _statTile('Assigned', '${summary.todayAssigned}'),
                _statTile('Delivered', '${summary.todayDelivered}'),
                _statTile('Tankers', '${summary.todayTankers}'),
              ],
            ),
          ],
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text("Today's Deliveries", style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 8),
          if (today.paginated.isEmpty && !today.loading)
            const EmptyState(icon: Icons.local_shipping_outlined, title: 'Nothing on today’s run')
          else
            for (final order in today.paginated.items)
              OrderListTile(
                order: order,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => DriverOrderDetailScreen(orderId: order.id)),
                ),
              ),
        ],
      ),
    );
  }

  Widget _statTile(String label, String value) => Expanded(
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      );
}
