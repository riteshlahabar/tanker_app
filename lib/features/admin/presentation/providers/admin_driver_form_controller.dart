import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/admin_driver.dart';
import 'admin_providers.dart';

part 'admin_driver_form_controller.g.dart';

class AdminDriverFormState {
  const AdminDriverFormState({this.submitting = false, this.failure, this.saved});

  final bool submitting;
  final Failure? failure;
  final AdminDriver? saved;
}

@riverpod
class AdminDriverFormController extends _$AdminDriverFormController {
  @override
  AdminDriverFormState build() => const AdminDriverFormState();

  Future<void> submit(Map<String, dynamic> fields, {int? id}) async {
    state = const AdminDriverFormState(submitting: true);

    final repo = ref.read(adminDriverRepositoryProvider);
    final result = id == null ? await repo.create(fields) : await repo.update(id, fields);

    state = result.when(
      success: (driver) => AdminDriverFormState(saved: driver),
      error: (failure) => AdminDriverFormState(failure: failure),
    );
  }
}
