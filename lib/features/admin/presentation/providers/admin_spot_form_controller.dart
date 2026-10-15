import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../shared/models/spot.dart';
import 'admin_providers.dart';

part 'admin_spot_form_controller.g.dart';

class AdminSpotFormState {
  const AdminSpotFormState({this.submitting = false, this.failure, this.saved});

  final bool submitting;
  final Failure? failure;
  final Spot? saved;
}

@riverpod
class AdminSpotFormController extends _$AdminSpotFormController {
  @override
  AdminSpotFormState build() => const AdminSpotFormState();

  Future<void> submit(Map<String, dynamic> fields, {int? id}) async {
    state = const AdminSpotFormState(submitting: true);

    final repo = ref.read(adminSpotRepositoryProvider);
    final result = id == null ? await repo.create(fields) : await repo.update(id, fields);

    state = result.when(
      success: (spot) => AdminSpotFormState(saved: spot),
      error: (failure) => AdminSpotFormState(failure: failure),
    );
  }
}
