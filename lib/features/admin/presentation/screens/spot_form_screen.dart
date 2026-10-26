import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/spot.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/shell_tab_bar.dart';
import '../providers/admin_providers.dart';
import '../providers/admin_spot_form_controller.dart';

/// Create (no [existing]) or edit a refill spot.
class SpotFormScreen extends ConsumerStatefulWidget {
  const SpotFormScreen({super.key, this.existing});

  final Spot? existing;

  @override
  ConsumerState<SpotFormScreen> createState() => _SpotFormScreenState();
}

class _SpotFormScreenState extends ConsumerState<SpotFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _address = TextEditingController(text: widget.existing?.address);
  late final _latitude =
      TextEditingController(text: widget.existing?.latitude?.toString() ?? '');
  late final _longitude =
      TextEditingController(text: widget.existing?.longitude?.toString() ?? '');
  late final _refillCharge =
      TextEditingController(text: widget.existing?.refillCharge.toStringAsFixed(0) ?? '');
  late final _waterType = TextEditingController(text: widget.existing?.waterType);
  late final _contactPerson = TextEditingController(text: widget.existing?.contactPerson);
  late final _contactMobile = TextEditingController(text: widget.existing?.contactMobile);
  late bool _isAvailable = widget.existing?.isAvailable ?? true;
  late bool _status = widget.existing?.status ?? true;

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _latitude.dispose();
    _longitude.dispose();
    _refillCharge.dispose();
    _waterType.dispose();
    _contactPerson.dispose();
    _contactMobile.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref.read(adminSpotFormControllerProvider.notifier).submit(
          {
            'name': _name.text.trim(),
            'address': _address.text.trim().isEmpty ? null : _address.text.trim(),
            'latitude': ?double.tryParse(_latitude.text.trim()),
            'longitude': ?double.tryParse(_longitude.text.trim()),
            'refill_charge': double.tryParse(_refillCharge.text.trim()) ?? 0,
            'water_type': _waterType.text.trim().isEmpty ? null : _waterType.text.trim(),
            'contact_person':
                _contactPerson.text.trim().isEmpty ? null : _contactPerson.text.trim(),
            'contact_mobile':
                _contactMobile.text.trim().isEmpty ? null : _contactMobile.text.trim(),
            'is_available': _isAvailable,
            'status': _status,
          },
          id: widget.existing?.id,
        );

    if (!mounted) return;

    final saved = ref.read(adminSpotFormControllerProvider).saved;

    if (saved == null) return;

    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this filling point?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await ref.read(adminSpotRepositoryProvider).delete(widget.existing!.id);

    if (!mounted) return;

    result.when(
      success: (_) => Navigator.of(context).pop(),
      error: (failure) =>
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(adminSpotFormControllerProvider);
    final isEditing = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Filling Point' : 'Add Filling Point'),
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
                hint: '',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(controller: _address, label: 'Address', hint: 'Optional', maxLines: 3),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _latitude,
                      label: 'Latitude',
                      hint: 'Optional',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: _longitude,
                      label: 'Longitude',
                      hint: 'Optional',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _refillCharge,
                label: 'Refill charge',
                hint: '',
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(controller: _waterType, label: 'Water type', hint: 'Optional'),
              const SizedBox(height: 12),
              AppTextField(controller: _contactPerson, label: 'Contact person', hint: 'Optional'),
              const SizedBox(height: 12),
              AppTextField(
                controller: _contactMobile,
                label: 'Contact mobile',
                hint: 'Optional',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Available'),
                value: _isAvailable,
                onChanged: (value) => setState(() => _isAvailable = value),
              ),
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
                label: isEditing ? 'Save Changes' : 'Add Filling Point',
                busy: formState.submitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const ShellTabBar(),
    );
  }
}
