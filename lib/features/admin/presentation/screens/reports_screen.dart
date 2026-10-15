import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/empty_state.dart';
import '../providers/admin_reports_controller.dart';
import 'report_detail_screen.dart';

/// Reports tab body — the six reports the server lists, so adding one never
/// needs an app release.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminReportsControllerProvider);

    if (state.loading) return const Center(child: CircularProgressIndicator());

    if (state.reports.isEmpty) {
      return EmptyState(
        icon: Icons.bar_chart_outlined,
        title: 'Could not load reports',
        message: state.error?.message,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(adminReportsControllerProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.reports.length,
        itemBuilder: (context, index) {
          final report = state.reports[index];

          return ListTile(
            leading: const Icon(Icons.bar_chart_outlined),
            title: Text(report.title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ReportDetailScreen(definition: report)),
            ),
          );
        },
      ),
    );
  }
}
