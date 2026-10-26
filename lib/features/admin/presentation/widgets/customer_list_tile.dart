import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../domain/admin_customer.dart';
import 'admin_pill.dart';

/// One row of the admin's Customers list.
///
/// The same anatomy as [DriverListTile] and [TankerListTile] — appetit's cream
/// 15px card with a 4px status-coloured spine, a bold lead line, a grey detail
/// line and a footer — so the master-data lists read as one app.
///
/// It replaces an [EntityListTile] whose one grey subtitle ran the mobile and
/// " · Standing order" together, which buried the single most consequential
/// fact about a customer: whether they may order at all. That is now a pill,
/// because it decides what the app does when they tap Book a Tanker.
class CustomerListTile extends StatelessWidget {
  const CustomerListTile({super.key, required this.customer, required this.onTap});

  final AdminCustomer customer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = customer.status ? statusDeliveredColor : statusCancelledColor;
    final address = customer.address?.trim();

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
                            const Icon(Icons.person_outline, size: 17, color: appTextColorPrimary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                customer.fullName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                            ),
                            if (!customer.status) ...[
                              const SizedBox(width: 8),
                              const AdminPill(label: 'Inactive', color: statusCancelledColor),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          customer.mobile,
                          style: const TextStyle(color: appTextColorSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 14,
                                    // An address-less customer produces an
                                    // order the driver cannot find, so it
                                    // reads in the pending amber the other
                                    // cards use for "needs attention".
                                    color: (address == null || address.isEmpty)
                                        ? statusPendingColor
                                        : appTextColorSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      (address == null || address.isEmpty)
                                          ? 'No address on file'
                                          : address,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: (address == null || address.isEmpty)
                                            ? statusPendingColor
                                            : appTextColorSecondary,
                                        fontWeight: (address == null || address.isEmpty)
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            AdminPill(
                              label: customer.canSelfOrder ? 'Orders in app' : 'Standing order',
                              color: customer.canSelfOrder ? appColorPrimary : appetitBrownColor,
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
