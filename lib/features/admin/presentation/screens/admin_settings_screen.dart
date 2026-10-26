import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/shell_tab_bar.dart';
import '../providers/admin_settings_controller.dart';

/// The six fields `UpdateSettingRequest` validates, mirroring the web panel's
/// own Settings screen field-for-field — same keys, same labels, same help
/// text, so the two cannot describe the same setting differently.
class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  final _companyName = TextEditingController();
  final _whatsappNumber = TextEditingController();
  final _monthlySalary = TextEditingController();
  final _tankerRate = TextEditingController();
  final _reportTime = TextEditingController();
  bool _loaded = false;

  /// What the panel's own form falls back to when a settings row is missing
  /// (`setting::_partials.fields`). The app had shown blanks instead, and
  /// since five of the six are `required`, a first save on a server with no
  /// settings rows came straight back as a 422 — which is exactly the state
  /// the live server is in.
  static const _panelDefaults = <String, String>{
    'company_name': 'Tanker',
    'default_monthly_salary': '15000',
    'default_tanker_rate': '0',
    'daily_report_time': '23:59',
  };

  @override
  void dispose() {
    _companyName.dispose();
    _whatsappNumber.dispose();
    _monthlySalary.dispose();
    _tankerRate.dispose();
    _reportTime.dispose();
    super.dispose();
  }

  /// A key the server has no row for, or holds as an empty string, falls back
  /// to the panel's default.
  String _valueOf(Map<String, String?> values, String key) {
    final stored = values[key];

    if (stored != null && stored.isNotEmpty) return stored;

    return _panelDefaults[key] ?? '';
  }

  void _fillFrom(Map<String, String?> values) {
    _companyName.text = _valueOf(values, 'company_name');
    // The one genuinely optional field, so no default is invented for it.
    _whatsappNumber.text = values['admin_whatsapp_number'] ?? '';
    _monthlySalary.text = _valueOf(values, 'default_monthly_salary');
    _tankerRate.text = _valueOf(values, 'default_tanker_rate');
    _reportTime.text = _valueOf(values, 'daily_report_time');
  }

  Future<void> _save() async {
    final message = await ref.read(adminSettingsControllerProvider.notifier).save({
      'company_name': _companyName.text.trim(),
      'admin_whatsapp_number': _whatsappNumber.text.trim(),
      'default_monthly_salary': _monthlySalary.text.trim(),
      'default_tanker_rate': _tankerRate.text.trim(),
      'daily_report_time': _reportTime.text.trim(),
    });

    if (!mounted || message == null) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminSettingsControllerProvider);

    if (state.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
        bottomNavigationBar: ShellTabBar(),
      );
    }

    if (!_loaded) {
      _fillFrom(state.values);
      _loaded = true;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(controller: _companyName, label: 'Company name', hint: ''),
            const SizedBox(height: 12),
            AppTextField(
              controller: _whatsappNumber,
              label: 'Owner WhatsApp number',
              hint: 'With country code, digits only, e.g. 919812345678',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _monthlySalary,
              // Drivers are salaried monthly, not paid per delivery — this
              // field used to say "rate (per delivery)" and, worse, still
              // posted the dropped `default_driver_rate` key.
              label: 'Default monthly salary (₹)',
              hint: "Pre-filled on a new driver. Each driver's own salary is set on their form",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _tankerRate,
              // Water is sold by the load, so there is one unit in the system:
              // an order is this rate × the number of tankers. The old flat
              // `default_order_amount` beside it ignored the count, which made
              // the same number mean two different prices.
              label: 'Default rate per tanker (₹)',
              hint: 'One tanker-load, for vehicles with no rate of their own. 0 = pricing not set up yet',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _reportTime,
              label: 'Daily report time (HH:mm)',
              hint: '23:59',
            ),
            if (state.error != null) ...[
              const SizedBox(height: 12),
              Text(state.error!.message, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            PrimaryButton(label: 'Save Settings', busy: state.saving, onPressed: _save),
          ],
        ),
      ),
      bottomNavigationBar: const ShellTabBar(),
    );
  }
}
