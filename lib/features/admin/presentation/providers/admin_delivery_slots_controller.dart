import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../shared/models/paginated.dart';
import '../../domain/admin_delivery_slot.dart';
import '../../domain/entity_list_filter.dart';
import 'admin_providers.dart';

part 'admin_delivery_slots_controller.g.dart';

class AdminDeliverySlotsState {
  const AdminDeliverySlotsState({
    this.filter = const EntityListFilter(),
    this.paginated = const Paginated<AdminDeliverySlot>.empty(),
    this.loading = true,
    this.loadingMore = false,
    this.error,
  });

  final EntityListFilter filter;
  final Paginated<AdminDeliverySlot> paginated;
  final bool loading;
  final bool loadingMore;
  final Failure? error;

  AdminDeliverySlotsState copyWith({
    EntityListFilter? filter,
    Paginated<AdminDeliverySlot>? paginated,
    bool? loading,
    bool? loadingMore,
    Failure? error,
    bool clearError = false,
  }) =>
      AdminDeliverySlotsState(
        filter: filter ?? this.filter,
        paginated: paginated ?? this.paginated,
        loading: loading ?? this.loading,
        loadingMore: loadingMore ?? this.loadingMore,
        error: clearError ? null : (error ?? this.error),
      );
}

@riverpod
class AdminDeliverySlotsController extends _$AdminDeliverySlotsController {
  @override
  AdminDeliverySlotsState build() {
    unawaited(refresh());

    return const AdminDeliverySlotsState();
  }

  Future<void> setFilter(EntityListFilter filter) async {
    state = state.copyWith(filter: filter);
    await refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true, clearError: true);

    final result = await ref.read(adminDeliverySlotRepositoryProvider).list(state.filter, page: 1);

    state = result.when(
      success: (page) => state.copyWith(paginated: page, loading: false),
      error: (failure) => state.copyWith(loading: false, error: failure),
    );
  }

  Future<void> loadMore() async {
    if (state.loadingMore || state.loading || !state.paginated.hasMore) return;

    state = state.copyWith(loadingMore: true, clearError: true);

    final result = await ref
        .read(adminDeliverySlotRepositoryProvider)
        .list(state.filter, page: state.paginated.nextPage);

    state = result.when(
      success: (page) =>
          state.copyWith(paginated: state.paginated.merge(page), loadingMore: false),
      error: (failure) => state.copyWith(loadingMore: false, error: failure),
    );
  }
}
