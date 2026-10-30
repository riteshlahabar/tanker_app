import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/duty_controller.dart';
import '../../core/theme/colors.dart';

/// The on-duty switch, and the honest statement of what it can and cannot do.
///
/// The owner asked for a toggle so a driver off shift is not holding a
/// service open. The paragraph under it is not filler: the service is the
/// only reason the phone rings while the app is closed, and Xiaomi, Oppo,
/// Vivo and Realme kill background services unless the app is allowed to run
/// in the background. A driver who is not told that will believe the phone is
/// listening when it is not — which is the single failure this whole feature
/// exists to prevent.
class OnDutyCard extends ConsumerWidget {
  const OnDutyCard({super.key});

  Future<void> _set(BuildContext context, WidgetRef ref, bool value) async {
    final problem = await ref.read(dutyControllerProvider.notifier).setOnDuty(value);

    if (problem == null || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(problem)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duty = ref.watch(dutyControllerProvider);

    // A customer is never rung, so there is nothing here to offer them.
    if (!duty.available) return const SizedBox.shrink();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  duty.onDuty ? Icons.notifications_active : Icons.notifications_off_outlined,
                  color: duty.onDuty ? statusDeliveredColor : appTextColorSecondary,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Ring me for new orders', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
                Switch(
                  value: duty.onDuty,
                  onChanged: duty.busy ? null : (value) => _set(context, ref, value),
                ),
              ],
            ),
            Text(
              duty.onDuty
                  ? 'WTMS will ring even when the app is closed. An "On duty" '
                      'notification stays in the shade while it is watching — '
                      'that notification is what keeps the ringing alive, so it '
                      'cannot be swiped away.'
                  : 'With this off, WTMS only rings while the app is open on '
                      'screen. Turn it on at the start of your shift.',
              style: const TextStyle(fontSize: 12.5, color: appTextColorSecondary, height: 1.35),
            ),
            if (duty.onDuty) ...[
              const SizedBox(height: 8),
              const Text(
                'On a Xiaomi, Oppo, Vivo or Realme phone also allow WTMS to run '
                'in the background and remove it from battery saving, or the '
                'phone will stop it after a while without saying so.',
                style: TextStyle(fontSize: 12.5, color: statusPendingColor, height: 1.35),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
