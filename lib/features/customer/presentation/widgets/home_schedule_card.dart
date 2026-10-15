import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/colors.dart';
import '../../domain/delivery_schedule.dart';

/// "Next tanker: Thursday" — the Home screen's view of the customer's own
/// standing-order routine, tapping through to My Deliveries.
class HomeScheduleCard extends StatelessWidget {
  const HomeScheduleCard({super.key, required this.schedule, required this.onTap});

  final DeliverySchedule schedule;
  final VoidCallback onTap;

  static final _dateFormat = DateFormat('EEEE, d MMM');

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: appColorPrimary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            const Icon(Icons.event_repeat, color: appColorPrimary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(schedule.pattern, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    schedule.isPaused
                        ? 'Routine paused'
                        : schedule.nextDeliveryDate == null
                            ? 'No delivery scheduled'
                            : 'Next tanker: ${_dateFormat.format(schedule.nextDeliveryDate!)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
