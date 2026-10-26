import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../shared/models/spot.dart';
import 'admin_pill.dart';

/// One row of the admin's Filling Points list.
///
/// The master-data card again: cream, 15px, a 4px spine. The spine is the
/// *point's own* state — active or not — while "Unavailable today" is a pill,
/// because the two mean different things and the owner flips the second far
/// more often than the first.
///
/// The contact mobile is on the card deliberately. It is now required on every
/// filling point, and it is what a driver standing at a shut gate needs; a row
/// that showed only a name and a charge made them open the record to find it.
class SpotAdminListTile extends StatelessWidget {
  const SpotAdminListTile({super.key, required this.spot, required this.onTap});

  final Spot spot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = spot.status ? statusDeliveredColor : statusCancelledColor;
    final address = spot.address?.trim();

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
                            const Icon(
                              Icons.water_drop_outlined,
                              size: 17,
                              color: appTextColorPrimary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                spot.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                            ),
                            if (!spot.status) ...[
                              const SizedBox(width: 8),
                              const AdminPill(label: 'Inactive', color: statusCancelledColor),
                            ] else if (!spot.isAvailable) ...[
                              const SizedBox(width: 8),
                              const AdminPill(label: 'Unavailable', color: statusPendingColor),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          [
                            ?(address == null || address.isEmpty ? null : address),
                            ?spot.waterType,
                          ].join('  ·  '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: appTextColorSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.call_outlined,
                                    size: 14,
                                    color: appTextColorSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      [?spot.contactPerson, ?spot.contactMobile].join(' · '),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: appTextColorSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '₹ ${spot.refillCharge.toStringAsFixed(0)} / fill',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
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
