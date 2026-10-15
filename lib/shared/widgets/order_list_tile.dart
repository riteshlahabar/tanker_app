import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/colors.dart';
import '../models/order.dart';
import 'status_chip.dart';

/// One row of an order list: order number, status, address, date and amount.
/// Used by My Orders and the Notifications feed alike.
class OrderListTile extends StatelessWidget {
  const OrderListTile({super.key, required this.order, required this.onTap});

  final Order order;
  final VoidCallback onTap;

  static final _dateFormat = DateFormat('d MMM yyyy');

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: appetitAppContainerColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.orderNo,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
                StatusChip(status: order.status, label: order.statusLabel),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              order.deliveryAddress,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.deliveryDate == null ? '—' : _dateFormat.format(order.deliveryDate!),
                  style: const TextStyle(fontSize: 13),
                ),
                Text(
                  '₹ ${order.orderAmount.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
