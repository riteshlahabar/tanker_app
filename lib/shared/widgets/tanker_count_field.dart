import 'package:flutter/material.dart';

/// How many tanker-loads a delivery is for.
///
/// Water is sold by the tanker, not by the litre, so this is a count — a
/// picker rather than a free-text box, which also keeps every form inside the
/// server's 1–20 rule without each one repeating the validation.
class TankerCountField extends StatelessWidget {
  const TankerCountField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Number of tankers',
  });

  final int value;
  final ValueChanged<int> onChanged;
  final String label;

  /// The server accepts up to 20, but a list that long is unusable on a phone
  /// and nobody orders ten tankers at once; raise it if that turns out wrong.
  static const int maxTankers = 10;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        for (var count = 1; count <= maxTankers; count++)
          DropdownMenuItem(
            value: count,
            child: Text('$count tanker${count == 1 ? '' : 's'}'),
          ),
      ],
      onChanged: (chosen) {
        if (chosen != null) onChanged(chosen);
      },
    );
  }
}
