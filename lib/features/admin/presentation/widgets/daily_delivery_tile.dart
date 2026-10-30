import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/colors.dart';
import '../../domain/daily_delivery_row.dart';
import 'admin_pill.dart';

/// One day of the Daily Delivery Summary, as a card rather than a row of a
/// seven-column table.
///
/// A `DataTable` of seven columns on a phone is a sideways scroll where the
/// date leaves the screen before the money arrives, so no figure can be read
/// against the day that produced it. The card keeps the master-data anatomy
/// the rest of the app uses — cream 15px, 4px spine, bold lead line — and
/// puts **the day first, then the money, then the work**.
///
/// Two conventions it inherits rather than invents:
///
/// * a day with deliveries but no revenue says **"Not priced yet"**, never
///   "₹ 0": a tanker with no `tanker_rate` prices at nothing, and the panel
///   and the app both write that in words (CLAUDE.md, Business rules);
/// * a day with **no trade at all** is grey and says so. Nothing happened is
///   a fact to notice, not an error to flag.
class DailyDeliveryTile extends StatelessWidget {
  const DailyDeliveryTile({super.key, required this.row});

  final DailyDeliveryRow row;

  /// Indian grouping — a day's revenue runs to five or six figures, and
  /// 1,45,000 reads at a glance where 145000 does not.
  static final _money = NumberFormat.decimalPattern('en_IN');
  static final _weekday = DateFormat('EEEE');

  @override
  Widget build(BuildContext context) {
    // A day that only lost orders is the one worth catching the eye; a day
    // with nothing at all is grey, because nothing happened is not an error.
    final Color accent;

    if (row.traded) {
      accent = statusDeliveredColor;
    } else if (row.cancelled > 0) {
      accent = statusCancelledColor;
    } else {
      accent = iconColorSecondary;
    }

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
                      if (row.traded) ...[
                        const SizedBox(height: 8),
                        _footer(),
                      ],
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
                row.dateLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              if (row.date != null)
                Text(
                  _weekday.format(row.date!),
                  style: const TextStyle(fontSize: 11.5, color: appTextColorSecondary),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // The day's headline figure, right-aligned so a column of days reads
        // down as one column of money.
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // FittedBox because "₹ 1,45,000" against a long weekday is the
              // wordiest real case on a narrow phone, not a sample.
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  _revenueLine(),
                  maxLines: 1,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: row.traded ? 16 : 12.5,
                    fontWeight: FontWeight.w700,
                    color: row.traded ? accent : appTextColorSecondary,
                  ),
                ),
              ),
              if (row.traded)
                const Text(
                  'revenue',
                  style: TextStyle(fontSize: 10.5, color: appTextColorSecondary),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _revenueLine() {
    if (!row.traded) return 'No deliveries';
    if (row.revenueIsUnpriced) return 'Not priced yet';

    return '₹ ${_money.format(row.revenue)}';
  }

  Widget _pills() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        AdminPill(label: '${row.delivered} delivered', color: statusDeliveredColor),
        AdminPill(label: '${row.orders} placed', color: appColorPrimary),
        if (row.cancelled > 0)
          AdminPill(label: '${row.cancelled} cancelled', color: statusCancelledColor),
        if (row.tankers > 0)
          AdminPill(
            // A count of tanker-loads, never litres.
            label: row.tankers == 1 ? '1 tanker' : '${row.tankers} tankers',
            color: appetitBrownColor,
          ),
      ],
    );
  }

  /// The refill cost on its own line, beneath the revenue it was spent to
  /// earn — stated, not subtracted. The server reports no margin, and a
  /// figure this screen invented would be the one the owner quoted.
  Widget _footer() {
    return Row(
      children: [
        const Icon(Icons.local_gas_station_outlined, size: 14, color: appTextColorSecondary),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            row.refillCost > 0
                ? 'Refills cost ₹ ${_money.format(row.refillCost)}'
                : 'No refill charge recorded',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11.5, color: appTextColorSecondary),
          ),
        ),
      ],
    );
  }
}
