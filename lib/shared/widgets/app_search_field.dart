import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

/// The app's borderless cream search input.
///
/// [AppTextField] is not used because it puts a label above the field, which
/// a single-line search row does not want. Material's outlined box is not
/// used either: it was the one grey-outlined control left on a page of cream
/// ones.
///
/// Submitting applies the search — searching on every keystroke would fire a
/// request per letter at a report that aggregates over a date range. The
/// clear button appears only once there is something to clear, and clearing
/// applies immediately, because an empty box that still filters is the bug
/// everyone hits.
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onSubmitted;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: TextField(
        controller: widget.controller,
        textInputAction: TextInputAction.search,
        onSubmitted: widget.onSubmitted,
        // Redraws so the clear button appears and disappears with the text.
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13.5),
          prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
          suffixIcon: widget.controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                  onPressed: () {
                    widget.controller.clear();
                    widget.onSubmitted('');
                  },
                ),
          border: InputBorder.none,
          filled: true,
          fillColor:
              isDark ? Theme.of(context).cardColor : appetitAppContainerColor.withValues(alpha: 0.6),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
