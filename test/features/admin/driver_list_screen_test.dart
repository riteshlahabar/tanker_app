import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/core/network/api_result.dart';
import 'package:tanker_app/features/admin/domain/admin_driver.dart';
import 'package:tanker_app/features/admin/domain/admin_driver_repository.dart';
import 'package:tanker_app/features/admin/domain/entity_list_filter.dart';
import 'package:tanker_app/features/admin/presentation/providers/admin_providers.dart';
import 'package:tanker_app/features/admin/presentation/screens/driver_list_screen.dart';
import 'package:tanker_app/features/admin/presentation/widgets/driver_list_tile.dart';
import 'package:tanker_app/shared/models/paginated.dart';
import 'package:tanker_app/shared/models/tanker_info.dart';

/// The restyled Drivers screen, driven end to end: the filter bar it now
/// shares with Tankers and Orders, the count line, and the cards.
class _FakeRepository implements AdminDriverRepository {
  final filters = <EntityListFilter>[];

  @override
  Future<ApiResult<Paginated<AdminDriver>>> list(
    EntityListFilter filter, {
    int page = 1,
  }) async {
    filters.add(filter);

    return Success(Paginated<AdminDriver>(
      items: const [
        AdminDriver(
          id: 1,
          firstName: 'Manoj',
          lastName: 'Khedkar',
          fullName: 'Manoj Khedkar',
          mobile: '9766697520',
          monthlySalary: 15000,
          status: true,
          tanker: TankerInfo(
            id: 3,
            label: 'Water Tanker 1 (MH12AB1234)',
            vehicleNumber: 'MH12AB1234',
          ),
        ),
        AdminDriver(
          id: 2,
          firstName: 'Rajesh',
          lastName: 'Lahabar',
          fullName: 'Rajesh Lahabar',
          mobile: '7378699893',
          monthlySalary: 0,
          status: false,
        ),
      ],
      currentPage: page,
      lastPage: 1,
      perPage: 20,
      total: 2,
      hasMore: false,
    ));
  }

  @override
  Future<ApiResult<AdminDriver>> create(Map<String, dynamic> fields) => throw UnimplementedError();

  @override
  Future<ApiResult<AdminDriver>> update(int id, Map<String, dynamic> fields) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<String>> delete(int id) => throw UnimplementedError();
}

void main() {
  Future<_FakeRepository> pumpScreen(WidgetTester tester, double width) async {
    final repository = _FakeRepository();

    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [adminDriverRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: DriverListScreen()),
      ),
    );

    await tester.pumpAndSettle();

    return repository;
  }

  /// Scoped to the cards: "Inactive" is also the name of a filter chip, so an
  /// unscoped finder cannot tell the row apart from the control that filters
  /// for it.
  Finder inCards(String text) => find.descendant(
        of: find.byType(DriverListTile),
        matching: find.text(text),
      );

  testWidgets('the list fits a narrow phone and shows what each driver is paid', (tester) async {
    await pumpScreen(tester, 320);

    expect(tester.takeException(), isNull);
    expect(inCards('Manoj Khedkar'), findsOneWidget);
    expect(inCards('₹ 15,000 / mo'), findsOneWidget);
    // The second driver has neither a salary nor a tanker — both are called
    // out rather than left as blanks where a value would be.
    expect(inCards('Salary not set'), findsOneWidget);
    expect(inCards('No tanker assigned'), findsOneWidget);
    expect(inCards('Inactive'), findsOneWidget);
  });

  testWidgets('the count line says how many matched', (tester) async {
    await pumpScreen(tester, 411);

    expect(find.text('2 drivers'), findsOneWidget);
  });

  testWidgets('the status chips filter, and tapping the same one clears it', (tester) async {
    final repository = await pumpScreen(tester, 411);

    expect(repository.filters.last.status, isNull);

    await tester.tap(find.widgetWithText(FilterChip, 'Active'));
    await tester.pumpAndSettle();
    expect(repository.filters.last.status, isTrue);

    // Tapping the active chip again is how a single-choice chip row is
    // un-chosen — there is no "All" chip to go back to.
    await tester.tap(find.widgetWithText(FilterChip, 'Active'));
    await tester.pumpAndSettle();
    expect(repository.filters.last.status, isNull);

    await tester.tap(find.widgetWithText(FilterChip, 'Inactive'));
    await tester.pumpAndSettle();
    expect(repository.filters.last.status, isFalse);
  });

  testWidgets('Clear appears only once something is filtered', (tester) async {
    await pumpScreen(tester, 411);

    expect(find.text('Clear'), findsNothing);

    await tester.tap(find.widgetWithText(FilterChip, 'Active'));
    await tester.pumpAndSettle();

    expect(find.text('Clear'), findsOneWidget);
  });

  testWidgets('the search box names the fields the server matches', (tester) async {
    await pumpScreen(tester, 411);

    expect(find.text('Search by name or mobile'), findsOneWidget);
  });

  testWidgets('the add button says what it adds', (tester) async {
    await pumpScreen(tester, 411);

    expect(find.widgetWithText(FloatingActionButton, 'Add Driver'), findsOneWidget);
  });
}
