import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/shell_tab_bar.dart';
import '../providers/admin_settings_controller.dart';

/// The six fields `UpdateSettingRequest` validates, mirroring the web
/// panel's own Settings screen field-for-field.
class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  final _companyName = TextEditingController();
  final _whatsappNumber = TextEditingController();
  final _driverRate = TextEditingController();
  final _orderAmount = TextEditingController();
  final _pricePerTanker = TextEditingController();
  final _reportTime = TextEditingController();
  bool _loaded = false;

  @override
  void dispose() {
    _companyName.dispose();
    _whatsappNumber.dispose();
    _driverRate.dispose();
    _orderAmount.dispose();
    _pricePerTanker.dispose();
    _reportTime.dispose();
    super.dispose();
  }

  void _fillFrom(Map<String, String?> values) {
    _companyName.text = values['company_name'] ?? '';
    _whatsappNumber.text = values['admin_whatsapp_number'] ?? '';
    _driverRate.text = values['default_driver_rate'] ?? '';
    _orderAmount.text = values['default_order_amount'] ?? '';
    _pricePerTanker.text = values['price_per_tanker'] ?? '';
    _reportTime.text = values['daily_report_time'] ?? '';
  }

  Future<void> _save() async {
    final message = await ref.read(adminSettingsControllerProvider.notifier).save({
      'company_name': _companyName.text.trim(),
      'admin_whatsapp_number': _whatsappNumber.text.trim(),
      'default_driver_rate': _driverRate.text.trim(),
      'default_order_amount': _orderAmount.text.trim(),
      'price_per_tanker': _pricePerTanker.text.trim(),
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
              label: 'Admin WhatsApp number',
              hint: 'With country code, e.g. 919812345678',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _driverRate,
              label: 'Default driver rate (per delivery)',
              hint: '',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _orderAmount,
              label: 'Default order amount',
              hint: 'Used when price per litre is 0',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _pricePerTanker,
              label: 'Price per tanker (₹)',
              hint: 'Used when a tanker has no rate of its own; 0 = flat amount',
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
