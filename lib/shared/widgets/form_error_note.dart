import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

/// A server-side refusal, in the design's own red rather than a raw
/// `Colors.red`, and in a tinted box so it is not mistaken for a field label.
class FormErrorNote extends StatelessWidget {
  const FormErrorNote(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusCancelledColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 18, color: statusCancelledColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: statusCancelledColor, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
