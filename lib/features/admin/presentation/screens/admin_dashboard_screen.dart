import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/shell_tabs_controller.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/models/order_status.dart';
import '../../../../shared/widgets/order_list_tile.dart';
import '../../../../shared/widgets/stat_tile.dart';
import '../../domain/admin_dashboard.dart';
import '../../domain/admin_order_filter.dart';
import '../../domain/admin_report_filter.dart';
import '../providers/admin_dashboard_controller.dart';
import '../providers/admin_orders_controller.dart';
import '../providers/admin_reports_controller.dart';
import 'admin_order_detail_screen.dart';
import 'customer_list_screen.dart';
import 'driver_list_screen.dart';
import 'report_detail_screen.dart';
import 'schedule_list_screen.dart';
import 'tanker_list_screen.dart';

/// The report behind "Revenue today" — the server's key for the Daily
/// Delivery report, which is where the day's money is broken down.
const _revenueReportKey = 'daily-delivery';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminDashboardControllerProvider);
    final dashboard = state.dashboard;

    // The shell keeps every tab alive in an IndexedStack, so coming back to
    // the dashboard would otherwise show whatever was true when it first
    // loaded. The owner's rule is that a delivered order leaves this screen,
    // so returning to the tab re-reads it.
    ref.listen(shellTabsProvider, (previous, next) {
      final dashboardTab = next.tabs.indexWhere((tab) => tab.label == 'Dashboard');

      if (next.index == dashboardTab && previous?.index != next.index) {
        ref.read(adminDashboardControllerProvider.notifier).refresh();
      }
    });

    if (state.loading && dashboard == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (dashboard == null) {
      return Center(child: Text(state.error?.message ?? 'Could not load the dashboard.'));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(adminDashboardControllerProvider.notifier).refresh(),
      child: ListView(
        // No horizontal padding on the list itself: OrderListTile carries its
        // own 16px inset, the same as on the Orders tab, so the tiles below
        // line up with the cards above rather than sitting 32px in.
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _Counters(dashboard: dashboard),
          ),
          const SizedBox(height: 20),
          _OpenOrders(dashboard: dashboard),
        ],
      ),
    );
  }
}

/// The nine figures, grouped under headings — today's trade first, because it
/// is what the owner opens the app to check.
///
/// **Every counter is a doorway**: a figure invites the question "which
/// ones?", and the tile answers it by opening the list it was counted from,
/// pre-filtered — the "Active" tiles on their own `status: true` lists, so
/// what the owner lands on adds up to the number they tapped.
class _Counters extends ConsumerWidget {
  const _Counters({required this.dashboard});

  final AdminDashboard dashboard;

  /// Moves the shell to the Orders tab with the tile's own filter applied,
  /// rather than pushing a second copy of the list — see
  /// `ShellTabs.selectLabel`. Whatever the Orders tab was filtered by is
  /// replaced, which is the point: the owner asked for *these* orders.
  void _showOrders(WidgetRef ref, {OrderStatus? status, bool today = false}) {
    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day);

