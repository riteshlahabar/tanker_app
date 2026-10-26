import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../domain/admin_delivery_slot.dart';
import 'admin_pill.dart';

/// One row of the admin's Delivery Slots list.
///
/// A slot is mostly a clock face, so the window is the biggest thing on the
/// card rather than a grey subtitle under the name — "Morning" is the label
/// the office uses, but "6:00 AM – 9:00 AM" is what it means, and it is what
/// the customer picking a slot in the app actually sees.
///
/// The order number is shown because it decides the order of that dropdown,
/// and nothing else on the screen says so.
class DeliverySlotListTile extends StatelessWidget {
  const DeliverySlotListTile({super.key, required this.slot, required this.onTap});

  final AdminDeliverySlot slot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = slot.status ? statusDeliveredColor : statusCancelledColor;

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
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: appColorPrimary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.schedule_outlined,
                            size: 20,
                            color: appColorPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      slot.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  if (!slot.status) ...[
                                    const SizedBox(width: 8),
                                    const AdminPill(
                                      label: 'Inactive',
                                      color: statusCancelledColor,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                slot.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: appTextColorSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '#${slot.sortOrder}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: appTextColorSecondary,
                            fontWeight: FontWeight.w600,
                          ),
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
