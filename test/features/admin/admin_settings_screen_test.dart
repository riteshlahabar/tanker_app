import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/core/network/api_result.dart';
import 'package:tanker_app/features/admin/domain/admin_settings_repository.dart';
import 'package:tanker_app/features/admin/presentation/providers/admin_providers.dart';
import 'package:tanker_app/features/admin/presentation/screens/admin_settings_screen.dart';

/// Settings is down to the two keys `UpdateSettingRequest` still validates.
/// The rate per tanker, the monthly salary and the daily report time left the
/// screen because none of them was a setting: the first two belong to the
/// tanker and the driver, and the third only described a schedule in
/// `routes/console.php`.
///
/// The keys are asserted, not just the labels. A label is cosmetic; a key is
/// the contract with the panel, which drops an unknown one silently and 422s
/// a missing required one — and nothing else enforces it. This screen has
/// been wrong that way twice.
class _FakeRepository implements AdminSettingsRepository {
  _FakeRepository({this.stored = const {}});

  final Map<String, String?> stored;
  Map<String, String>? sent;

  @override
  Future<ApiResult<Map<String, String?>>> show() async => Success(stored);

  @override
  Future<ApiResult<Map<String, String?>>> update(Map<String, String> values) async {
    sent = values;

    return Success(values);
  }
}

/// Everything the panel holds, so the happy path is tested against real rows.
const _storedSettings = <String, String?>{
  'company_name': 'WTMS',
  'admin_whatsapp_number': '919812345678',
};

void main() {
  Future<_FakeRepository> pumpSettings(
    WidgetTester tester, {
    Map<String, String?> stored = _storedSettings,
  }) async {
    final repository = _FakeRepository(stored: stored);

    tester.view.physicalSize = const Size(411, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [adminSettingsRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: AdminSettingsScreen()),
      ),
    );

    await tester.pumpAndSettle();

    return repository;
  }

  /// What is actually in the inputs. `find.text` cannot be trusted for a field
  /// value here, because InputDecorator also builds the hint.
  List<String> fieldValues(WidgetTester tester) => tester
      .widgetList<EditableText>(find.byType(EditableText))
      .map((field) => field.controller.text)
      .toList();

  testWidgets('only the business fields are left, and they carry their stored values', (tester) async {
    await pumpSettings(tester);

    expect(find.text('Company name'), findsOneWidget);
    expect(find.text('Owner WhatsApp number'), findsOneWidget);
    expect(fieldValues(tester), containsAll(<String>['WTMS', '919812345678']));

    // Two inputs, not five: a figure still on this screen is a figure that
    // disagrees with the tanker or the driver it was moved to.
    expect(fieldValues(tester).length, 2);
    expect(find.textContaining('monthly salary (₹)'), findsNothing);
    expect(find.textContaining('rate per tanker (₹)'), findsNothing);
    expect(find.textContaining('Daily report time'), findsNothing);
  });

  testWidgets('saving posts the key the panel requires', (tester) async {
    final repository = await pumpSettings(tester);

    await tester.tap(find.text('Save Settings'));
    await tester.pumpAndSettle();

    final sent = repository.sent!;

    // Both of UpdateSettingRequest's fields, exactly — a missing required one
    // is a 422, and every key the panel has dropped would be ignored at best.
    expect(sent.keys.toSet(), {'company_name', 'admin_whatsapp_number'});
    expect(sent['company_name'], 'WTMS');

    for (final gone in const [
      'default_monthly_salary',
      'default_tanker_rate',
      'daily_report_time',
      'default_order_amount',
      'price_per_tanker',
      'default_driver_rate',
    ]) {
      expect(sent.keys, isNot(contains(gone)));
    }
  });

  testWidgets('a server with no settings rows opens on the panel defaults', (tester) async {
    // GET /api/admin/settings answers [] on the live server, which left the
    // fields blank and made the first save 422 on the required company name.
    final repository = await pumpSettings(tester, stored: const {});

    expect(fieldValues(tester), contains('Tanker'));

    await tester.tap(find.text('Save Settings'));
    await tester.pumpAndSettle();

    final sent = repository.sent!;

    expect(sent['company_name'], 'Tanker');
    // Optional, and the panel invents nothing for it either.
    expect(sent['admin_whatsapp_number'], '');
  });
}
