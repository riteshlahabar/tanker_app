import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../shared/models/spot.dart';
import '../../../../shared/widgets/app_filter_chip.dart';
import '../../../../shared/widgets/app_search_field.dart';
import '../../domain/admin_report_definition.dart';
import '../../domain/admin_report_filter.dart';
import '../../domain/admin_tanker.dart';
import 'customer_filter_sheet.dart';
import 'driver_filter_sheet.dart';
import 'report_option_sheet.dart';

/// What a report is narrowed to: a date range, whichever single entity the
/// report asked for, and a search.
///
/// It replaces a `Wrap` of Material `ActionChip`s, two bare `DropdownButton`s
/// and an outlined `TextField` — four different control idioms on one row, in
/// an app that has had one since the Driver Expenses screen. Now every filter
/// is the same chip opening the same kind of sheet, over the app's own cream
/// search field.
///
/// Three rules it inherits from that screen:
///
/// * **a chip names its value**: "Ramesh Patil" and "1 – 27 Oct", never
///   "Driver" and "Date range" once something is chosen, because the headline
///   above the rows cannot be read without knowing what it covers;
/// * **every filter can be unset** — each sheet opens on its own "Any" row,
///   which is what the old dropdowns' blank first item was trying to be and
///   the driver chip had no way to express at all;
/// * **the row scrolls horizontally**: a date, an entity and a Clear chip
///   stop fitting a 320dp phone as soon as the entity is a real name.
class ReportFilterBar extends StatefulWidget {
  const ReportFilterBar({
    super.key,
    required this.definition,
    required this.filter,
    required this.entityLabel,
    required this.spots,
    required this.tankers,
    required this.onChanged,
  });

  final AdminReportDefinition definition;
  final AdminReportFilter filter;

  /// The chosen driver / customer / filling point / tanker in words, or null
  /// for "any". Held by the screen because its headline says it too.
  final String? entityLabel;

  final List<Spot> spots;
  final List<AdminTanker> tankers;

  /// Applies a new filter, and the label to show for whatever entity it
  /// names. Null label means the entity chip goes back to "Any".
  final void Function(AdminReportFilter filter, String? entityLabel) onChanged;

  @override
  State<ReportFilterBar> createState() => _ReportFilterBarState();
}

class _ReportFilterBarState extends State<ReportFilterBar> {
  final _searchController = TextEditingController();

  static final _dayMonth = DateFormat('d MMM');

  bool get _usesDriver => widget.definition.filterFields.contains('driver');
  bool get _usesCustomer => widget.definition.filterFields.contains('customer');
  bool get _usesSpot => widget.definition.filterFields.contains('spot');
  bool get _usesTanker => widget.definition.filterFields.contains('tanker');
  bool get _usesSearch => widget.definition.filterFields.contains('search');

  bool get _isFiltered =>
      widget.entityLabel != null ||
      widget.filter.from != null ||
      (widget.filter.search?.isNotEmpty ?? false);

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

  /// Both builders rebuild field by field rather than using `copyWith`,
  /// which cannot put a field back to null — and clearing a filter is half of
  /// what this bar is for.
  ///
  /// Setting one entity clears the others by construction, which is safe
  /// because a report declares at most one entity filter and so only one chip
  /// is ever on screen. The range and the search carry over.
  AdminReportFilter _withEntity({int? driverId, int? customerId, int? spotId, int? tankerId}) {
    final current = widget.filter;

    return AdminReportFilter(
      from: current.from,
      to: current.to,
      driverId: driverId,
      customerId: customerId,
      spotId: spotId,
      tankerId: tankerId,
      search: current.search,
    );
  }

  /// An emptied box means **no** search — sending `''` would reach the server
  /// as `like '%%'`, which matches everything and looks like a filter that
  /// did nothing.
  AdminReportFilter _withSearch(String value) {
    final current = widget.filter;
    final search = value.trim();

    return AdminReportFilter(
      from: current.from,
      to: current.to,
      driverId: current.driverId,
      customerId: current.customerId,
      spotId: current.spotId,
      tankerId: current.tankerId,
      search: search.isEmpty ? null : search,
    );
  }

