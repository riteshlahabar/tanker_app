import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/providers/first_load.dart';
import '../../domain/admin_report_filter.dart';
import '../../domain/admin_report_result.dart';
import 'admin_providers.dart';

part 'admin_report_detail_controller.g.dart';

class AdminReportDetailState {
  const AdminReportDetailState({
    this.filter = const AdminReportFilter(),
    this.result,
    this.loading = true,
    this.error,
  });

  final AdminReportFilter filter;
  final AdminReportResult? result;
  final bool loading;
  final Failure? error;

  AdminReportDetailState copyWith({
    AdminReportFilter? filter,
    AdminReportResult? result,
    bool? loading,
    Failure? error,
  }) =>
      AdminReportDetailState(
        filter: filter ?? this.filter,
        result: result ?? this.result,
        loading: loading ?? this.loading,
        error: error,
      );
}

/// Backs one report's detail screen — the server defaults the date range to
/// this month when the filter leaves `from`/`to` null, so the first load
/// needs no client-side default.
///
/// **A screen opening the report at a particular range passes it here**, as
/// part of the provider's identity, rather than setting it afterwards: the
/// dashboard's Revenue tile wants today. Riverpod forbids modifying a
/// provider from `initState`, and seeding it once the opening load has
/// started races two requests — so the range has to be known at `build()`,
/// and then the one request `FirstLoad` fires already carries it.
@riverpod
class AdminReportDetailController extends _$AdminReportDetailController {
  @override
  AdminReportDetailState build(String reportKey, {DateTime? initialFrom, DateTime? initialTo}) {
    FirstLoad.after(ref, refresh);

    return AdminReportDetailState(
      filter: AdminReportFilter(from: initialFrom, to: initialTo),
    );
  }

  Future<void> setFilter(AdminReportFilter filter) async {
    state = state.copyWith(filter: filter);
    await refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true, error: null);

    final result = await ref.read(adminReportRepositoryProvider).show(reportKey, state.filter);

    state = result.when(
      success: (report) => state.copyWith(result: report, loading: false),
      error: (failure) => state.copyWith(loading: false, error: failure),
    );
  }
}
