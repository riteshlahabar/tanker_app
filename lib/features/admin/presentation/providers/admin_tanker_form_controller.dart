import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/admin_tanker.dart';
import 'admin_providers.dart';

part 'admin_tanker_form_controller.g.dart';

class AdminTankerFormState {
  const AdminTankerFormState({this.submitting = false, this.failure, this.saved});

  final bool submitting;
  final Failure? failure;
  final AdminTanker? saved;
}

/// One controller for both create (no `id`) and edit (`id` of the tanker
/// being changed) — the request shape is identical either way.
@riverpod
class AdminTankerFormController extends _$AdminTankerFormController {
  @override
  AdminTankerFormState build() => const AdminTankerFormState();

  Future<void> submit(Map<String, dynamic> fields, {int? id}) async {
    state = const AdminTankerFormState(submitting: true);

    final repo = ref.read(adminTankerRepositoryProvider);
    final result = id == null ? await repo.create(fields) : await repo.update(id, fields);

    state = result.when(
      success: (tanker) => AdminTankerFormState(saved: tanker),
      error: (failure) => AdminTankerFormState(failure: failure),
    );
  }
}
