import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/admin_delivery_slot.dart';
import 'admin_providers.dart';

part 'admin_delivery_slot_form_controller.g.dart';

class AdminDeliverySlotFormState {
  const AdminDeliverySlotFormState({this.submitting = false, this.failure, this.saved});

  final bool submitting;
  final Failure? failure;
  final AdminDeliverySlot? saved;
}

@riverpod
class AdminDeliverySlotFormController extends _$AdminDeliverySlotFormController {
  @override
  AdminDeliverySlotFormState build() => const AdminDeliverySlotFormState();

  Future<void> submit(Map<String, dynamic> fields, {int? id}) async {
    state = const AdminDeliverySlotFormState(submitting: true);

    final repo = ref.read(adminDeliverySlotRepositoryProvider);
    final result = id == null ? await repo.create(fields) : await repo.update(id, fields);

    state = result.when(
      success: (slot) => AdminDeliverySlotFormState(saved: slot),
      error: (failure) => AdminDeliverySlotFormState(failure: failure),
    );
  }
}
