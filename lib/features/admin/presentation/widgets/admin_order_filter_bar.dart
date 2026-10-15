import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/order_status.dart';
import '../../domain/admin_order_filter.dart';
import '../../domain/driver_option.dart';
import '../providers/admin_orders_controller.dart';
import '../providers/admin_picker_controllers.dart';

/// Status, driver, date-range and search filters for the admin's Orders
/// list, applied through `AdminOrdersController.setFilter`.
class AdminOrderFilterBar extends ConsumerStatefulWidget {
  const AdminOrderFilterBar({super.key});

  @override
  ConsumerState<AdminOrderFilterBar> createState() => _AdminOrderFilterBarState();
}

class _AdminOrderFilterBarState extends ConsumerState<AdminOrderFilterBar> {
  final _searchController = TextEditingController();
  String? _driverLabel;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _apply(AdminOrderFilter filter) =>
      ref.read(adminOrdersControllerProvider.notifier).setFilter(filter);

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

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(adminOrdersControllerProvider).filter;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search by order no.',
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
                DropdownButton<OrderStatus?>(
                  value: filter.status,
                  hint: const Text('Status'),
                  onChanged: (value) => _apply(
                    value == null ? filter.copyWith(clearStatus: true) : filter.copyWith(status: value),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Any status')),
                    ...OrderStatus.values
                        .map((s) => DropdownMenuItem(value: s, child: Text(s.label))),
                  ],
                ),
                const SizedBox(width: 12),
                ActionChip(
                  label: Text(_driverLabel ?? 'Driver'),
                  onPressed: () => _pickDriver(filter),
                ),
                if (filter.driverId != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () {
                      setState(() => _driverLabel = null);
                      _apply(filter.copyWith(clearDriver: true));
                    },
                  ),
                const SizedBox(width: 12),
                ActionChip(
                  label: Text(
                    filter.from == null ? 'Date range' : '${filter.from!.day}/${filter.from!.month}'
                        ' – ${filter.to!.day}/${filter.to!.month}',
                  ),
                  onPressed: () => _pickDateRange(filter),
                ),
                if (filter.from != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => _apply(filter.copyWith(clearDateRange: true)),
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
