import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/colors.dart';
import '../../../../shared/models/order_status.dart';
import '../../domain/admin_order_filter.dart';
import '../../domain/driver_option.dart';
import '../providers/admin_orders_controller.dart';
import '../providers/admin_picker_controllers.dart';

/// Status, driver, date-range and search for the admin's Orders list.
///
/// Every control is a chip that opens a sheet, rather than a dropdown sitting
/// beside two chips and two loose close buttons as it was. One idiom means the
/// bar reads as a single row of filters, and it matches the Driver Expenses
/// screen so the two admin lists behave the same way.
class AdminOrderFilterBar extends ConsumerStatefulWidget {
  const AdminOrderFilterBar({super.key});

  @override
  ConsumerState<AdminOrderFilterBar> createState() => _AdminOrderFilterBarState();
}

class _AdminOrderFilterBarState extends ConsumerState<AdminOrderFilterBar> {
  final _searchController = TextEditingController();
  String? _driverLabel;

  static final _dateFormat = DateFormat('d MMM');

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _apply(AdminOrderFilter filter) =>
      ref.read(adminOrdersControllerProvider.notifier).setFilter(filter);

  Future<void> _pickStatus(AdminOrderFilter current) async {
    final chosen = await showModalBottomSheet<_StatusChoice>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _StatusSheet(selected: current.status),
    );

    // A swipe-dismiss returns null and must change nothing. "Any status" is a
    // deliberate choice, so it comes back as a _StatusChoice holding null —
    // the two cannot be told apart from a bare nullable.
    if (chosen == null) return;

    _apply(
      chosen.status == null
          ? current.copyWith(clearStatus: true)
          : current.copyWith(status: chosen.status),
    );
  }

  Future<void> _pickDriver(AdminOrderFilter current) async {
    final chosen = await showModalBottomSheet<DriverOption>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _DriverSearchSheet(),
    );

    if (chosen == null) return;

    setState(() => _driverLabel = chosen.fullName);
    _apply(current.copyWith(driverId: chosen.id));
  }

  Future<void> _pickDateRange(AdminOrderFilter current) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      initialDateRange: current.from != null && current.to != null
          ? DateTimeRange(start: current.from!, end: current.to!)
          : null,
    );

    if (picked == null) return;

    _apply(current.copyWith(from: picked.start, to: picked.end));
  }

  void _clearAll() {
    _searchController.clear();
    setState(() => _driverLabel = null);
    _apply(const AdminOrderFilter());
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(adminOrdersControllerProvider).filter;
    final isFiltered = filter.status != null ||
        filter.driverId != null ||
        filter.from != null ||
        (filter.search?.isNotEmpty ?? false);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by order no.',
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              filled: true,
              fillColor: appetitAppContainerColor.withValues(alpha: 0.4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (value) => _apply(filter.copyWith(search: value)),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _Chip(
                  label: filter.status?.label ?? 'Any status',
                  // The chip wears the status's own colour, so the bar says
                  // what is being looked at without reading the word.
                  color: filter.status?.color,
                  selected: filter.status != null,
                  onTap: () => _pickStatus(filter),
                ),
                const SizedBox(width: 8),
                _Chip(
                  label: _driverLabel ?? 'Any driver',
                  selected: filter.driverId != null,
                  onTap: () => _pickDriver(filter),
                ),
                const SizedBox(width: 8),
                _Chip(
                  label: filter.from == null
                      ? 'Any date'
                      : '${_dateFormat.format(filter.from!)} – ${_dateFormat.format(filter.to!)}',
                  selected: filter.from != null,
                  onTap: () => _pickDateRange(filter),
                ),
                if (isFiltered) ...[
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

/// One filter chip. Tinted in its own colour when a choice is active, so an
/// applied filter is obvious at a glance rather than only on reading it.
class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? appColorPrimary;

    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
      selectedColor: accent.withValues(alpha: 0.14),
      side: BorderSide(
        color: selected ? accent.withValues(alpha: 0.5) : Colors.black12,
      ),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        color: selected ? accent : appTextColorPrimary,
      ),
    );
  }
}

/// What the status sheet hands back. A wrapper rather than a bare
/// `OrderStatus?`, so "the user chose Any status" is distinguishable from
/// "the user swiped the sheet away".
class _StatusChoice {
  const _StatusChoice(this.status);

  final OrderStatus? status;
}

/// Statuses with their own colours, so the sheet reads the same way the list
/// does.
class _StatusSheet extends StatelessWidget {
  const _StatusSheet({this.selected});

  final OrderStatus? selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Filter by status', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          // Seven rows plus the heading need ~450px, which does not fit a
          // phone, and would not fit in landscape however the sheet is opened.
          // So the rows scroll instead of overflowing — the same
          // Flexible-over-a-shrink-wrapped-list idiom _DriverSearchSheet uses.
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.all_inclusive, size: 20),
                  title: const Text('Any status'),
                  selected: selected == null,
                  onTap: () => Navigator.pop(context, const _StatusChoice(null)),
                ),
                for (final status in OrderStatus.values)
                  ListTile(
                    leading: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(color: status.color, shape: BoxShape.circle),
                    ),
                    title: Text(status.label),
                    selected: selected == status,
                    onTap: () => Navigator.pop(context, _StatusChoice(status)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverSearchSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_DriverSearchSheet> createState() => _DriverSearchSheetState();
}

class _DriverSearchSheetState extends ConsumerState<_DriverSearchSheet> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(driverPickerControllerProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Choose a driver', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 12),
          TextField(
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Search drivers'),
            onChanged: (value) => ref.read(driverPickerControllerProvider.notifier).search(value),
          ),
          const SizedBox(height: 12),
          if (state.loading) const LinearProgressIndicator(),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final driver in state.options)
                  ListTile(
                    title: Text(driver.fullName),
                    subtitle: driver.mobile == null ? null : Text(driver.mobile!),
                    onTap: () => Navigator.pop(context, driver),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
