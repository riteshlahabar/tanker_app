import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../core/theme/colors.dart';

/// The design's text input, exactly as the appetit login screen draws it: a
/// borderless filled field in the cream container colour, clipped to a 15px
/// radius, grey label and hint.
///
/// Every form in the app uses this, so the input treatment is defined once.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.errorText,
    this.enabled = true,
    this.maxLines = 1,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  /// A server-side complaint for this field (a 422), shown under the input.
  final String? errorText;

  final bool enabled;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            obscureText: obscureText,
            validator: validator,
            onChanged: onChanged,
            enabled: enabled,
            maxLines: obscureText ? 1 : maxLines,
            decoration: InputDecoration(
              labelStyle: const TextStyle(color: Colors.grey),
              border: InputBorder.none,
              labelText: label,
              hintText: hint,
              filled: true,
              fillColor: isDark ? context.cardColor : appetitAppContainerColor,
              hintStyle: const TextStyle(color: Colors.grey),
              suffixIcon: suffixIcon,
              // The field carries its own error line below, so the decoration
              // does not reserve a second one.
              errorStyle: const TextStyle(height: 0, fontSize: 0),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              errorText!,
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
