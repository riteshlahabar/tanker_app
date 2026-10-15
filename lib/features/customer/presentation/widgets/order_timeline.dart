import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../shared/models/order_status_log_entry.dart';

/// A vertical stepper built from the order's status log — the "order
/// tracking timeline" the owner asked for, read straight off
/// `OrderStatusLogResource` so it can never disagree with the order's own
/// status.
class OrderTimeline extends StatelessWidget {
  const OrderTimeline({super.key, required this.entries});

  final List<OrderStatusLogEntry> entries;

  static final _dateTimeFormat = DateFormat('d MMM, h:mm a');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < entries.length; i++) _row(entries[i], isLast: i == entries.length - 1),
      ],
    );
  }

  Widget _row(OrderStatusLogEntry entry, {required bool isLast}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(color: entry.status.color, shape: BoxShape.circle),
              ),
              if (!isLast)
                Container(width: 2, height: 36, color: entry.status.color.withValues(alpha: 0.3)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (entry.at != null)
                    Text(
                      _dateTimeFormat.format(entry.at!),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  if (entry.note != null && entry.note!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(entry.note!, style: const TextStyle(fontSize: 13)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
