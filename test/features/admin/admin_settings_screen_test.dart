import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/core/network/api_result.dart';
import 'package:tanker_app/features/admin/domain/admin_settings_repository.dart';
import 'package:tanker_app/features/admin/presentation/providers/admin_providers.dart';
import 'package:tanker_app/features/admin/presentation/screens/admin_settings_screen.dart';

/// Drivers went onto a monthly salary on 2026-10-17 and
/// `UpdateSettingRequest` now requires `default_monthly_salary`. The app's
/// Settings screen was the one surface the rename missed: it still showed
/// "Default driver rate (per delivery)" and, worse, still POSTed the dropped
/// `default_driver_rate` key — so every save came back 422 for a missing
/// required field.
///
/// The keys are therefore asserted, not just the label. A label is cosmetic; a
/// key is the contract with the panel, and nothing else enforces it.
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
  'default_monthly_salary': '18000',
  'default_order_amount': '900',
  'price_per_tanker': '1100',
  'daily_report_time': '23:59',
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
  /// value here: InputDecorator also builds the hint, and the daily-report
  /// field's hint is the very string its value usually is ("23:59").
  List<String> fieldValues(WidgetTester tester) => tester
      .widgetList<EditableText>(find.byType(EditableText))
      .map((field) => field.controller.text)
      .toList();

  testWidgets('the salary field is monthly, and per-delivery wording is gone', (tester) async {
    await pumpSettings(tester);

    expect(find.text('Default monthly salary (₹)'), findsOneWidget);
    expect(find.textContaining('per delivery)'), findsNothing);
    expect(find.textContaining('driver rate'), findsNothing);
    // The stored value has to reach the field, or the owner would overwrite a
    // real salary with a default.
    expect(fieldValues(tester), contains('18000'));
  });

  testWidgets('saving posts the key the panel requires', (tester) async {
    final repository = await pumpSettings(tester);

    await tester.tap(find.text('Save Settings'));
    await tester.pumpAndSettle();

    final sent = repository.sent!;

    expect(sent.keys, contains('default_monthly_salary'));
    expect(sent.keys, isNot(contains('default_driver_rate')));
    expect(sent['default_monthly_salary'], '18000');

    // All six of UpdateSettingRequest's fields, exactly — a missing required
    // one is a 422 and an unknown one is silently dropped.
    expect(
      sent.keys.toSet(),
      {
        'company_name',
        'admin_whatsapp_number',
        'default_monthly_salary',
        'default_order_amount',
        'price_per_tanker',
        'daily_report_time',
      },
    );
  });

  testWidgets('a server with no settings rows opens on the panel defaults', (tester) async {
    // GET /api/admin/settings answers [] on the live server, which left every
    // field blank and made the first save 422 on five required fields.
    final repository = await pumpSettings(tester, stored: const {});

    expect(
      fieldValues(tester),
      containsAll(<String>['Tanker', '15000', '23:59']),
    );

    await tester.tap(find.text('Save Settings'));
    await tester.pumpAndSettle();

    final sent = repository.sent!;

    expect(sent['default_monthly_salary'], '15000');
    expect(sent['price_per_tanker'], '0');
    expect(sent['daily_report_time'], '23:59');
    // Optional, and the panel invents nothing for it either.
    expect(sent['admin_whatsapp_number'], '');
  });
}