    ref.read(adminOrdersControllerProvider.notifier).setFilter(
          AdminOrderFilter(status: status, from: today ? day : null, to: today ? day : null),
        );
    ref.read(shellTabsProvider.notifier).selectLabel('Orders');
  }

  void _push(BuildContext context, Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));

  /// Revenue today opens the **Daily Delivery report for today** — the figure
  /// is a total, and a report is where a total is explained; the delivered
  /// orders behind it are one tap further on.
  ///
  /// The report's definition comes from the server's own menu rather than
  /// being written out here, so a renamed or re-filtered report still opens
  /// correctly. If that menu has not arrived yet the tile falls back to the
  /// Reports tab: the owner lands one tap away, never on nothing.
  void _showRevenueReport(BuildContext context, WidgetRef ref) {
    final reports = ref.read(adminReportsControllerProvider).reports;
    final definition = reports.where((report) => report.key == _revenueReportKey).firstOrNull;

    if (definition == null) {
      ref.read(shellTabsProvider.notifier).selectLabel('Reports');

      return;
    }

    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day);

    _push(
      context,
      ReportDetailScreen(
        definition: definition,
        initialFilter: AdminReportFilter(from: day, to: day),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watched rather than read at tap time: the Revenue tile opens a report
    // by the server's own menu, and that menu is otherwise loaded by the
    // Reports tab. A tile that quietly fell back to the Reports list because
    // another tab had not been opened yet would be a mystery to the owner.
    ref.watch(adminReportsControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeading('Today'),
        const SizedBox(height: 8),
        _Grid(
          children: [
            StatTile(
              label: 'Orders today',
              value: '${dashboard.ordersToday}',
              color: appColorPrimary,
              icon: Icons.receipt_outlined,
              onTap: () => _showOrders(ref, today: true),
            ),
            StatTile(
              label: 'Pending',
              value: '${dashboard.pending}',
              // The same amber a Pending chip uses, so the tile and the
              // order row read as the same thing.
              color: statusPendingColor,
              icon: Icons.hourglass_empty,
              // Deliberately no date: a pending order from yesterday is still
              // waiting, and the owner tapping this wants the queue, not an
              // extract of it.
              onTap: () => _showOrders(ref, status: OrderStatus.pending),
            ),
            StatTile(
              label: 'Delivered today',
              value: '${dashboard.deliveredToday}',
              color: statusDeliveredColor,
              icon: Icons.check_circle_outline,
              onTap: () => _showOrders(ref, status: OrderStatus.delivered, today: true),
            ),
            StatTile(
              label: 'Tankers delivered',
              value: '${dashboard.tankersDeliveredToday}',
              color: statusDeliveredColor,
              icon: Icons.water_drop_outlined,
              // Loads, not orders — so this opens the orders those loads were
              // carried on, the same list the tile beside it opens.
              onTap: () => _showOrders(ref, status: OrderStatus.delivered, today: true),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StatTile(
          label: 'Revenue today',
          value: '₹ ${dashboard.revenueToday.toStringAsFixed(0)}',
          color: appetitBrownColor,
          icon: Icons.currency_rupee,
          onTap: () => _showRevenueReport(context, ref),
        ),
        const SizedBox(height: 20),
        const _SectionHeading('Coming up'),
        const SizedBox(height: 8),
        _Grid(
          children: [
            StatTile(
              label: 'Scheduled tomorrow',
              value: '${dashboard.scheduledTomorrow}',
              color: statusRefillingColor,
              icon: Icons.event_outlined,
              // Tomorrow's orders do not exist yet — the generator writes them
              // overnight — so this opens the standing orders they come from,
              // not an empty day of the Orders list.
              onTap: () => _push(context, const ScheduleListScreen()),
            ),
            StatTile(
              label: 'Active tankers',
              value: '${dashboard.tankers}',
              color: appColorPrimary,
              icon: Icons.local_shipping_outlined,
              // Opened on the active ones only: the tile counts those, and a
              // list including retired vehicles would not add up to it.
              onTap: () => _push(context, const TankerListScreen(initialStatus: true)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const _SectionHeading('On the books'),
        const SizedBox(height: 8),
        _Grid(
          children: [
            StatTile(
              label: 'Active drivers',
              value: '${dashboard.drivers}',
              color: appBottomNavColor,
              icon: Icons.badge_outlined,
              onTap: () => _push(context, const DriverListScreen(initialStatus: true)),
            ),
            StatTile(
              label: 'Active customers',
              value: '${dashboard.customers}',
              color: appetitBrownColor,
              icon: Icons.people_outline,
              onTap: () => _push(context, const CustomerListScreen(initialStatus: true)),
            ),
          ],
        ),
      ],
    );
  }
}

/// The owner's live queue. Everything still to be delivered, newest first; a
/// delivered or cancelled order is simply absent from the next fetch, so it
/// leaves here on its own while the Orders tab keeps every order there is.
class _OpenOrders extends ConsumerWidget {
  const _OpenOrders({required this.dashboard});

  final AdminDashboard dashboard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = dashboard.openOrders;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Expanded(child: _SectionHeading('Orders to deliver')),
              if (orders.isNotEmpty)
                TextButton(
                  // Moves the shell to the Orders tab rather than pushing a
                  // second copy of it — see ShellTabs.selectLabel.
                  onPressed: () => ref.read(shellTabsProvider.notifier).selectLabel('Orders'),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 28),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('All orders', style: TextStyle(fontSize: 12.5)),
                ),
            ],
          ),
        ),
        if (orders.isEmpty)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Text(
              'Nothing outstanding. New orders appear here until they are delivered.',
              style: TextStyle(color: appTextColorSecondary, fontSize: 13),
            ),
          )
        else ...[
          const SizedBox(height: 4),
          for (final order in orders)
            OrderListTile(
              order: order,
              // Looking across everybody, so the customer leads the row and
              // the driver — or "Unassigned" — sits in the footer.
              showParties: true,
              // Assigning or cancelling happens on the detail screen, so the
              // list is re-read when it closes rather than left stale.
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(
                    builder: (_) => AdminOrderDetailScreen(orderId: order.id),
                  ))
                  .then((_) => ref.read(adminDashboardControllerProvider.notifier).refresh()),
            ),
          if (dashboard.hasMoreOpenThanShown)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                'Showing the latest ${orders.length} of ${dashboard.openTotal} outstanding.',
                style: const TextStyle(color: appTextColorSecondary, fontSize: 12.5),
              ),
            ),
        ],
      ],
    );
  }
}

/// Grouping the figures under headings is what makes this read as a dashboard
/// rather than a wall of numbers.
class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: appTextColorSecondary,
      ),
    );
  }
}

/// Two columns of short tiles. `shrinkWrap` because the page itself is the
/// scroller — each section is a block in one list, not a grid of its own.
class _Grid extends StatelessWidget {
  const _Grid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      // Short cards, as asked. The tile needs ~66px for a one-line label plus
      // the value, so this must not go above about 1.95 on a narrow phone —
      // `test/shared/stat_tile_test.dart` holds that line.
      childAspectRatio: 1.95,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: children,
    );
  }
}
