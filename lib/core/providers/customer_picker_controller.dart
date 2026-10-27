import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/models/customer_option.dart';
import '../errors/failure.dart';
import 'core_providers.dart';

part 'customer_picker_controller.g.dart';

/// The customer list behind an order form's picker, searchable as you type.
///
/// Lives in `core/providers` rather than under a role because both the admin's
/// New Order screen and the driver's read it; the endpoint behind it is chosen
/// by `customerLookupRepositoryProvider` from the signed-in role, so this
/// controller never knows or cares which role is typing.
///
/// **Opening it with nothing typed lists every customer** — the owner asked
/// for a dropdown you *can* search, not a search box that hides the book until
/// you guess a name. The unfiltered page is cached for the life of the
/// provider, so reopening the field is instant and a browse costs one request
/// per visit rather than one per tap. A 400 ms debounce still keeps a fast
/// typist from firing a request per keystroke.
@riverpod
class CustomerPickerController extends _$CustomerPickerController {
  Timer? _debounce;

  /// The unfiltered first page, once fetched.
  List<CustomerOption>? _all;
  bool _allHasMore = false;

  @override
  CustomerPickerState build() {
    ref.onDispose(() => _debounce?.cancel());

    return const CustomerPickerState();
  }

  /// Show the whole book — what the field does the moment it is opened, and
  /// what clearing the query falls back to.
  Future<void> loadAll() async {
    _debounce?.cancel();

    final cached = _all;

    if (cached != null) {
      state = CustomerPickerState(options: cached, hasMore: _allHasMore);

      return;
    }

    await _load('');
  }

  void search(String query) {
    _debounce?.cancel();

    final trimmed = query.trim();

    // Deleting the last character returns to the full list rather than to an
    // empty panel, so the field never looks broken mid-edit.
    if (trimmed.isEmpty) {
      unawaited(loadAll());

      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () => _load(trimmed));
  }

  /// Clears the results without clearing what was typed — used once a customer
  /// has been chosen, or when the list is collapsed, so it stops hanging under
  /// the field. The cached browse survives, so reopening does not re-fetch.
  void dismiss() {
    _debounce?.cancel();
    state = const CustomerPickerState();
  }

  Future<void> _load(String query) async {
    state = CustomerPickerState(options: state.options, loading: true);

    final result = await ref.read(customerLookupRepositoryProvider).search(query);

    state = result.when(
      success: (page) {
        if (query.isEmpty) {
          _all = page.items;
          _allHasMore = page.hasMore;
        }

        return CustomerPickerState(options: page.items, hasMore: page.hasMore);
      },
      error: (failure) => CustomerPickerState(error: failure),
    );
  }
}

class CustomerPickerState {
  const CustomerPickerState({
    this.options = const [],
    this.loading = false,
    this.hasMore = false,
    this.error,
  });

  final List<CustomerOption> options;
  final bool loading;

  /// The server had more customers than this page carries — the field says so
  /// rather than letting a browse read as the complete list.
  final bool hasMore;
  final Failure? error;
}
