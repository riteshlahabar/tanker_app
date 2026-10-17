import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/models/driver_expense.dart';
import '../../domain/admin_expense_repository.dart';
import '../providers/admin_expenses_controller.dart';
import '../providers/admin_picker_controllers.dart';

/// Driver / category / date-range / search, mirroring what the web panel's
/// DataTable offers so the two screens answer the same questions.
class AdminExpenseFilterBar extends ConsumerStatefulWidget {
  const AdminExpenseFilterBar({super.key, required this.filter});

  final AdminExpenseFilter filter;

  @override
  ConsumerState<AdminExpenseFilterBar> createState() => _AdminExpenseFilterBarState();
}

class _AdminExpenseFilterBarState extends ConsumerState<AdminExpenseFilterBar> {
  final _searchController = TextEditingController();

  static final _dateFormat = DateFormat('d MMM');

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.filter.search ?? '';
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
    final picked = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _DriverPickerSheet(),
    );

    if (picked == null) return;

    // -1 is the sheet's "any driver" row; a real id is never negative.
    _apply(
      picked < 0
          ? widget.filter.copyWith(clearDriver: true)
          : widget.filter.copyWith(driverId: picked),
    );
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
            decoration: const InputDecoration(
              hintText: 'Search driver or notes',
              prefixIcon: Icon(Icons.search),
              isDense: true,
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) => _apply(filter.copyWith(search: value)),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: Text(filter.driverId == null ? 'Any driver' : 'Driver chosen'),
                  selected: filter.driverId != null,
                  onSelected: (_) => _pickDriver(),
                ),
                const SizedBox(width: 8),
                for (final category in ExpenseCategory.values) ...[
                  FilterChip(
                    label: Text(category.label),
                    selected: filter.category == category,
                    onSelected: (selected) => _apply(
                      selected
                          ? filter.copyWith(category: category)
                          : filter.copyWith(clearCategory: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                FilterChip(
                  label: Text(
                    filter.hasRange
                        ? '${_dateFormat.format(filter.from!)} – ${_dateFormat.format(filter.to!)}'
                        : 'Any date',
                  ),
                  selected: filter.hasRange,
                  onSelected: (_) => _pickRange(),
                ),
                const SizedBox(width: 8),
                if (ref.watch(adminExpensesControllerProvider).isFiltered)
                  ActionChip(
                    avatar: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear'),
                    onPressed: () {
                      _searchController.clear();
                      _apply(const AdminExpenseFilter());
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Reuses the Assign sheet's driver search, so there is one list of drivers in
/// the app rather than one per screen.
class _DriverPickerSheet extends ConsumerWidget {
  const _DriverPickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(driverPickerControllerProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search drivers',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) =>
                    ref.read(driverPickerControllerProvider.notifier).search(value),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Any driver'),
              onTap: () => Navigator.pop(context, -1),
            ),
            const Divider(height: 1),
            if (state.loading)
              const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.options.length,
                  itemBuilder: (context, index) {
                    final driver = state.options[index];

                    return ListTile(
                      title: Text(driver.fullName),
                      subtitle: Text(driver.mobile ?? ''),
                      onTap: () => Navigator.pop(context, driver.id),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
