import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/providers/first_load.dart';
import '../../domain/admin_report_definition.dart';
import 'admin_providers.dart';

part 'admin_reports_controller.g.dart';

class AdminReportsState {
  const AdminReportsState({this.reports = const [], this.loading = true, this.error});

  final List<AdminReportDefinition> reports;
  final bool loading;
  final Failure? error;
}

@riverpod
class AdminReportsController extends _$AdminReportsController {
  @override
  AdminReportsState build() {
    FirstLoad.after(ref, refresh);

    return const AdminReportsState();
  }

  Future<void> refresh() async {
    final result = await ref.read(adminReportRepositoryProvider).index();

    state = result.when(
      success: (reports) => AdminReportsState(reports: reports, loading: false),
      error: (failure) => AdminReportsState(loading: false, error: failure),
    );
  }
}
