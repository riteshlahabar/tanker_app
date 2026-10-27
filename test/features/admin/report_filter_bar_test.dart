import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/features/admin/domain/admin_report_definition.dart';
import 'package:tanker_app/features/admin/domain/admin_report_filter.dart';
import 'package:tanker_app/features/admin/presentation/widgets/report_filter_bar.dart';
import 'package:tanker_app/shared/widgets/app_filter_chip.dart';
import 'package:tanker_app/shared/widgets/app_search_field.dart';

/// The reports filter bar: one chip idiom for every filter, each naming its
/// own value, each clearable.
///
/// The claims worth pinning are about what the chips *say* and what the bar
/// hands back — a chip reading "Driver" while one driver is selected, or a
/// cleared search going back as `''`, are the two ways this control has
/// misled before.
void main() {
  const salary = AdminReportDefinition(
    key: 'driver-salary',
    title: 'Driver Deliveries & Salary',
    filterFields: ['driver', 'search'],
  );

  late List<({AdminReportFilter filter, String? label})> changes;

  Future<void> pump(
    WidgetTester tester, {
    AdminReportFilter filter = const AdminReportFilter(),
    String? entityLabel,
    AdminReportDefinition definition = salary,
  }) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    changes = [];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReportFilterBar(
            definition: definition,
            filter: filter,
            entityLabel: entityLabel,
            spots: const [],
            tankers: const [],
            onChanged: (filter, label) => changes.add((filter: filter, label: label)),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('the chips name their value, not their state', (tester) async {
    await pump(tester);

    // Untouched: the server defaults to this month, so the chip says so
    // rather than "Date range" or "All time", neither of which is true.
    expect(find.text('This month'), findsOneWidget);
    expect(find.text('All drivers'), findsOneWidget);

    await pump(
      tester,
      filter: AdminReportFilter(
        from: DateTime(2026, 10, 1),
        to: DateTime(2026, 10, 27),
        driverId: 7,
      ),
      entityLabel: 'Ramesh Patil',
    );

    expect(find.text('1 Oct – 27 Oct'), findsOneWidget);
    expect(find.text('Ramesh Patil'), findsOneWidget);
    expect(find.text('All drivers'), findsNothing);
  });

  testWidgets('Clear appears only once something is filtered', (tester) async {
    await pump(tester);

    expect(find.text('Clear'), findsNothing);

    await pump(tester, filter: const AdminReportFilter(driverId: 7), entityLabel: 'Ramesh Patil');

    expect(find.text('Clear'), findsOneWidget);

    // 320dp is deliberately the narrowest real phone, so the third chip is
    // off-screen until the row is scrolled — which is the behaviour, not a
    // problem: a tap at an off-screen centre would hit nothing.
    await tester.ensureVisible(find.text('Clear'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();

    // Cleared back to every driver, and the chip's label with it — a filter
    // that cleared but left the name behind is the bug this guards.
    expect(changes.single.filter.driverId, isNull);
    expect(changes.single.label, isNull);
  });

  testWidgets('an emptied search goes back as nothing, never as an empty string', (tester) async {
    await pump(tester, filter: const AdminReportFilter(search: 'ram'));

    expect(find.byType(AppSearchField), findsOneWidget);

    await tester.enterText(find.byType(TextField), '   ');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    // '' would reach the server as like '%%' and match everything, which
    // reads as a filter that silently did nothing.
    expect(changes.single.filter.search, isNull);
  });

  testWidgets('a report with no search field gets no search box', (tester) async {
    await pump(
      tester,
      definition: const AdminReportDefinition(
        key: 'tanker-utilisation',
        title: 'Tanker Utilisation',
        filterFields: ['tanker'],
      ),
    );

    expect(find.byType(AppSearchField), findsNothing);
    // And its one entity chip is the tanker, not the driver.
    expect(find.text('Any tanker'), findsOneWidget);
    expect(find.text('All drivers'), findsNothing);
  });

  testWidgets('every chip is the app chip, not a Material one', (tester) async {
    await pump(tester);

    // The point of the rewrite: one control idiom, no ActionChip/InputChip/
    // DropdownButton mixed into the same row.
    expect(find.byType(AppFilterChip), findsNWidgets(2));
    expect(find.byType(DropdownButton<int?>), findsNothing);
    expect(find.byType(ActionChip), findsNothing);
  });
}
