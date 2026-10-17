import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/core/network/api_result.dart';
import 'package:tanker_app/features/admin/domain/admin_tanker.dart';
import 'package:tanker_app/features/admin/domain/admin_tanker_repository.dart';
import 'package:tanker_app/features/admin/domain/entity_list_filter.dart';
import 'package:tanker_app/features/admin/presentation/providers/admin_providers.dart';
import 'package:tanker_app/features/admin/presentation/screens/tanker_list_screen.dart';
import 'package:tanker_app/features/admin/presentation/widgets/tanker_list_tile.dart';
import 'package:tanker_app/shared/models/paginated.dart';

/// The restyled Tankers screen, driven end to end: the filter bar it now
/// shares with the Orders screen, the count line, and the cards.
class _FakeRepository implements AdminTankerRepository {
  final filters = <EntityListFilter>[];

  @override
  Future<ApiResult<Paginated<AdminTanker>>> list(
    EntityListFilter filter, {
    int page = 1,
    int? perPage,
  }) async {
    filters.add(filter);

    return Success(Paginated<AdminTanker>(
      items: const [
        AdminTanker(
          id: 1,
          vehicleName: 'Water Tanker 1',
          vehicleNumber: 'MH12AB1234',
          label: 'Water Tanker 1 (MH12AB1234)',
          status: true,
          capacityLitres: 5000,
          tankerRate: 1200,
          currentDriver: 'Rajesh Lahabar',
        ),
        AdminTanker(
          id: 2,
          vehicleName: 'Water Tanker 2',
          vehicleNumber: 'MH14ZZ9999',
          label: 'Water Tanker 2 (MH14ZZ9999)',
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
  Future<ApiResult<AdminTanker>> create(Map<String, dynamic> fields) => throw UnimplementedError();

  @override
  Future<ApiResult<AdminTanker>> update(int id, Map<String, dynamic> fields) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<String>> delete(int id) => throw UnimplementedError();

  @override
  Future<ApiResult<List<AdminTanker>>> unassigned({int? keepTankerId}) =>
      throw UnimplementedError();
}

void main() {
  Future<_FakeRepository> pumpScreen(WidgetTester tester, double width) async {
    final repository = _FakeRepository();

    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [adminTankerRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: TankerListScreen()),
      ),
    );

    await tester.pumpAndSettle();

    return repository;
  }

  /// Scoped to the cards: "Inactive" is also the name of a filter chip, so an
  /// unscoped finder cannot tell the row apart from the control that filters
  /// for it.
  Finder inCards(String text) => find.descendant(
        of: find.byType(TankerListTile),
        matching: find.text(text),
      );

  testWidgets('the list fits a narrow phone and shows what each tanker costs', (tester) async {
    await pumpScreen(tester, 320);

    expect(tester.takeException(), isNull);
    expect(inCards('MH12AB1234'), findsOneWidget);
    expect(inCards('₹ 1200 / tanker'), findsOneWidget);
    // The second tanker has neither rate nor driver — both are called out
    // rather than left as blanks where a value would be.
    expect(inCards('Rate not set'), findsOneWidget);
    expect(inCards('No driver assigned'), findsOneWidget);
    expect(inCards('Inactive'), findsOneWidget);
  });

  testWidgets('the count line says how many matched', (tester) async {
    await pumpScreen(tester, 411);

    expect(find.text('2 tankers'), findsOneWidget);
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

  testWidgets('the add button says what it adds', (tester) async {
    await pumpScreen(tester, 411);

    expect(find.widgetWithText(FloatingActionButton, 'Add Tanker'), findsOneWidget);
  });
}
