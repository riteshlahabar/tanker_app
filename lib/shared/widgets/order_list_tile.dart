import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/colors.dart';
import '../models/order.dart';
import 'status_chip.dart';

/// One row of an order list: order number, status, address, date and amount.
/// Used by My Orders, the driver's Orders, the admin's list and the
/// Notifications feed alike.
///
/// The card is appetit's (15px radius, cream container). What carries the
/// weight is the status-coloured spine down the left edge — a list of twenty
/// orders is read by scanning, and colour does that faster than reading six
/// chips. The colour is the status chip's own, so the spine and the chip can
/// never disagree.
class OrderListTile extends StatelessWidget {
  const OrderListTile({
    super.key,
    required this.order,
    required this.onTap,
    this.showParties = false,
  });

  final Order order;
  final VoidCallback onTap;

  /// The admin is looking across everybody's orders, so they need to see who
  /// placed it and who is carrying it. A customer reading their own list
  /// already knows both.
  final bool showParties;

  static final _dateFormat = DateFormat('d MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final accent = order.status.color;

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
                // The spine. 4px of the status colour, full height of the card.
                Container(width: 4, color: accent),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _titleRow(),
                        const SizedBox(height: 6),
                        _addressRow(),
                        const SizedBox(height: 10),
                        _footerRow(),
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

  /// The admin leads with the customer, since the order number means nothing
  /// to them at a glance; everybody else leads with the reference.
  Widget _titleRow() {
    final lead = showParties ? (order.customerName ?? order.orderNo) : order.orderNo;

    return Row(
      children: [
        Expanded(
          child: Text(
            lead,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
        const SizedBox(width: 8),
        StatusChip(status: order.status, label: order.statusLabel),
      ],
    );
  }

  Widget _addressRow() {
    // With the customer on the title line the reference moves down here, so
    // it is still one tap away from being read out over the phone.
    final line = showParties && order.customerName != null
        ? '${order.orderNo}  ·  ${order.deliveryAddress}'
        : order.deliveryAddress;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.place_outlined, size: 14, color: appTextColorSecondary),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            line,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: appTextColorSecondary, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _footerRow() {
    final date = order.deliveryDate == null ? '—' : _dateFormat.format(order.deliveryDate!);
    // "Unassigned" is the admin's cue to act, so it is said rather than left
    // as a blank where a name would be.
    final driver = showParties ? (order.driverName ?? 'Unassigned') : order.driverName;

    return Row(
      children: [
        // The date and driver share whatever is left after the amount, so a
        // long driver name ellipsises instead of pushing the money off-screen.
        Expanded(
          child: Row(
            children: [
              const Icon(Icons.event_outlined, size: 14, color: appTextColorSecondary),
              const SizedBox(width: 4),
              Text(date, style: const TextStyle(fontSize: 12.5, color: appTextColorSecondary)),
              if (driver != null) ...[
                const SizedBox(width: 10),
                const Icon(Icons.badge_outlined, size: 14, color: appTextColorSecondary),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    driver,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      // An unassigned order is work waiting on the owner, so it
                      // reads in the pending amber rather than the same grey as
                      // everything else.
                      color: order.driverName == null ? statusPendingColor : appTextColorSecondary,
                      fontWeight:
                          order.driverName == null ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          order.amountLabel,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ],
    );
  }
}
