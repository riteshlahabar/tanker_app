import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/providers/first_load.dart';
import 'admin_providers.dart';

part 'admin_settings_controller.g.dart';

class AdminSettingsState {
  const AdminSettingsState({
    this.values = const {},
    this.loading = true,
    this.saving = false,
    this.error,
  });

  final Map<String, String?> values;
  final bool loading;
  final bool saving;
  final Failure? error;
}

@riverpod
class AdminSettingsController extends _$AdminSettingsController {
  @override
  AdminSettingsState build() {
    FirstLoad.after(ref, refresh);

    return const AdminSettingsState();
  }

  Future<void> refresh() async {
    state = const AdminSettingsState();

    final result = await ref.read(adminSettingsRepositoryProvider).show();

    state = result.when(
      success: (values) => AdminSettingsState(values: values, loading: false),
      error: (failure) => AdminSettingsState(loading: false, error: failure),
    );
  }

  /// Returns the panel's own message either way, for a snackbar.
  Future<String?> save(Map<String, String> values) async {
    state = AdminSettingsState(values: state.values, loading: false, saving: true);

    final result = await ref.read(adminSettingsRepositoryProvider).update(values);

    return result.when(
      success: (saved) {
        state = AdminSettingsState(values: saved, loading: false);

        return 'Settings saved.';
      },
      error: (failure) {
        state = AdminSettingsState(values: state.values, loading: false, error: failure);

        return null;
      },
    );
  }
}