  Future<void> _pickRange() async {
    final current = widget.filter;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: current.from != null && current.to != null
          ? DateTimeRange(start: current.from!, end: current.to!)
          : null,
    );

    if (picked == null) return;

    widget.onChanged(
      AdminReportFilter(
        from: picked.start,
        to: picked.end,
        driverId: current.driverId,
        customerId: current.customerId,
        spotId: current.spotId,
        tankerId: current.tankerId,
        search: current.search,
      ),
      widget.entityLabel,
    );
  }

  Future<void> _pickDriver() async {
    final picked = await showModalBottomSheet<DriverFilterChoice>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const DriverFilterSheet(
        title: 'Which driver?',
        anySubtitle: 'Every driver in the report',
      ),
    );

    if (picked == null) return;

    widget.onChanged(_withEntity(driverId: picked.id), picked.name);
  }

  /// Opens a sheet that answers with an id and the words to put on the chip.
  /// A null id is the sheet's own "Any" row, and takes the label back to null
  /// with it — otherwise clearing the filter would leave the last name on the
  /// chip and the headline.
  Future<void> _pickEntity({
    required Widget sheet,
    required AdminReportFilter Function(int? id) filter,
  }) async {
    final picked = await showModalBottomSheet<({int? id, String label})>(
      context: context,
      isScrollControlled: true,
      builder: (_) => sheet,
    );

    if (picked == null) return;

    widget.onChanged(filter(picked.id), picked.id == null ? null : picked.label);
  }

  void _clearAll() {
    _searchController.clear();

    widget.onChanged(
      AdminReportFilter(from: widget.filter.from, to: widget.filter.to),
      null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = widget.filter;
    final label = widget.entityLabel;

    return Column(
      children: [
        if (_usesSearch)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: AppSearchField(
              controller: _searchController,
              hint: 'Search by name or mobile',
              onSubmitted: (value) => widget.onChanged(_withSearch(value), label),
            ),
          ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: _chips(filter, label)),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  List<Widget> _chips(AdminReportFilter filter, String? label) {
    return [
      AppFilterChip(
        label: filter.from == null
            ? 'This month'
            : '${_dayMonth.format(filter.from!)} – ${_dayMonth.format(filter.to!)}',
        icon: Icons.date_range_outlined,
        // The server defaults to this month when no range is sent, so an
        // untouched chip states that default rather than saying "all time",
        // which this screen never means.
        selected: filter.from != null,
        onTap: _pickRange,
      ),
      if (_usesDriver)
        AppFilterChip(
          label: label ?? 'All drivers',
          icon: Icons.person_outline,
          selected: filter.driverId != null,
          onTap: _pickDriver,
        ),
      if (_usesCustomer)
        AppFilterChip(
          label: label ?? 'All customers',
          icon: Icons.people_outline,
          selected: filter.customerId != null,
          onTap: () => _pickEntity(
            sheet: const CustomerFilterSheet(),
            filter: (id) => _withEntity(customerId: id),
          ),
        ),
      if (_usesSpot)
        AppFilterChip(
          label: label ?? 'Any filling point',
          icon: Icons.water_drop_outlined,
          selected: filter.spotId != null,
          onTap: () => _pickEntity(
            sheet: ReportOptionSheet(
              title: 'Which filling point?',
              anyLabel: 'Any filling point',
              selectedId: filter.spotId,
              options: [
                for (final spot in widget.spots) (id: spot.id, label: spot.name),
              ],
            ),
            filter: (id) => _withEntity(spotId: id),
          ),
        ),
      if (_usesTanker)
        AppFilterChip(
          label: label ?? 'Any tanker',
          icon: Icons.local_shipping_outlined,
          selected: filter.tankerId != null,
          onTap: () => _pickEntity(
            sheet: ReportOptionSheet(
              title: 'Which tanker?',
              anyLabel: 'Any tanker',
              selectedId: filter.tankerId,
              options: [
                for (final tanker in widget.tankers) (id: tanker.id, label: tanker.label),
              ],
            ),
            filter: (id) => _withEntity(tankerId: id),
          ),
        ),
      if (_isFiltered)
        AppFilterChip(
          label: 'Clear',
          icon: Icons.close,
          selected: false,
          onTap: _clearAll,
        ),
    ];
  }
}
