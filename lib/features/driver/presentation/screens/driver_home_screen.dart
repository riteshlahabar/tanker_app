import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/order_list_tile.dart';
import '../providers/driver_orders_controller.dart';
import '../providers/driver_summary_controller.dart';
import 'driver_order_detail_screen.dart';

/// The driver's Home: who they are, which tanker they are on, and the three
/// numbers that describe their day — then today's run.
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
              child: _DriverGreeting(
                name: summary.fullName,
                tanker: summary.tanker?.label,
              ),
            ),
            const SizedBox(height: 16),
            // Three cards, one colour each, because the driver reads these at
            // arm's length in a cab: three grey numbers in a row took a second
            // look to tell apart, and the colours are the order lifecycle's
            // own — assigned blue, delivered green — so they already mean
            // something elsewhere in the app.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _StatCard(
                    label: 'Assigned',
                    value: '${summary.todayAssigned}',
                    icon: Icons.assignment_outlined,
                    colour: statusAssignedColor,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    label: 'Delivered',
                    value: '${summary.todayDelivered}',
                    icon: Icons.check_circle_outline,
                    colour: statusDeliveredColor,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    label: 'Tankers',
                    value: '${summary.todayTankers}',
                    icon: Icons.water_drop_outlined,
                    colour: appetitBrownColor,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 22),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "TODAY'S RUN",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: appTextColorSecondary,
              ),
            ),
          ),
          const SizedBox(height: 10),
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

}

class _DriverGreeting extends StatelessWidget {
  const _DriverGreeting({required this.name, this.tanker});

  final String name;
  final String? tanker;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [appBottomNavColor, Color(0xFF6A4A72)],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $name',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tanker == null ? 'No tanker assigned' : 'On $tanker',
                  style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                ),
              ],
            ),
          ),
          const Icon(Icons.local_shipping, color: Colors.white24, size: 40),
        ],
      ),
    );
  }
}

/// One of the three day cards. Tinted rather than filled: three saturated
/// blocks side by side fight each other, and the number is what has to read
/// first.
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.colour,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color colour;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: colour.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: colour.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: colour, size: 20),
            const SizedBox(height: 8),
            // A fixed-height cell clips a long label, and a driver with 12
            // deliveries makes this two characters wider than it was designed
            // for.
            FittedBox(
              child: Text(
                value,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: colour),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11.5, color: appTextColorSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
