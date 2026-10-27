import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/colors.dart';
import '../../../../shared/models/driver_expense.dart';
import '../../domain/admin_expense_repository.dart';
import '../providers/admin_expenses_controller.dart';
import 'expense_driver_picker_sheet.dart';

/// Driver / category / date-range / search, mirroring what the web panel's
/// DataTable offers so the two screens answer the same questions.
///
/// The chips name their value rather than their state: the driver chip reads
/// **"Ramesh Patil"**, not "Driver chosen", and the date chip the actual range
/// — a chip that only says a filter is *on* makes the admin reopen the picker
/// to find out what they are looking at, and the total above the list becomes
/// unreadable with it.
///
/// The row scrolls horizontally because five categories plus driver and date
/// never fit a phone's width; the leading search field is the app's own
/// borderless cream input rather than Material's outlined box, which was the
/// one grey-outlined field left on a page of cream ones.
class AdminExpenseFilterBar extends ConsumerStatefulWidget {
  const AdminExpenseFilterBar({super.key, required this.filter});

  final AdminExpenseFilter filter;

  @override
  ConsumerState<AdminExpenseFilterBar> createState() => _AdminExpenseFilterBarState();
}

class _AdminExpenseFilterBarState extends ConsumerState<AdminExpenseFilterBar> {
  final _searchController = TextEditingController();

  static final _dayMonth = DateFormat('d MMM');

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.filter.search ?? '';
  }

  @override
  void didUpdateWidget(AdminExpenseFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Keeps the field in step when the filter is cleared from elsewhere — the
    // Clear chip, or the empty state's own button.
    final search = widget.filter.search ?? '';

    if (search != (oldWidget.filter.search ?? '') && search != _searchController.text) {
      _searchController.text = search;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _apply(AdminExpenseFilter filter) =>
      ref.read(adminExpensesControllerProvider.notifier).setFilter(filter);

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: widget.filter.hasRange
          ? DateTimeRange(start: widget.filter.from!, end: widget.filter.to!)
          : null,
    );

    if (picked == null) return;

    _apply(widget.filter.copyWith(from: picked.start, to: picked.end));
  }

  Future<void> _pickDriver() async {
    final picked = await showModalBottomSheet<ExpenseDriverChoice>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ExpenseDriverPickerSheet(),
    );

    if (picked == null) return;

    _apply(
      picked.isAny
          ? widget.filter.copyWith(clearDriver: true)
          : widget.filter.copyWith(driverId: picked.id, driverName: picked.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = widget.filter;
    final isFiltered = ref.watch(adminExpensesControllerProvider).isFiltered;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: _SearchField(
            controller: _searchController,
            onSubmitted: (value) => _apply(filter.copyWith(search: value)),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _FilterChip(
                label: filter.driverName ?? 'All drivers',
                icon: Icons.person_outline,
                selected: filter.driverId != null,
                onTap: _pickDriver,
              ),
              _FilterChip(
                label: filter.hasRange
                    ? '${_dayMonth.format(filter.from!)} – ${_dayMonth.format(filter.to!)}'
                    : 'All time',
                icon: Icons.date_range_outlined,
                selected: filter.hasRange,
                onTap: _pickRange,
              ),
              // A thin rule, because what follows is a different kind of
              // control: these toggle, the two above open a picker.
              Container(
                width: 1,
                height: 22,
                margin: const EdgeInsets.only(right: 8),
                color: appTextColorSecondary.withValues(alpha: 0.2),
              ),
              for (final category in ExpenseCategory.values)
                _FilterChip(
                  label: category.label,
                  colour: category.color,
                  selected: filter.category == category,
                  onTap: () => _apply(
                    filter.category == category
                        ? filter.copyWith(clearCategory: true)
                        : filter.copyWith(category: category),
                  ),
                ),
              if (isFiltered)
                _FilterChip(
                  label: 'Clear',
                  icon: Icons.close,
                  selected: false,
                  onTap: () {
                    _searchController.clear();
                    _apply(const AdminExpenseFilter());
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The app's borderless cream input, with the search affordances this bar
/// needs: submit on done, and a clear button once there is something to
/// clear. [AppTextField] is not used because it takes a label above the
/// field, which a single-line search row does not want.
class _SearchField extends StatefulWidget {
  const _SearchField({required this.controller, required this.onSubmitted});

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
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
          hintText: 'Search a driver or a note',
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
          fillColor: isDark
              ? Theme.of(context).cardColor
              : appetitAppContainerColor.withValues(alpha: 0.6),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

/// One filter chip, in the design's own language rather than Material's.
///
/// Selected takes the category's own colour where there is one, so a chosen
/// Fuel chip and the Fuel spine on the rows below it are the same blue — the
/// filter and what it filtered read as one thing.
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.colour,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? colour;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = colour ?? appColorPrimary;
    final foreground = selected
        ? (isDark ? Colors.white : accent)
        : (isDark ? Colors.white70 : appTextColorSecondary);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected
            ? accent.withValues(alpha: isDark ? 0.34 : 0.14)
            : (isDark ? Theme.of(context).cardColor : appetitAppContainerColor.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? accent.withValues(alpha: 0.55) : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 15, color: foreground),
                  const SizedBox(width: 5),
                ] else if (colour != null) ...[
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
