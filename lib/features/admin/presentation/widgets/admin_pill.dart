import 'package:flutter/material.dart';

/// A small tinted pill — the status chip's shape, without tying it to an
/// order status.
///
/// Lifted out of [DriverListTile], which had it as a private `_Pill`, once the
/// customer, filling-point, standing-order and delivery-slot cards all wanted
/// the same thing. Four private copies is how four of them end up with four
/// different paddings.
class AdminPill extends StatelessWidget {
  const AdminPill({super.key, required this.label, required this.color});

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
