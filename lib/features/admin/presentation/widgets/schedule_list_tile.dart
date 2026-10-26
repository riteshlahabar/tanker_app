import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/colors.dart';
import '../../domain/admin_schedule.dart';
import 'admin_pill.dart';

/// One row of the admin's Standing Orders list.
///
/// A routine is read for three things, so the card answers all three without
/// being opened: whose it is, how often it runs, and **when the next one
/// lands**. The next date is the figure the office actually checks, so it sits
/// where the money sits on the other master-data cards.
///
/// Paused is a pill rather than a spine colour: a paused routine is still an
/// active one, and the spine is kept for active/inactive so it means the same
/// thing on every list.
class ScheduleListTile extends StatelessWidget {
  const ScheduleListTile({super.key, required this.schedule, required this.onTap});

  final AdminSchedule schedule;
  final VoidCallback onTap;

  static final _dateFormat = DateFormat('EEE, d MMM');

  @override
  Widget build(BuildContext context) {
    final accent = !schedule.status
        ? statusCancelledColor
        : schedule.isPaused
            ? statusPendingColor
            : statusDeliveredColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Material(
        color: appetitAppContainerColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(15),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: accent),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.event_repeat, size: 17, color: appTextColorPrimary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                schedule.customerName ?? 'Customer #${schedule.customerId}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                            ),
                            if (!schedule.status) ...[
                              const SizedBox(width: 8),
                              const AdminPill(label: 'Inactive', color: statusCancelledColor),
                            ] else if (schedule.isPaused) ...[
                              const SizedBox(width: 8),
                              const AdminPill(label: 'Paused', color: statusPendingColor),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          [
                            schedule.pattern,
                            ?schedule.deliverySlot,
                            if (schedule.tankerCount != null) schedule.tankerLabel,
                          ].join('  ·  '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: appTextColorSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.local_shipping_outlined,
                                    size: 14,
                                    color: schedule.preferredDriver == null
                                        ? statusPendingColor
                                        : appTextColorSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      schedule.preferredDriver ?? 'Assigned by admin',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: schedule.preferredDriver == null
                                            ? statusPendingColor
                                            : appTextColorSecondary,
                                        fontWeight: schedule.preferredDriver == null
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              schedule.nextDeliveryDate == null
                                  ? 'Finished'
                                  : 'Next ${_dateFormat.format(schedule.nextDeliveryDate!)}',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
