import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

/// The total of an order being written, shown as a **result rather than a
/// field** — it is not something anyone types, it is what the rate and the
/// count come to.
///
/// Shared by the admin's New Order screen and the driver's, which ask for the
/// same two numbers and owe the person filling the form the same arithmetic.
/// Showing the working (`2 × ₹ 1,500`) is the point: a customer who rings up
/// about a total gets an answer rather than a figure.
class OrderTotalCard extends StatelessWidget {
  const OrderTotalCard({
    super.key,
    required this.rate,
    required this.tankers,
    required this.total,
  });

  final double rate;
  final int tankers;
  final double total;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // A rate of 0 is not a free delivery, it is a vehicle the owner has not
    // priced yet — the convention the whole app follows for an unset rate.
    final priced = rate > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : appetitAppContainerColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOTAL AMOUNT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: appTextColorSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  priced
                      ? '$tankers × ₹ ${rate.toStringAsFixed(2)}'
                      : '$tankers tanker${tankers == 1 ? '' : 's'} · no rate set',
                  style: const TextStyle(fontSize: 12, color: appTextColorSecondary),
                ),
              ],
            ),
          ),
          Text(
            priced ? '₹ ${total.toStringAsFixed(2)}' : 'Not priced yet',
            style: TextStyle(
              fontSize: priced ? 22 : 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : appColorPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
