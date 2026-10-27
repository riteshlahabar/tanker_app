import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/core/network/api_result.dart';
import 'package:tanker_app/features/admin/domain/admin_report_definition.dart';
import 'package:tanker_app/features/admin/domain/admin_report_filter.dart';
import 'package:tanker_app/features/admin/domain/admin_report_repository.dart';
import 'package:tanker_app/features/admin/domain/admin_report_result.dart';
import 'package:tanker_app/features/admin/domain/driver_salary_row.dart';
import 'package:tanker_app/features/admin/presentation/providers/admin_providers.dart';
import 'package:tanker_app/features/admin/presentation/screens/report_detail_screen.dart';
import 'package:tanker_app/features/admin/presentation/widgets/driver_salary_tile.dart';

/// The Driver Deliveries & Salary report is the first to get a view of its
/// own instead of the nine-column table.
///
/// Two claims are load-bearing:
///
/// * the row is read **by position**, the same contract the server's nightly
///   WhatsApp reads, so a changed column set must fall back to the generic
///   table rather than relabel money;
/// * a driver on **no salary** is said in words, never drawn as ₹ 0 — every
///   driver is on zero until the owner sets the real figures.
class _FakeReports implements AdminReportRepository {
  _FakeReports(this.result);

  final AdminReportResult result;

  @override
  Future<ApiResult<List<AdminReportDefinition>>> index() async => const Success([]);

  @override
  Future<ApiResult<AdminReportResult>> show(String key, AdminReportFilter filter) async =>
      Success(result);
}

const _definition = AdminReportDefinition(
  key: 'driver-salary',
  title: 'Driver Deliveries & Salary',
  filterFields: ['driver', 'search'],
);

AdminReportResult _result({
  List<String>? headings,
  List<List<dynamic>>? rows,
}) =>
    AdminReportResult(
      key: 'driver-salary',
      title: 'Driver Deliveries & Salary',
      rangeLabel: '1 – 27 Oct 2026',
      headings: headings ?? DriverSalaryRow.headings,
      rows: rows ??
          [
            // Money as ints, the way PHP sends an integral amount.
            ['Ramesh Patil', '9876543210', 'MH12AB1234', 12, 18, 27000, 3600, 0, 450],
            ['Sunil Jadhav', '9876500000', '—', 0, 0, 0, 0, 18000.0, 0],
          ],
      totals: const {
        'Drivers': '2',
        'Deliveries': '12',
        'Tankers delivered': '18',
        'Order value': '₹ 27,000.00',
        'Salary per month (not for the range)': '₹ 18,000.00',
        'Expenses in the range': '₹ 450.00',
      },
    );

void main() {
  Future<void> pump(WidgetTester tester, AdminReportResult result) async {
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [adminReportRepositoryProvider.overrideWithValue(_FakeReports(result))],
        child: const MaterialApp(home: ReportDetailScreen(definition: _definition)),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('each driver is a card, not a row of a sideways table', (tester) async {
    await pump(tester, _result());

    expect(find.byType(DriverSalaryTile), findsNWidgets(2));
    expect(find.byType(DataTable), findsNothing);

    // The work, against the name — the thing the table could not do, because
    // the name scrolled off before the figures arrived.
    expect(find.text('Ramesh Patil'), findsOneWidget);
    expect(find.text('12'), findsWidgets);
    expect(find.text('18'), findsWidgets);
    expect(find.text('MH12AB1234'), findsOneWidget);
  });

  testWidgets('the headline says what it covers and holds the salary apart', (tester) async {
    await pump(tester, _result());

    expect(find.text('12 deliveries'), findsOneWidget);
    // The whole scope line, not just the words — the filter chip says "All
    // drivers" too, and what matters here is that the headline states both
    // who and when.
    expect(find.text('All drivers  ·  1 – 27 Oct 2026'), findsOneWidget);

    // The rule that must survive every redesign: a monthly salary is not the
    // cost of an arbitrary range, so it is never added to the money above it.
    expect(find.textContaining('not the cost of this range'), findsOneWidget);
  });

  testWidgets('a driver with no salary set is told, not shown ₹ 0', (tester) async {
    await pump(tester, _result());

    expect(find.text('Salary not set'), findsOneWidget);
    expect(find.textContaining('₹ 0 / mo'), findsNothing);

    // The one who does have a salary still reads as a monthly figure.
    expect(find.text('₹ 18,000 / mo'), findsOneWidget);
  });

  testWidgets('an unexpected column set falls back to the generic table', (tester) async {
    // A column inserted in the middle — the failure mode the positional read
    // has to refuse rather than mislabel.
    await pump(
      tester,
      _result(
        headings: ['Driver', 'Mobile', 'Shift', 'Tanker', 'Delivered'],
        rows: [
          ['Ramesh Patil', '9876543210', 'Night', 'MH12AB1234', 12],
        ],
      ),
    );

    expect(find.byType(DriverSalaryTile), findsNothing);
    expect(find.byType(DataTable), findsOneWidget);
    expect(find.text('Shift'), findsOneWidget);
  });
}
