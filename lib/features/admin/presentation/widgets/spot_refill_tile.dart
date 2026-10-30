import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/colors.dart';
import '../../domain/spot_refill_row.dart';
import 'admin_pill.dart';

/// One filling point of the Refill Report, as a card rather than a row of a
/// six-column table.
///
/// The table put the **address** in column two, which on a phone pushes every
/// figure off the right of the screen — a real Nagpur address is longer than
/// the money it sits next to. The card keeps the master-data anatomy the rest
/// of the app uses (cream 15px, 4px spine, bold lead line), puts the name and
/// address together as one identity, and the money on the right where a
/// column of points reads down as one column of amounts.
///
/// Three zeroes told apart, the convention the Daily Summary established:
///
/// * a point **nobody used** in the range is grey and says "Not used" — a
///   quiet point is a fact to notice, not an error;
/// * a point with refills but **no cost recorded** says so, because its
///   charge was not set when the driver filled there;
/// * a **charge of 0** reads "Charge not set", never "₹ 0" — a free filling
///   point and an unconfigured one are different facts, and only one of them
///   is likely.
class SpotRefillTile extends StatelessWidget {
  const SpotRefillTile({super.key, required this.row});

  final SpotRefillRow row;

  /// Indian grouping — a range's refill cost runs to five or six figures, and
  /// 2,45,000 reads at a glance where 245000 does not.
  static final _money = NumberFormat.decimalPattern('en_IN');

  @override
  Widget build(BuildContext context) {
    final accent = row.used ? statusRefillingColor : iconColorSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Material(
        color: appetitAppContainerColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(15),
        clipBehavior: Clip.antiAlias,
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
                      _titleRow(accent),
                      const SizedBox(height: 8),
                      _pills(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _titleRow(Color accent) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                row.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              if (row.address.trim().isNotEmpty)
                Text(
                  row.address,
                  // Two lines: a real address is longer than a sample.
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: appTextColorSecondary),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  _costLine(),
                  maxLines: 1,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: row.used && !row.costMissing ? 16 : 12.5,
                    fontWeight: FontWeight.w700,
                    color: row.used && !row.costMissing ? accent : appTextColorSecondary,
                  ),
                ),
              ),
              if (row.used && !row.costMissing)
                const Text(
                  'refill cost',
                  style: TextStyle(fontSize: 10.5, color: appTextColorSecondary),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _costLine() {
    if (!row.used) return 'Not used';
    if (row.costMissing) return 'No cost recorded';

    return '₹ ${_money.format(row.refillCost)}';
  }

  Widget _pills() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        if (row.used)
          AdminPill(
            label: row.refills == 1 ? '1 refill' : '${row.refills} refills',
            color: statusRefillingColor,
          ),
        if (row.tankers > 0)
          AdminPill(
            // A count of tanker-loads, never litres.
            label: row.tankers == 1 ? '1 tanker' : '${row.tankers} tankers',
            color: appetitBrownColor,
          ),
        AdminPill(
          label: row.chargeIsSet
              ? '₹ ${_money.format(row.chargePerRefill)} / refill'
              : 'Charge not set',
          color: row.chargeIsSet ? appColorPrimary : statusPendingColor,
        ),
      ],
    );
  }
}
