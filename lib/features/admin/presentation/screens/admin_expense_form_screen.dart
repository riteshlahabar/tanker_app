import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/models/driver_expense.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/shell_tab_bar.dart';
import '../providers/admin_picker_controllers.dart';
import '../providers/admin_providers.dart';

/// Record an expense for a driver who has not entered it themselves — the case
/// the owner asked for — or correct one already there.
///
/// The driver is chosen on create only: the panel refuses to move an expense
/// between drivers on an update, because that would quietly rewrite both their
/// totals. Same rule the schedule form follows for its customer.
class AdminExpenseFormScreen extends ConsumerStatefulWidget {
  const AdminExpenseFormScreen({super.key, this.existing});

  final DriverExpense? existing;

  @override
  ConsumerState<AdminExpenseFormScreen> createState() => _AdminExpenseFormScreenState();
}

class _AdminExpenseFormScreenState extends ConsumerState<AdminExpenseFormScreen> {
  static const _backdateDays = 60;

  final _formKey = GlobalKey<FormState>();

  late final _amount = TextEditingController(
    text: widget.existing?.amount.toStringAsFixed(0) ?? '',
  );
  late final _notes = TextEditingController(text: widget.existing?.notes);

  late DateTime _date = widget.existing?.expenseDate ?? DateTime.now();
  late ExpenseCategory _category = widget.existing?.category ?? ExpenseCategory.fuel;

  late int? _driverId = widget.existing?.driverId;
  late String? _driverName = widget.existing?.driverName;

  bool _saving = false;
  bool _deleting = false;
  String? _error;

  static final _dateFormat = DateFormat('d MMM yyyy');

  bool get _isEdit => widget.existing != null;

  @override
  void dispose() {
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      // Matches StoreExpenseRequest exactly, so the picker cannot offer a date
      // the panel will refuse.
      firstDate: DateTime.now().subtract(const Duration(days: _backdateDays)),
      lastDate: DateTime.now(),
    );

    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickDriver() async {
    final picked = await showModalBottomSheet<({int id, String name})>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _DriverChoiceSheet(),
    );

    if (picked == null) return;

    setState(() {
      _driverId = picked.id;
      _driverName = picked.name;
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!_isEdit && _driverId == null) {
      setState(() => _error = 'Choose which driver this expense belongs to.');

      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final repository = ref.read(adminExpenseRepositoryProvider);
    final amount = double.tryParse(_amount.text.trim()) ?? 0;
    final notes = _notes.text.trim();

    final result = _isEdit
        ? await repository.update(
            widget.existing!.id,
            expenseDate: _date,
            category: _category,
            amount: amount,
            notes: notes,
          )
        : await repository.create(
            driverId: _driverId!,
            expenseDate: _date,
            category: _category,
            amount: amount,
            notes: notes,
          );

    if (!mounted) return;

    result.when(
      success: (_) => _finish(_isEdit ? 'Expense updated.' : 'Expense recorded.'),
      error: (failure) => setState(() {
        _saving = false;
        _error = failure.message;
      }),
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this expense?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (!(confirmed ?? false) || !mounted) return;

    setState(() {
      _deleting = true;
      _error = null;
    });

    final result = await ref.read(adminExpenseRepositoryProvider).remove(widget.existing!.id);

    if (!mounted) return;

    result.when(
      success: (_) => _finish('Expense deleted.'),
      error: (failure) => setState(() {
        _deleting = false;
        _error = failure.message;
      }),
    );
  }

  void _finish(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Expense' : 'Add Expense')),
      bottomNavigationBar: const ShellTabBar(),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.badge_outlined),
              title: Text(_driverName ?? 'Choose a driver'),
              subtitle: Text(
                _isEdit
                    ? 'The driver cannot be changed on an edit.'
                    : 'Whose expense this is',
              ),
              trailing: _isEdit
                  ? null
                  : TextButton(onPressed: _pickDriver, child: const Text('Choose')),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(_dateFormat.format(_date)),
              subtitle: const Text('When the money was spent'),
              trailing: TextButton(onPressed: _pickDate, child: const Text('Change')),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<ExpenseCategory>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: [
                for (final category in ExpenseCategory.values)
                  DropdownMenuItem(value: category, child: Text(category.label)),
              ],
              onChanged: (value) => setState(() => _category = value ?? _category),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _amount,
              label: 'Amount (₹)',
              hint: '',
              keyboardType: TextInputType.number,
              validator: (value) {
                final parsed = double.tryParse((value ?? '').trim()) ?? 0;

                return parsed <= 0 ? 'Enter the amount spent' : null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _notes,
              label: 'Notes',
              hint: 'Bill number, why the office entered it',
              maxLines: 3,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            PrimaryButton(
              label: _isEdit ? 'Save Changes' : 'Add Expense',
              busy: _saving,
              onPressed: _save,
            ),
            if (_isEdit) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _deleting ? null : _delete,
                child: Text(_deleting ? 'Deleting…' : 'Delete Expense'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Reuses the Assign sheet's driver search, so the app has one list of drivers
/// rather than one per screen. Returns the name too, so the form can show who
/// was chosen without a second lookup.
class _DriverChoiceSheet extends ConsumerWidget {
  const _DriverChoiceSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(driverPickerControllerProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search drivers',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) =>
                    ref.read(driverPickerControllerProvider.notifier).search(value),
              ),
            ),
            if (state.loading)
              const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.options.length,
                  itemBuilder: (context, index) {
                    final driver = state.options[index];

                    return ListTile(
                      title: Text(driver.fullName),
                      subtitle: Text(driver.mobile ?? ''),
                      onTap: () =>
                          Navigator.pop(context, (id: driver.id, name: driver.fullName)),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
