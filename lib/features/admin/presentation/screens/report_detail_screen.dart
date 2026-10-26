import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/spot.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/sheet_body.dart';
import '../../../../shared/widgets/shell_tab_bar.dart';
import '../../../../shared/widgets/stat_tile.dart';
import '../../domain/admin_report_definition.dart';
import '../../domain/admin_tanker.dart';
import '../../domain/entity_list_filter.dart';
import '../providers/admin_picker_controllers.dart';
import '../providers/admin_providers.dart';
import '../providers/admin_report_detail_controller.dart';

/// One generic table screen for all six reports — they all answer to the
/// same headings/rows/totals shape, so one screen reads whichever report's
/// `filterFields` named it, rather than six near-identical screens.
class ReportDetailScreen extends ConsumerStatefulWidget {
  const ReportDetailScreen({super.key, required this.definition});

  final AdminReportDefinition definition;

  @override
  ConsumerState<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends ConsumerState<ReportDetailScreen> {
  final _searchController = TextEditingController();
  String? _entityLabel;
  List<Spot> _spotOptions = const [];
  List<AdminTanker> _tankerOptions = const [];

  bool get _usesDriver => widget.definition.filterFields.contains('driver');
  bool get _usesCustomer => widget.definition.filterFields.contains('customer');
  bool get _usesSpot => widget.definition.filterFields.contains('spot');
  bool get _usesTanker => widget.definition.filterFields.contains('tanker');
  bool get _usesSearch => widget.definition.filterFields.contains('search');

  @override
  void initState() {
    super.initState();
    if (_usesSpot) _loadSpots();
    if (_usesTanker) _loadTankers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSpots() async {
    final result = await ref.read(adminSpotRepositoryProvider).list(const EntityListFilter());

    if (!mounted) return;

    setState(() => _spotOptions = result.valueOrNull?.items ?? const []);
  }

  Future<void> _loadTankers() async {
    final result = await ref.read(adminTankerRepositoryProvider).list(const EntityListFilter());

    if (!mounted) return;

    setState(() => _tankerOptions = result.valueOrNull?.items ?? const []);
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final controller = ref.read(
      adminReportDetailControllerProvider(widget.definition.key).notifier,
    );
    final current = ref.read(adminReportDetailControllerProvider(widget.definition.key)).filter;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: current.from != null && current.to != null
          ? DateTimeRange(start: current.from!, end: current.to!)
          : null,
    );

    if (picked == null) return;

    await controller.setFilter(current.copyWith(from: picked.start, to: picked.end));
  }

  Future<void> _pickDriver(BuildContext context) async {
    final chosen = await showModalBottomSheet<({int id, String label})>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _DriverSearchSheet(),
    );

    if (chosen == null) return;

    setState(() => _entityLabel = chosen.label);

    final controller = ref.read(
      adminReportDetailControllerProvider(widget.definition.key).notifier,
    );
    final current = ref.read(adminReportDetailControllerProvider(widget.definition.key)).filter;
    await controller.setFilter(current.copyWith(driverId: chosen.id));
  }

  Future<void> _pickCustomer(BuildContext context) async {
    final chosen = await showModalBottomSheet<({int id, String label})>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _CustomerSearchSheet(),
    );

    if (chosen == null) return;

    setState(() => _entityLabel = chosen.label);

    final controller = ref.read(
      adminReportDetailControllerProvider(widget.definition.key).notifier,
    );
    final current = ref.read(adminReportDetailControllerProvider(widget.definition.key)).filter;
    await controller.setFilter(current.copyWith(customerId: chosen.id));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminReportDetailControllerProvider(widget.definition.key));
    final result = state.result;

    return Scaffold(
      appBar: AppBar(title: Text(widget.definition.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.date_range, size: 18),
                  label: Text(result?.rangeLabel ?? 'Date range'),
                  onPressed: () => _pickDateRange(context),
                ),
                if (_usesDriver)
                  ActionChip(
                    label: Text(_entityLabel ?? 'Driver'),
                    onPressed: () => _pickDriver(context),
                  ),
                if (_usesCustomer)
                  ActionChip(
                    label: Text(_entityLabel ?? 'Customer'),
                    onPressed: () => _pickCustomer(context),
                  ),
                if (_usesSpot)
                  DropdownButton<int?>(
                    hint: const Text('Filling Point'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Any filling point')),
                      ..._spotOptions.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))),
                    ],
                    onChanged: (value) {
                      final controller = ref.read(
                        adminReportDetailControllerProvider(widget.definition.key).notifier,
                      );
                      controller.setFilter(state.filter.copyWith(spotId: value));
                    },
                  ),
                if (_usesTanker)
                  DropdownButton<int?>(
                    hint: const Text('Tanker'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Any tanker')),
                      ..._tankerOptions.map((t) => DropdownMenuItem(value: t.id, child: Text(t.label))),
                    ],
                    onChanged: (value) {
                      final controller = ref.read(
                        adminReportDetailControllerProvider(widget.definition.key).notifier,
                      );
                      controller.setFilter(state.filter.copyWith(tankerId: value));
                    },
                  ),
                if (_usesSearch)
                  SizedBox(
                    width: 180,
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(hintText: 'Search', isDense: true),
                      onSubmitted: (value) {
                        final controller = ref.read(
                          adminReportDetailControllerProvider(widget.definition.key).notifier,
                        );
                        controller.setFilter(state.filter.copyWith(search: value));
                      },
                    ),
                  ),
              ],
            ),
          ),
          if (result != null && result.totals.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final entry in result.totals.entries)
                    StatTile(label: entry.key, value: entry.value),
                ],
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: state.loading
                ? const Center(child: CircularProgressIndicator())
                : result == null
                    ? EmptyState(
                        icon: Icons.bar_chart_outlined,
                        title: 'Could not load this report',
                        message: state.error?.message,
                      )
                    : result.rows.isEmpty
                        ? const EmptyState(icon: Icons.inbox_outlined, title: 'No rows for this range')
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: DataTable(
                                columns: [
                                  for (final heading in result.headings) DataColumn(label: Text(heading)),
                                ],
                                rows: [
                                  for (final row in result.rows)
                                    DataRow(cells: [
                                      for (final cell in row) DataCell(Text(cell?.toString() ?? '—')),
                                    ]),
                                ],
                              ),
                            ),
                          ),
          ),
        ],
      ),
      bottomNavigationBar: const ShellTabBar(),
    );
  }
}

class _DriverSearchSheet extends ConsumerWidget {
  const _DriverSearchSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(driverPickerControllerProvider);

    return SheetBody(
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
                    onTap: () => Navigator.pop(context, (id: driver.id, label: driver.fullName)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerSearchSheet extends ConsumerWidget {
  const _CustomerSearchSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerPickerControllerProvider);

    return SheetBody(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Choose a customer', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 12),
          TextField(
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Search customers'),
            onChanged: (value) => ref.read(customerPickerControllerProvider.notifier).search(value),
          ),
          const SizedBox(height: 12),
          if (state.loading) const LinearProgressIndicator(),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final customer in state.options)
                  ListTile(
                    title: Text(customer.fullName),
                    onTap: () => Navigator.pop(context, (id: customer.id, label: customer.fullName)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
