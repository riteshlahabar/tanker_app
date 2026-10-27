import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/models/customer_option.dart';
import '../errors/failure.dart';
import 'core_providers.dart';

part 'customer_picker_controller.g.dart';

/// Search-as-you-type over customers, for an order form's picker.
///
/// Lives in `core/providers` rather than under a role because both the admin's
/// New Order screen and the driver's read it; the endpoint behind it is chosen
/// by `customerLookupRepositoryProvider` from the signed-in role, so this
/// controller never knows or cares which role is typing.
///
/// A 400 ms debounce keeps a fast typist from firing a request per keystroke,
/// and a blank query resets to empty rather than asking for every customer —
/// the picker is a search box, not a browsable list.
@riverpod
class CustomerPickerController extends _$CustomerPickerController {
  Timer? _debounce;

  @override
  CustomerPickerState build() {
    ref.onDispose(() => _debounce?.cancel());

    return const CustomerPickerState();
  }

  void search(String query) {
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      state = const CustomerPickerState();

      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () => _search(query));
  }

  /// Clears the results without clearing what was typed — used once a customer
  /// has been chosen, so the list collapses instead of hanging under the
  /// field.
  void dismiss() {
    _debounce?.cancel();
    state = const CustomerPickerState();
  }

  Future<void> _search(String query) async {
    state = CustomerPickerState(options: state.options, loading: true);

    final result = await ref.read(customerLookupRepositoryProvider).search(query);

    state = result.when(
      success: (options) => CustomerPickerState(options: options),
      error: (failure) => CustomerPickerState(error: failure),
    );
  }
}

class CustomerPickerState {
  const CustomerPickerState({this.options = const [], this.loading = false, this.error});

  final List<CustomerOption> options;
  final bool loading;
  final Failure? error;
}
