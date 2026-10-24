import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/colors.dart';
import '../../domain/admin_driver.dart';

/// One row of the admin's Drivers list.
///
/// Deliberately the same anatomy as [TankerListTile] and [OrderListTile] —
/// appetit's cream 15px card with a 4px status-coloured spine, a bold lead
/// line, a grey detail line and a footer — so the master-data lists read as one
/// app rather than one screen per module. No colour is introduced: active and
/// inactive reuse the delivered/cancelled green and red, and anything needing
/// the owner's attention wears the amber a Pending chip already uses.
///
/// It replaces an [EntityListTile] whose single grey subtitle crammed the
/// mobile, the salary and the tanker into one line, which threw away the
/// distinction between a figure that is set and one that is still zero.
///
/// A leading icon, not an initials avatar: the card keeps [TankerListTile]'s
/// proven 320px geometry, where an avatar's 50-odd pixels would squeeze the
/// footer's money against the tanker name.
class DriverListTile extends StatelessWidget {
  const DriverListTile({super.key, required this.driver, required this.onTap});

  final AdminDriver driver;
  final VoidCallback onTap;

  /// Indian grouping: a salary is a five- or six-figure number, so 1,20,000
  /// reads at a glance where 120000 does not.
  static final _money = NumberFormat.decimalPattern('en_IN');

  @override
  Widget build(BuildContext context) {
    final accent = driver.status ? statusDeliveredColor : statusCancelledColor;

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
                        _titleRow(),
                        const SizedBox(height: 6),
                        _detailRow(),
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

  /// The driver's name, plus an Inactive pill. Active needs no pill — the green
  /// spine already says so, and a badge on every row would be noise.
  Widget _titleRow() {
    return Row(
      children: [
        const Icon(Icons.person_outline, size: 17, color: appTextColorPrimary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            driver.fullName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
        if (!driver.status) ...[
          const SizedBox(width: 8),
          const _Pill(label: 'Inactive', color: statusCancelledColor),
        ],
      ],
    );
  }

  /// The mobile leads: it is both how the office rings the driver and the
  /// identity they log into the app with, so it is the one field worth reading
  /// off the row.
  Widget _detailRow() {
    final address = driver.address?.trim();

    return Text(
      [driver.mobile, ?(address == null || address.isEmpty ? null : address)].join('  ·  '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(color: appTextColorSecondary, fontSize: 13),
    );
  }

  /// The vehicle on the left, the money on the right — the same split the order
  /// and tanker cards use, so the eye lands in the same place on every list.
  Widget _footerRow() {
    final tanker = driver.tanker;

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.local_shipping_outlined,
                size: 14,
                // A driver with no tanker cannot be given an order at all, so
                // it reads in the pending amber rather than the same grey as
                // everything else — the convention the order card's
                // "Unassigned" set and the tanker card's "No driver assigned"
                // mirrors from the other side.
                color: tanker == null ? statusPendingColor : appTextColorSecondary,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  tanker?.label ?? 'No tanker assigned',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: tanker == null ? statusPendingColor : appTextColorSecondary,
                    fontWeight: tanker == null ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (driver.monthlySalary == 0)
          // Every driver landed on zero when the per-delivery rate was dropped
          // for a monthly salary, and the owner still has to set each real
          // figure (CLAUDE.md, Blocked on the owner). A confident "₹ 0 / mo"
          // would read as a decision rather than an omission.
          const _Pill(label: 'Salary not set', color: statusPendingColor)
        else
          Text(
            '₹ ${_money.format(driver.monthlySalary)} / mo',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
      ],
    );
  }
}

/// A small tinted pill. The status chip's shape, without tying it to
/// [OrderStatus] — a driver has no order status to read a colour from.
class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w600),
      ),
    );
  }
}
