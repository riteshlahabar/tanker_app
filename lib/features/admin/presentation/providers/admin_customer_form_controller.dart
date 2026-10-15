import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/admin_customer.dart';
import 'admin_providers.dart';

part 'admin_customer_form_controller.g.dart';

class AdminCustomerFormState {
  const AdminCustomerFormState({this.submitting = false, this.failure, this.saved});

  final bool submitting;
  final Failure? failure;
  final AdminCustomer? saved;
}

@riverpod
class AdminCustomerFormController extends _$AdminCustomerFormController {
  @override
  AdminCustomerFormState build() => const AdminCustomerFormState();

  Future<void> submit(Map<String, dynamic> fields, {int? id}) async {
    state = const AdminCustomerFormState(submitting: true);

    final repo = ref.read(adminCustomerRepositoryProvider);
    final result = id == null ? await repo.create(fields) : await repo.update(id, fields);

    state = result.when(
      success: (customer) => AdminCustomerFormState(saved: customer),
      error: (failure) => AdminCustomerFormState(failure: failure),
    );
  }
}
