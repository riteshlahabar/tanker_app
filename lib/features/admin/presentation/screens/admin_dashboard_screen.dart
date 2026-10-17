import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/stat_tile.dart';
import '../providers/admin_dashboard_controller.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminDashboardControllerProvider);
    final dashboard = state.dashboard;

    if (state.loading && dashboard == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (dashboard == null) {
      return Center(child: Text(state.error?.message ?? 'Could not load the dashboard.'));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(adminDashboardControllerProvider.notifier).refresh(),
      child: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        childAspectRatio: 1.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          StatTile(label: 'Active tankers', value: '${dashboard.tankers}'),
          StatTile(label: 'Active drivers', value: '${dashboard.drivers}'),
          StatTile(label: 'Active customers', value: '${dashboard.customers}'),
          StatTile(label: 'Scheduled tomorrow', value: '${dashboard.scheduledTomorrow}'),
          StatTile(label: 'Orders today', value: '${dashboard.ordersToday}'),
          StatTile(label: 'Pending', value: '${dashboard.pending}'),
          StatTile(label: 'Delivered today', value: '${dashboard.deliveredToday}'),
          StatTile(
            label: 'Revenue today',
            value: '₹ ${dashboard.revenueToday.toStringAsFixed(0)}',
          ),
          StatTile(
            label: 'Tankers delivered today',
            value: '${dashboard.tankersDeliveredToday}',
          ),
        ],
      ),
    );
  }
}
