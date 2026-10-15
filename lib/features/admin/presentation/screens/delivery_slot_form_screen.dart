import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../domain/admin_delivery_slot.dart';
import '../providers/admin_delivery_slot_form_controller.dart';
import '../providers/admin_providers.dart';

/// Create (no [existing]) or edit a delivery slot.
class DeliverySlotFormScreen extends ConsumerStatefulWidget {
  const DeliverySlotFormScreen({super.key, this.existing});

  final AdminDeliverySlot? existing;

  @override
  ConsumerState<DeliverySlotFormScreen> createState() => _DeliverySlotFormScreenState();
}

class _DeliverySlotFormScreenState extends ConsumerState<DeliverySlotFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _sortOrder =
      TextEditingController(text: widget.existing?.sortOrder.toString() ?? '0');
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  late bool _status = widget.existing?.status ?? true;

  @override
  void initState() {
    super.initState();
    _startTime = _parseTime(widget.existing?.startTime);
    _endTime = _parseTime(widget.existing?.endTime);
  }

  TimeOfDay? _parseTime(String? value) {
    if (value == null) return null;

    final parts = value.split(':');

    if (parts.length < 2) return null;

    return TimeOfDay(hour: int.tryParse(parts[0]) ?? 0, minute: int.tryParse(parts[1]) ?? 0);
  }

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _name.dispose();
    _sortOrder.dispose();
    super.dispose();
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(context: context, initialTime: _startTime ?? TimeOfDay.now());

    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(context: context, initialTime: _endTime ?? TimeOfDay.now());

    if (picked != null) setState(() => _endTime = picked);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Choose a start and end time.')));

      return;
    }

    await ref.read(adminDeliverySlotFormControllerProvider.notifier).submit(
          {
            'name': _name.text.trim(),
            'start_time': _formatTime(_startTime!),
            'end_time': _formatTime(_endTime!),
            'sort_order': int.tryParse(_sortOrder.text.trim()) ?? 0,
            'status': _status,
          },
          id: widget.existing?.id,
        );

    if (!mounted) return;

    final saved = ref.read(adminDeliverySlotFormControllerProvider).saved;

    if (saved == null) return;

    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this delivery slot?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed != true) return;

    final result =
        await ref.read(adminDeliverySlotRepositoryProvider).delete(widget.existing!.id);

    if (!mounted) return;

    result.when(
      success: (_) => Navigator.of(context).pop(),
      error: (failure) =>
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(adminDeliverySlotFormControllerProvider);
    final isEditing = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Delivery Slot' : 'Add Delivery Slot'),
        actions: [
          if (isEditing) IconButton(icon: const Icon(Icons.delete_outline), onPressed: _delete),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _name,
                label: 'Name',
                hint: 'e.g. Morning',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickStartTime,
                      child: InputDecorator(
                        decoration:
                            const InputDecoration(labelText: 'Start time', border: OutlineInputBorder()),
                        child: Text(_startTime == null ? 'Choose' : _startTime!.format(context)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickEndTime,
                      child: InputDecorator(
                        decoration:
                            const InputDecoration(labelText: 'End time', border: OutlineInputBorder()),
                        child: Text(_endTime == null ? 'Choose' : _endTime!.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _sortOrder,
                label: 'Sort order',
                hint: 'Lower shows first',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active'),
                value: _status,
                onChanged: (value) => setState(() => _status = value),
              ),
              if (formState.failure != null) ...[
                const SizedBox(height: 8),
                Text(formState.failure!.message, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              PrimaryButton(
                label: isEditing ? 'Save Changes' : 'Add Slot',
                busy: formState.submitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
