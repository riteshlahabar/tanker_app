import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/sheet_body.dart';

/// One choice from a short, already-loaded list — a filling point or a
/// tanker, on the reports screen.
///
/// It replaces a bare `DropdownButton`, which on a narrow phone clips its
/// longest item without warning (the trap CLAUDE.md names, and the reason
/// four dropdowns still owe an `isExpanded`). A sheet has the whole width,
/// shows the "Any" choice as a row rather than a blank first item, and reads
/// as the app's cream card like every other picker in the app.
class ReportOptionSheet extends StatelessWidget {
  const ReportOptionSheet({
    super.key,
    required this.title,
    required this.anyLabel,
    required this.options,
    this.selectedId,
  });

  final String title;

  /// What "no filter" is called here — "Any filling point", "Any tanker".
  final String anyLabel;

  final List<({int id, String label})> options;
  final int? selectedId;

  @override
  Widget build(BuildContext context) {
    return SheetBody(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 12),
          _Row(
            label: anyLabel,
            selected: selectedId == null,
            // The record's id is nullable at the call site, which is how
            // "cleared" travels back without a second sentinel type.
            onTap: () => Navigator.pop<({int? id, String label})>(
              context,
              (id: null, label: anyLabel),
            ),
          ),
          // Flexible over a shrink-wrapped list: the sheet grows with the
          // options rather than being clipped at a fixed height, and still
          // scrolls once there are more than fit.
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final option in options)
                  _Row(
                    label: option.label,
                    selected: option.id == selectedId,
                    onTap: () => Navigator.pop<({int? id, String label})>(context, option),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected
            ? appColorPrimary.withValues(alpha: 0.12)
            : (isDark
                ? Theme.of(context).cardColor
                : appetitAppContainerColor.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(13),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? appColorPrimary : null,
                    ),
                  ),
                ),
                if (selected) const Icon(Icons.check, size: 18, color: appColorPrimary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
