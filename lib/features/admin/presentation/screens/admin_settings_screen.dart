import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/form_note.dart';
import '../../../../shared/widgets/form_section_heading.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/shell_tab_bar.dart';
import '../providers/admin_settings_controller.dart';

/// The two fields `UpdateSettingRequest` validates, mirroring the web panel's
/// own Settings screen field-for-field — same keys, same labels, same help
/// text, so the two cannot describe the same setting differently.
///
/// It held five. Three left because none of them was really a setting:
///
///  * **Default rate per tanker** — the price of a load belongs to the vehicle
///    that carries it, and the owner's tankers are not the same size, so one
///    global figure was wrong for every tanker with a rate of its own.
///  * **Default monthly salary** — what a driver is paid is on the driver, and
///    the salary report reads nothing else; a second figure here could only
///    disagree with the real ones while looking like it set them.
///  * **Daily report time** — documentation pretending to be a field. The
///    23:59 WhatsApp report is scheduled in `routes/console.php` and editing
///    this moved nothing.
class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  final _companyName = TextEditingController();
  final _whatsappNumber = TextEditingController();
  bool _loaded = false;

  /// What the panel's own form falls back to when a settings row is missing
  /// (`setting::_partials.fields`). The app had shown blanks instead, and
  /// since `company_name` is required, a first save on a server with no
  /// settings rows came straight back as a 422.
  static const _panelDefaults = <String, String>{'company_name': 'Tanker'};

  @override
  void dispose() {
    _companyName.dispose();
    _whatsappNumber.dispose();
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
  }

  Future<void> _save() async {
    final message = await ref.read(adminSettingsControllerProvider.notifier).save({
      'company_name': _companyName.text.trim(),
      'admin_whatsapp_number': _whatsappNumber.text.trim(),
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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FormSectionHeading('The business'),
            AppTextField(
              controller: _companyName,
              label: 'Company name',
              hint: 'Shown on the panel and in messages',
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _whatsappNumber,
              label: 'Owner WhatsApp number',
              hint: 'With country code, digits only, e.g. 919812345678',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 6),
            const FormNote(
              'Every owner notification and the nightly report go to this number.',
            ),

            const FormSectionHeading('Set elsewhere'),
            const _ElsewhereCard(
              icon: Icons.local_shipping_outlined,
              title: 'Rate per tanker',
              body: 'On each tanker, under Tankers. An order is that rate × the number '
                  'of tankers — there is no global default.',
            ),
            const SizedBox(height: 10),
            const _ElsewhereCard(
              icon: Icons.person_outline,
              title: 'Monthly salary',
              body: 'On each driver, under Drivers. It is what the Driver Salary report reads.',
            ),

            if (state.error != null) ...[
              const SizedBox(height: 12),
              Text(
                state.error!.message,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
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

/// A figure that used to be on this screen, saying where it actually lives.
///
/// Worth the space: the owner looked for these here, and a screen that simply
/// stopped showing them reads as something missing rather than something moved.
class _ElsewhereCard extends StatelessWidget {
  const _ElsewhereCard({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).cardColor
            : Theme.of(context).dividerColor.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).hintColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: TextStyle(fontSize: 12, height: 1.35, color: Theme.of(context).hintColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
