import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/colors.dart';
import '../../../../shared/models/driver_expense.dart';
import '../../../../shared/widgets/app_filter_chip.dart';
import '../../../../shared/widgets/app_search_field.dart';
import '../../domain/admin_expense_repository.dart';
import '../providers/admin_expenses_controller.dart';
import 'driver_filter_sheet.dart';

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
    final picked = await showModalBottomSheet<DriverFilterChoice>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const DriverFilterSheet(
        title: 'Whose expenses?',
        anySubtitle: 'Everybody’s spending together',
      ),
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
          child: AppSearchField(
            controller: _searchController,
            hint: 'Search a driver or a note',
            onSubmitted: (value) => _apply(filter.copyWith(search: value)),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              AppFilterChip(
                label: filter.driverName ?? 'All drivers',
                icon: Icons.person_outline,
                selected: filter.driverId != null,
                onTap: _pickDriver,
              ),
              AppFilterChip(
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
                AppFilterChip(
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
                AppFilterChip(
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


