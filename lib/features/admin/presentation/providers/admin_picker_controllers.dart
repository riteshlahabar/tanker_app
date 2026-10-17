import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/providers/first_load.dart';
import '../../domain/customer_option.dart';
import '../../domain/driver_option.dart';
import 'admin_providers.dart';

part 'admin_picker_controllers.g.dart';

class PickerState<T> {
  const PickerState({this.options = const [], this.loading = false, this.error});

  final List<T> options;
  final bool loading;
  final Failure? error;
}

/// Search-as-you-type for the Assign sheet's driver field. A short debounce
/// keeps a fast typist from firing a request per keystroke.
@riverpod
class DriverPickerController extends _$DriverPickerController {
  Timer? _debounce;

  @override
  PickerState<DriverOption> build() {
    ref.onDispose(() => _debounce?.cancel());

    FirstLoad.after(ref, () => _search(''));

    return const PickerState<DriverOption>();
  }

  void search(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(query));
  }

  Future<void> _search(String query) async {
    state = PickerState(options: state.options, loading: true);

    final result = await ref.read(adminPickerRepositoryProvider).searchDrivers(query);

    state = result.when(
      success: (options) => PickerState(options: options),
      error: (failure) => PickerState(error: failure),
    );
  }
}

/// Search-as-you-type for the New Order screen's customer field.
@riverpod
class CustomerPickerController extends _$CustomerPickerController {
  Timer? _debounce;

  @override
  PickerState<CustomerOption> build() {
    ref.onDispose(() => _debounce?.cancel());

    return const PickerState<CustomerOption>();
  }

  void search(String query) {
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      state = const PickerState<CustomerOption>();

      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () => _search(query));
  }

  Future<void> _search(String query) async {
    state = PickerState(options: state.options, loading: true);

    final result = await ref.read(adminPickerRepositoryProvider).searchCustomers(query);

    state = result.when(
      success: (options) => PickerState(options: options),
      error: (failure) => PickerState(error: failure),
    );
  }
}
