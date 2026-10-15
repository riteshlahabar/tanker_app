import 'package:flutter/material.dart';

import '../models/order_status.dart';

/// A small coloured chip for an order's status — the one place status colour
/// is applied, so My Orders, Order Detail and the timeline can never show a
/// status in a colour the others don't.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, required this.label});

  final OrderStatus status;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: status.color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
