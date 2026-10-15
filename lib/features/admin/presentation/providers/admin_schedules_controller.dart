import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../shared/models/paginated.dart';
import '../../domain/admin_schedule.dart';
import '../../domain/admin_schedule_filter.dart';
import 'admin_providers.dart';

part 'admin_schedules_controller.g.dart';

class AdminSchedulesState {
  const AdminSchedulesState({
    this.filter = const AdminScheduleFilter(),
    this.paginated = const Paginated<AdminSchedule>.empty(),
    this.loading = true,
    this.loadingMore = false,
    this.error,
  });

  final AdminScheduleFilter filter;
  final Paginated<AdminSchedule> paginated;
  final bool loading;
  final bool loadingMore;
  final Failure? error;

  AdminSchedulesState copyWith({
    AdminScheduleFilter? filter,
    Paginated<AdminSchedule>? paginated,
    bool? loading,
    bool? loadingMore,
    Failure? error,
    bool clearError = false,
  }) =>
      AdminSchedulesState(
        filter: filter ?? this.filter,
        paginated: paginated ?? this.paginated,
        loading: loading ?? this.loading,
        loadingMore: loadingMore ?? this.loadingMore,
        error: clearError ? null : (error ?? this.error),
      );
}

@riverpod
class AdminSchedulesController extends _$AdminSchedulesController {
  @override
  AdminSchedulesState build() {
    unawaited(refresh());

    return const AdminSchedulesState();
  }

  Future<void> setFilter(AdminScheduleFilter filter) async {
    state = state.copyWith(filter: filter);
    await refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true, clearError: true);

    final result = await ref.read(adminScheduleRepositoryProvider).list(state.filter, page: 1);

    state = result.when(
      success: (page) => state.copyWith(paginated: page, loading: false),
      error: (failure) => state.copyWith(loading: false, error: failure),
    );
  }

  Future<void> loadMore() async {
    if (state.loadingMore || state.loading || !state.paginated.hasMore) return;

    state = state.copyWith(loadingMore: true, clearError: true);

    final result = await ref
        .read(adminScheduleRepositoryProvider)
        .list(state.filter, page: state.paginated.nextPage);

    state = result.when(
      success: (page) =>
          state.copyWith(paginated: state.paginated.merge(page), loadingMore: false),
      error: (failure) => state.copyWith(loadingMore: false, error: failure),
    );
  }

  /// Returns a short line for a snackbar either way.
  Future<String> generateNow({DateTime? date, bool dryRun = false}) async {
    final result =
        await ref.read(adminScheduleRepositoryProvider).generate(date: date, dryRun: dryRun);

    final message = result.when(
      success: (r) => '${r.created} created, ${r.skipped} skipped, ${r.failed} failed'
          ' for ${r.targetDate}.',
      error: (failure) => failure.message,
    );

    if (result.isSuccess) await refresh();

    return message;
  }
}
