import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/shell_tabs_controller.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/models/order.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../../auth/presentation/providers/session_controller.dart';
import '../../../auth/presentation/providers/session_state.dart';
import '../providers/my_orders_controller.dart';
import '../providers/my_schedule_controller.dart';
import '../widgets/home_schedule_card.dart';
import 'book_tanker_screen.dart';
import 'my_deliveries_screen.dart';
import 'order_detail_screen.dart';

/// The customer's Home.
///
/// Built around the one thing they open the app to find out — *where is my
/// water* — rather than a greeting and a button. The order in flight is the
/// headline, with its status on it; the routine, when they are on one, sits
/// under it; and booking is one tap from anywhere on the screen.
class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  static final _today = DateFormat('EEEE, d MMMM');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final user = session is SessionSignedIn ? session.user : null;
    final scheduleState = ref.watch(myScheduleControllerProvider);
    final ongoing = ref.watch(myOrdersControllerProvider(true));
    final open = ongoing.paginated.items;
    final canOrder = user?.canSelfOrder ?? true;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(myScheduleControllerProvider.notifier).refresh();
        await ref.read(myOrdersControllerProvider(true).notifier).refresh();
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          _Greeting(name: user?.firstName ?? '', today: _today.format(DateTime.now())),
          const SizedBox(height: 18),

          if (open.isEmpty)
            _NothingInFlightCard(
              canOrder: canOrder,
              onBook: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BookTankerScreen()),
              ),
            )
          else ...[
            const _Heading('IN FLIGHT'),
            for (final order in open.take(3))
              _OpenOrderCard(
                order: order,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: order.id)),
                ),
              ),
          ],

          if (scheduleState.data?.schedule != null) ...[
            const SizedBox(height: 18),
            const _Heading('YOUR ROUTINE'),
            HomeScheduleCard(
              schedule: scheduleState.data!.schedule!,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyDeliveriesScreen()),
              ),
            ),
          ],

          const SizedBox(height: 18),
          const _Heading('QUICK'),
          Row(
            children: [
              if (canOrder) ...[
                Expanded(
                  child: _QuickTile(
                    icon: Icons.add_circle_outline,
                    label: 'Book a\ntanker',
                    colour: appColorPrimary,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const BookTankerScreen()),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: _QuickTile(
                  icon: Icons.receipt_long_outlined,
                  label: 'My\norders',
                  colour: appetitBrownColor,
                  onTap: () => ref.read(shellTabsProvider.notifier).selectLabel('My Orders'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickTile(
                  icon: Icons.currency_rupee,
                  label: 'My\nbilling',
                  colour: statusDeliveredColor,
                  onTap: () => ref.read(shellTabsProvider.notifier).selectLabel('Billing'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: appTextColorSecondary,
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.name, required this.today});

  final String name;
  final String today;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
                  today.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  name.isEmpty ? 'Hello' : 'Hello, $name',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.water_drop, color: Colors.white24, size: 44),
        ],
      ),
    );
  }
}

/// An order on its way, with where it has got to. The status is the point of
/// the card, so it is a chip rather than a word in a subtitle.
class _OpenOrderCard extends StatelessWidget {
  const _OpenOrderCard({required this.order, required this.onTap});

  final Order order;
  final VoidCallback onTap;

  static final _dateFormat = DateFormat('d MMM');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? Theme.of(context).cardColor
              : appetitAppContainerColor.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.orderNo,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                StatusChip(status: order.status, label: order.statusLabel),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.water_drop_outlined, size: 15, color: appTextColorSecondary),
                const SizedBox(width: 6),
                Text(
                  order.tankerCount == null ? '—' : order.tankerLabel,
                  style: const TextStyle(fontSize: 12.5, color: appTextColorSecondary),
                ),
                if (order.deliveryDate != null) ...[
                  const SizedBox(width: 14),
                  const Icon(Icons.event_outlined, size: 15, color: appTextColorSecondary),
                  const SizedBox(width: 6),
                  Text(
                    _dateFormat.format(order.deliveryDate!),
                    style: const TextStyle(fontSize: 12.5, color: appTextColorSecondary),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              order.deliveryAddress,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12.5, color: appTextColorSecondary),
            ),
            if (order.driverName != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.local_shipping_outlined, size: 15, color: appColorPrimary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${order.driverName} is delivering',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: appColorPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    order.amountLabel,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Nothing on the way — which is a state worth drawing properly, since for a
/// customer who orders once a week it is most of what they see.
class _NothingInFlightCard extends StatelessWidget {
  const _NothingInFlightCard({required this.canOrder, required this.onBook});

  final bool canOrder;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).cardColor
            : appetitAppContainerColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(Icons.water_drop_outlined, size: 36, color: appColorPrimary),
          const SizedBox(height: 10),
          const Text(
            'No tanker on the way',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            canOrder
                ? 'Book one and you can follow it from here.'
                : 'Your deliveries are on a routine the office manages.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12.5, color: appTextColorSecondary),
          ),
          if (canOrder) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onBook,
                icon: const Icon(Icons.add_circle_outline, size: 19),
                label: const Text('Book a Tanker'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColorPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.label,
    required this.colour,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color colour;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: colour.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, color: colour, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colour),
            ),
          ],
        ),
      ),
    );
  }
}
