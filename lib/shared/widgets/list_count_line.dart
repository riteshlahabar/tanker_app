import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

/// How many rows the current filters match. Without it a list is just "some
/// drivers" — the count is what tells the owner whether a filter did what they
/// expected.
class ListCountLine extends StatelessWidget {
  const ListCountLine({
    super.key,
    required this.total,
    required this.singular,
    required this.plural,
  });

  final int total;
  final String singular;
  final String plural;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 6, 16, 2),
        child: Text(
          total == 1 ? '1 $singular' : '$total $plural',
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
            color: appTextColorSecondary,
          ),
        ),
      ),
    );
  }
}
