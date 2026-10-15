import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../models/upcoming_delivery_date.dart';

/// One row of an upcoming-deliveries list — the customer's own "My
/// Deliveries", or the admin looking at any schedule's. `canSkip` and its
/// reason come straight from the server's `SkipWindow`, so the button here
/// can never allow a tap the backend would refuse — it just mirrors the
/// decision already made for whoever is asking.
class UpcomingDateTile extends StatelessWidget {
  const UpcomingDateTile({
    super.key,
    required this.date,
    required this.busy,
    required this.onSkip,
    required this.onRestore,
  });

  final UpcomingDeliveryDate date;
  final bool busy;
  final VoidCallback onSkip;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: appetitAppContainerColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date.dateLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  date.skipped ? 'Skipped${date.skipReason != null ? ' — ${date.skipReason}' : ''}' : date.statusLabel,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          _action(context),
        ],
      ),
    );
  }

  Widget _action(BuildContext context) {
    if (busy) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2.4),
      );
    }

    if (date.skipped) {
      return TextButton(onPressed: onRestore, child: const Text('Restore'));
    }

    return Tooltip(
      message: date.canSkip ? '' : (date.skipBlockedReason ?? ''),
      child: TextButton(
        onPressed: date.canSkip ? onSkip : null,
        child: const Text('Skip'),
      ),
    );
  }
}
