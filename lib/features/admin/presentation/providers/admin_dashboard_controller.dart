import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/admin_dashboard.dart';
import 'admin_providers.dart';

part 'admin_dashboard_controller.g.dart';

class AdminDashboardState {
  const AdminDashboardState({this.dashboard, this.loading = true, this.error});

  final AdminDashboard? dashboard;
  final bool loading;
  final Failure? error;
}

@riverpod
class AdminDashboardController extends _$AdminDashboardController {
  @override
  AdminDashboardState build() {
    unawaited(refresh());

    return const AdminDashboardState();
  }

  Future<void> refresh() async {
    state = const AdminDashboardState();

    final result = await ref.read(adminDashboardRepositoryProvider).summary();

    state = result.when(
      success: (dashboard) => AdminDashboardState(dashboard: dashboard, loading: false),
      error: (failure) => AdminDashboardState(loading: false, error: failure),
    );
  }
}
