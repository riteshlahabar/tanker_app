import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/admin_schedule.dart';
import 'admin_providers.dart';

part 'admin_schedule_form_controller.g.dart';

class AdminScheduleFormState {
  const AdminScheduleFormState({this.submitting = false, this.failure, this.saved});

  final bool submitting;
  final Failure? failure;
  final AdminSchedule? saved;
}

@riverpod
class AdminScheduleFormController extends _$AdminScheduleFormController {
  @override
  AdminScheduleFormState build() => const AdminScheduleFormState();

  Future<void> submit(Map<String, dynamic> fields, {int? id}) async {
    state = const AdminScheduleFormState(submitting: true);

    final repo = ref.read(adminScheduleRepositoryProvider);
    final result = id == null ? await repo.create(fields) : await repo.update(id, fields);

    state = result.when(
      success: (schedule) => AdminScheduleFormState(saved: schedule),
      error: (failure) => AdminScheduleFormState(failure: failure),
    );
  }
}
