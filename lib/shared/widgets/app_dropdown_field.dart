import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../core/theme/colors.dart';

/// A dropdown drawn exactly as [AppTextField] draws a text input: borderless,
/// filled in the cream container colour, clipped to a 15px radius.
///
/// Forms had been reaching for a raw `DropdownButtonFormField` with an
/// `OutlineInputBorder`, which puts an outlined grey box in the middle of a
/// column of cream fields — the same fault [AppPickerField] was written to fix
/// for date and time pickers.
///
/// **`isExpanded` is baked in**, because no hand-written dropdown in this app
/// set it: without it a long option (a tanker's full label, a spot's name)
/// overflows its row instead of ellipsizing.
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.icon,
    this.validator,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final IconData? icon;
  final String? Function(T?)? validator;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        isExpanded: true,
        items: items,
        onChanged: onChanged,
        validator: validator,
        borderRadius: BorderRadius.circular(15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          filled: true,
          fillColor: isDark ? context.cardColor : appetitAppContainerColor,
          prefixIcon: icon == null ? null : Icon(icon, size: 20, color: Colors.grey),
        ),
      ),
    );
  }
}
