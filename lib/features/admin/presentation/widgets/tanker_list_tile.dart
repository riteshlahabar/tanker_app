import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/colors.dart';
import '../../domain/admin_tanker.dart';

/// One row of the admin's Tankers list.
///
/// Built to the same anatomy as [OrderListTile] — appetit's cream 15px card
/// with a 4px status-coloured spine, a bold lead line, a grey detail line and
/// a footer — so the two lists read as one app rather than two. No colour is
/// introduced: active/inactive reuse the delivered/cancelled greens and reds,
/// and anything needing the owner's attention wears the pending amber a
/// Pending chip already uses.
///
/// It leads with the **vehicle number**, not the name: a number plate is what
/// identifies a truck on the road and on an RC book, and it is what the owner
/// will be looking for.
class TankerListTile extends StatelessWidget {
  const TankerListTile({super.key, required this.tanker, required this.onTap});

  final AdminTanker tanker;
  final VoidCallback onTap;

  static final _dateFormat = DateFormat('MMM yyyy');
  static final _litres = NumberFormat.decimalPattern('en_IN');

  /// A null *or* zero rate both mean "no rate of its own" — the panel falls
  /// through to the Price per Tanker setting either way, so the card must not
  /// show a confident "₹ 0".
  bool get _rateMissing => tanker.tankerRate == null || tanker.tankerRate == 0;

  @override
  Widget build(BuildContext context) {
    final accent = tanker.status ? statusDeliveredColor : statusCancelledColor;

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
                        ..._insuranceLine(),
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

  /// The plate, plus an Inactive pill. Active needs no pill — the green spine
  /// already says so, and a badge on every row would be noise.
  Widget _titleRow() {
    return Row(
      children: [
        const Icon(Icons.local_shipping_outlined, size: 17, color: appTextColorPrimary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            tanker.vehicleNumber,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 0.3),
          ),
        ),
        if (!tanker.status) ...[
          const SizedBox(width: 8),
          const _Pill(label: 'Inactive', color: statusCancelledColor),
        ],
      ],
    );
  }

  Widget _detailRow() {
    final capacity = tanker.capacityLitres == null
        ? null
        : '${_litres.format(tanker.capacityLitres)} L';

    return Text(
      [tanker.vehicleName, ?capacity, ?tanker.modelYear?.toString()].join('  ·  '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(color: appTextColorSecondary, fontSize: 13),
    );
  }

  /// Driver on the left, the money on the right — the same split the order
  /// card uses, so the eye lands in the same place on both lists.
  Widget _footerRow() {
    final driver = tanker.currentDriver;

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.badge_outlined,
                size: 14,
                // An idle tanker is money sitting still, so it reads in the
                // pending amber rather than the same grey as everything else —
                // the convention the order card's "Unassigned" already set.
                color: driver == null ? statusPendingColor : appTextColorSecondary,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  driver ?? 'No driver assigned',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: driver == null ? statusPendingColor : appTextColorSecondary,
                    fontWeight: driver == null ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (_rateMissing)
          // The owner still has to set every tanker's rate before pricing is
          // right (CLAUDE.md, Blocked on the owner). Saying so on the row is
          // the whole reason this card is worth more than a title and a dot.
          const _Pill(label: 'Rate not set', color: statusPendingColor)
        else
          Text(
            '₹ ${tanker.tankerRate!.toStringAsFixed(0)} / tanker',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
      ],
    );
  }

  /// Only drawn when it matters. An insurance date a year out is paperwork; one
  /// that has lapsed means the vehicle should not be on the road, so it earns a
  /// line of its own and nothing else does.
  List<Widget> _insuranceLine() {
    final expiry = tanker.insuranceExpiry;

    if (expiry == null) return const [];

    final today = DateTime.now();
    final days = DateUtils.dateOnly(expiry).difference(DateUtils.dateOnly(today)).inDays;

    if (days > 30) return const [];

    final expired = days < 0;

    return [
      const SizedBox(height: 8),
      Row(
        children: [
          Icon(
            expired ? Icons.error_outline : Icons.schedule,
            size: 14,
            color: expired ? statusCancelledColor : statusPendingColor,
          ),
          const SizedBox(width: 4),
          // Flexible, or a long date on a narrow phone pushes the line off the
          // card — which is exactly what the test font caught.
          Expanded(
            child: Text(
              expired
                  ? 'Insurance expired ${_dateFormat.format(expiry)}'
                  : 'Insurance expires in $days ${days == 1 ? 'day' : 'days'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: expired ? statusCancelledColor : statusPendingColor,
              ),
            ),
          ),
        ],
      ),
    ];
  }
}

/// A small tinted pill. The status chip's shape, without tying it to
/// [OrderStatus] — a tanker has no order status to read a colour from.
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
