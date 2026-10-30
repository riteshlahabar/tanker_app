import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/order_alerts_controller.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/colors.dart';
import '../../features/auth/presentation/providers/session_controller.dart';
import '../../features/auth/presentation/providers/session_state.dart';
import '../models/order.dart';

/// The ringing order, drawn above everything.
///
/// It is mounted from `MaterialApp.builder`, which puts it **outside** the
/// Navigator rather than inside a screen. That is the point: the owner's rule
/// is that it rings until the order is seen, and a banner living in the shell
/// would be hidden the moment the recipient pushed any detail screen — which
/// is exactly what they do while they are being rung at.
///
/// Because it sits outside the Navigator, Open pushes through
/// [AppRouter.navigatorKey] rather than through this context.
class OrderAlertOverlay extends ConsumerWidget {
  const OrderAlertOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderAlertsControllerProvider);
    final order = state.loudest;

    return Stack(
      children: [
        child,
        if (order != null)
          Positioned(
            // Below the app bar rather than over it, so the screen's own
            // title and back arrow stay usable while it is up.
            top: MediaQuery.paddingOf(context).top + kToolbarHeight + 8,
            left: 12,
            right: 12,
            child: _AlertCard(
              order: order,
              waiting: state.alerts.length,
              ringing: state.ringing,
            ),
          ),
      ],
    );
  }
}

class _AlertCard extends ConsumerWidget {
  const _AlertCard({
    required this.order,
    required this.waiting,
    required this.ringing,
  });

  final Order order;
  final int waiting;
  final bool ringing;

  Future<void> _open(WidgetRef ref) async {
    final navigator = AppRouter.navigatorKey.currentState;
    final session = ref.read(sessionControllerProvider);
    final role = session is SessionSignedIn ? session.user.role : null;

    // Marked seen before the push, not after: the noise should stop on the
    // tap. markSeen is idempotent on the panel, so the detail screen's own
    // call landing a moment later changes nothing.
    await ref.read(orderAlertsControllerProvider.notifier).markSeen(order.id);

    await navigator?.push(AppRouter.orderDetailRoute(order.id, role));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(orderAlertsControllerProvider.notifier);

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      color: statusCancelledColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  ringing ? Icons.notifications_active : Icons.notifications_none,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    waiting > 1 ? 'New order — $waiting waiting' : 'New order',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              order.customerName ?? order.orderNo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            Text(
              order.deliveryAddress,
              // Two lines: a real address in Nagpur is longer than a sample.
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 12.5),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  // Stop acknowledges the lot — the owner asked for a Stop,
                  // and a stop that left the order unseen would re-ring on
                  // the next poll and teach the driver to ignore it.
                  onPressed: () => controller.stopAll(),
                  style: TextButton.styleFrom(foregroundColor: Colors.white70),
                  child: const Text('Stop'),
                ),
                const SizedBox(width: 4),
                FilledButton(
                  onPressed: () => _open(ref),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: statusCancelledColor,
                  ),
                  child: const Text('Open'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
