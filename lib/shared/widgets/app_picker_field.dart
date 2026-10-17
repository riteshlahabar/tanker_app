import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../core/theme/colors.dart';

/// A tappable field that opens a picker — a date, a time, a chooser sheet —
/// drawn exactly as [AppTextField] draws a text input: borderless, filled in
/// the cream container colour, clipped to a 15px radius.
///
/// Forms across the app had been reaching for a raw `InputDecorator` with an
/// `OutlineInputBorder` for this, which put an outlined grey box in the middle
/// of a column of cream fields. One widget so the two treatments cannot
/// diverge again.
///
/// [value] null draws [hint] in the hint grey, so "nothing chosen" reads the
/// same here as in a text field with no text in it.
class AppPickerField extends StatelessWidget {
  const AppPickerField({
    super.key,
    required this.label,
    required this.hint,
    required this.onTap,
    this.value,
    this.icon,
    this.onClear,
  });

  final String label;
  final String hint;
  final VoidCallback onTap;
  final String? value;
  final IconData? icon;

  /// Given, adds a clear button — for an optional choice that has to be
  /// un-choosable once made.
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chosen = value != null && value!.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.grey),
            border: InputBorder.none,
            filled: true,
            fillColor: isDark ? context.cardColor : appetitAppContainerColor,
            prefixIcon: icon == null ? null : Icon(icon, size: 20, color: Colors.grey),
            suffixIcon: chosen && onClear != null
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: onClear,
                  )
                : null,
          ),
          child: Text(
            chosen ? value! : hint,
            style: TextStyle(
              color: chosen ? appTextColorPrimary : Colors.grey,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
