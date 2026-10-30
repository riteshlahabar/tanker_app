import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/spot.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/shell_tab_bar.dart';
import '../../../../shared/widgets/stat_tile.dart';
import '../../domain/admin_report_definition.dart';
import '../../domain/admin_report_filter.dart';
import '../../domain/admin_report_result.dart';
import '../../domain/admin_tanker.dart';
import '../../domain/entity_list_filter.dart';
import '../providers/admin_providers.dart';
import '../providers/admin_report_detail_controller.dart';
import '../widgets/report_body_registry.dart';
import '../widgets/report_filter_bar.dart';

/// One screen for every report — they all answer in the same
/// headings/rows/totals shape, so one screen reads whichever report's
/// `filterFields` named it rather than seven near-identical screens.
///
/// **A report may bring its own view of the rows** — which ones do is
/// [ReportBodyRegistry]'s list, not this screen's business. Anything it does
/// not claim falls back to the generic table, which is always right because
/// it draws whatever it is given. The filter bar and the loading, empty and
/// error states are shared by every path: a report view only ever replaces
/// the rows.
class ReportDetailScreen extends ConsumerStatefulWidget {
  const ReportDetailScreen({super.key, required this.definition, this.initialFilter});

  final AdminReportDefinition definition;

  /// Opens the report at a range other than the server's default of this
  /// month — the dashboard's Revenue tile asks for today, because that is the
  /// figure the owner tapped.
  final AdminReportFilter? initialFilter;

  @override
  ConsumerState<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends ConsumerState<ReportDetailScreen> {
  /// The chosen driver / customer / filling point / tanker in words. Lives
  /// here rather than in the bar because the headline says it too.
  String? _entityLabel;

  List<Spot> _spotOptions = const [];
  List<AdminTanker> _tankerOptions = const [];

  bool get _usesSpot => widget.definition.filterFields.contains('spot');
  bool get _usesTanker => widget.definition.filterFields.contains('tanker');

  /// This report's controller. The opening range is part of the provider's
  /// identity, not something applied afterwards — see the controller's own
  /// note on why.
  AdminReportDetailControllerProvider get _controller => adminReportDetailControllerProvider(
        widget.definition.key,
        initialFrom: widget.initialFilter?.from,
        initialTo: widget.initialFilter?.to,
      );

  @override
  void initState() {
    super.initState();
    if (_usesSpot) _loadSpots();
    if (_usesTanker) _loadTankers();
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

  void _apply(AdminReportFilter filter, String? entityLabel) {
    setState(() => _entityLabel = entityLabel);
    ref.read(_controller.notifier).setFilter(filter);
  }

  /// What the figures are narrowed to, in words, for a report view that draws
  /// a headline — a total that moves when a chip is tapped is unreadable
  /// without it.
  String _scope(AdminReportResult result, AdminReportFilter filter) {
    final search = filter.search?.trim() ?? '';

    return <String>[
      ?_entityScope(),
      result.rangeLabel,
      if (search.isNotEmpty) '"$search"',
    ].join('  ·  ');
  }

  /// The chosen entity, or "all of them" for whichever kind this report
  /// filters by — and **nothing at all** for a report with no entity filter,
  /// since "All drivers" over the Daily Delivery Summary would be a sentence
  /// about a filter it does not offer.
  String? _entityScope() {
    if (_entityLabel != null) return _entityLabel;

    final fields = widget.definition.filterFields;

    if (fields.contains('driver')) return 'All drivers';
    if (fields.contains('customer')) return 'All customers';
    if (fields.contains('spot')) return 'All filling points';
    if (fields.contains('tanker')) return 'All tankers';

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_controller);
    final result = state.result;

    // Null unless a registered report view claims this result — and so null
    // for a report whose columns changed on the server, which falls back to
    // the table below. When it is non-null the generic totals strip and its
    // divider stand down: each view draws its own headline inside the scroll
    // area, where it can scroll away once the rows are being read.
    final ownBody =
        result == null ? null : ReportBodyRegistry.bodyFor(result, _scope(result, state.filter));

    return Scaffold(
      appBar: AppBar(title: Text(widget.definition.title)),
      body: Column(
        children: [
          ReportFilterBar(
            definition: widget.definition,
            filter: state.filter,
            entityLabel: _entityLabel,
            spots: _spotOptions,
            tankers: _tankerOptions,
            onChanged: _apply,
          ),
          // The generic totals strip is for the table reports. A report with
          // a view of its own draws its own headline inside the scroll area,
          // where it can scroll away once the rows are being read.
          if (ownBody == null && result != null && result.totals.isNotEmpty)
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
          if (ownBody == null) const Divider(height: 1),
          Expanded(child: _body(state, result, ownBody)),
        ],
      ),
      bottomNavigationBar: const ShellTabBar(),
    );
  }

  Widget _body(AdminReportDetailState state, AdminReportResult? result, Widget? ownBody) {
    if (state.loading) return const Center(child: CircularProgressIndicator());

    if (result == null) {
      return EmptyState(
        icon: Icons.bar_chart_outlined,
        title: 'Could not load this report',
        message: state.error?.message,
      );
    }

    // A report view draws its own empty state, because "no drivers" and "no
    // filling points" are different sentences.
    if (ownBody != null) return ownBody;

    if (result.rows.isEmpty) {
      return const EmptyState(icon: Icons.inbox_outlined, title: 'No rows for this range');
    }

    return SingleChildScrollView(
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
    );
  }
}
