import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../domain/entity_list_filter.dart';

/// Search and an active/inactive filter for the Tankers list.
///
/// The idiom is [AdminOrderFilterBar]'s, deliberately: a filled cream 15px
/// field over a row of chips. What was here before — a bare outlined field
/// beside a loose `DropdownButton` — was the only filter bar in the admin app
/// shaped that way, so it read as a different app from the Orders and Expenses
/// screens.
class TankerFilterBar extends StatefulWidget {
  const TankerFilterBar({
    super.key,
    required this.filter,
    required this.onChanged,
  });

  final EntityListFilter filter;
  final ValueChanged<EntityListFilter> onChanged;

  @override
  State<TankerFilterBar> createState() => _TankerFilterBarState();
}

class _TankerFilterBarState extends State<TankerFilterBar> {
  late final _searchController = TextEditingController(text: widget.filter.search);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _isFiltered =>
      widget.filter.status != null || (widget.filter.search?.isNotEmpty ?? false);

  void _clearAll() {
    _searchController.clear();
    widget.onChanged(const EntityListFilter());
  }

  @override
  Widget build(BuildContext context) {
    final filter = widget.filter;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search by number, name or RC',
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              filled: true,
              fillColor: appetitAppContainerColor.withValues(alpha: 0.4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (value) => widget.onChanged(filter.copyWith(search: value)),
          ),
          const SizedBox(height: 8),
          // Scrolls horizontally rather than packing a fixed Row: Active +
          // Inactive + Clear is already wider than a narrow phone. Same idiom
          // as AdminOrderFilterBar, which cannot overflow for the same reason.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _StatusChip(
                  label: 'Active',
                  color: statusDeliveredColor,
                  selected: filter.status == true,
                  onTap: () => widget.onChanged(
                    filter.status == true
                        ? filter.copyWith(clearStatus: true)
                        : filter.copyWith(status: true),
                  ),
                ),
                const SizedBox(width: 8),
                _StatusChip(
                  label: 'Inactive',
                  color: statusCancelledColor,
                  selected: filter.status == false,
                  onTap: () => widget.onChanged(
                    filter.status == false
                        ? filter.copyWith(clearStatus: true)
                        : filter.copyWith(status: false),
                  ),
                ),
                if (_isFiltered) ...[
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear'),
                    onPressed: _clearAll,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A filter chip tinted in the colour the list itself uses for that state, so
/// the chip and the card spine agree without reading the word.
class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
      selectedColor: color.withValues(alpha: 0.14),
      side: BorderSide(color: selected ? color.withValues(alpha: 0.5) : Colors.black12),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        color: selected ? color : appTextColorPrimary,
      ),
    );
  }
}
