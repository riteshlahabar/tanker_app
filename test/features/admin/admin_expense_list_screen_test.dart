import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/core/errors/failure.dart';
import 'package:tanker_app/core/network/api_result.dart';
import 'package:tanker_app/features/admin/domain/admin_expense_repository.dart';
import 'package:tanker_app/features/admin/presentation/providers/admin_providers.dart';
import 'package:tanker_app/features/admin/presentation/screens/admin_expense_list_screen.dart';
import 'package:tanker_app/shared/models/driver_expense.dart';
import 'package:tanker_app/shared/models/paginated.dart';

/// The admin's Driver Expenses screen leads with a money figure, which makes
/// two things non-negotiable and both are asserted here:
///
/// * the figure comes from the **summary endpoint**, never from summing the
///   rows in hand — a page is a slice, and a total that silently reads low is
///   the worst thing a spending screen can do;
/// * when it cannot be fetched the screen says **"Not totalled"** rather than
///   drawing a confident ₹ 0, the same convention as an order's "Not priced
///   yet".
class _FakeAdminExpenseRepository implements AdminExpenseRepository {
  _FakeAdminExpenseRepository({
    required this.items,
    this.summaryResult,
    this.total,
  });

  final List<DriverExpense> items;

  /// Null means the summary call fails.
  final AdminExpenseSummary? summaryResult;

  /// Lets a test claim more rows exist than it returns, so the "that is
  /// everything" line can be exercised both ways.
  final int? total;

  AdminExpenseFilter? listFilter;
  AdminExpenseFilter? summaryFilter;

  @override
  Future<ApiResult<Paginated<DriverExpense>>> list({
    required AdminExpenseFilter filter,
    int page = 1,
  }) async {
    listFilter = filter;

    return Success(
      Paginated<DriverExpense>(
        items: items,
        currentPage: 1,
        lastPage: 1,
        perPage: 20,
        total: total ?? items.length,
        hasMore: false,
      ),
    );
  }

  @override
  Future<ApiResult<AdminExpenseSummary>> summary({required AdminExpenseFilter filter}) async {
    summaryFilter = filter;

    final result = summaryResult;

    // A dropped connection is the realistic way this one call fails while the
    // list beside it succeeds.
    return result == null ? const Error(NetworkFailure()) : Success(result);
  }

  @override
  Future<ApiResult<DriverExpense>> create({
    required int driverId,
    required DateTime expenseDate,
    required ExpenseCategory category,
    required double amount,
    String? notes,
  }) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<DriverExpense>> update(
    int id, {
    required DateTime expenseDate,
    required ExpenseCategory category,
    required double amount,
    String? notes,
  }) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<String>> remove(int id) => throw UnimplementedError();
}

DriverExpense _expense({
  required int id,
  required String driver,
  required String date,
  required num amount,
  String category = 'fuel',
}) =>
    DriverExpense.fromJson(<String, dynamic>{
      'id': id,
      'driver_id': id,
      'driver_name': driver,
      'expense_date': date,
      'category': category,
      'amount': amount,
      'entered_by_admin': false,
    });

const _summary = <String, dynamic>{
  'filtered': {'entries': 3, 'total': 4150, 'fuel': 3700, 'toll': 450},
  'month': {'entries': 9, 'total': 12400, 'fuel': 9000, 'toll': 3400},
};

void main() {
  Future<_FakeAdminExpenseRepository> pumpScreen(
    WidgetTester tester, {
    List<DriverExpense>? items,
    Map<String, dynamic>? summary = _summary,
    int? total,
  }) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final repository = _FakeAdminExpenseRepository(
      items: items ??
          [
            _expense(id: 1, driver: 'Ramesh Patil', date: '2026-10-26', amount: 2500),
            _expense(id: 2, driver: 'Suresh Kale', date: '2026-10-26', amount: 1200),
            _expense(
              id: 3,
              driver: 'Ramesh Patil',
              date: '2026-10-25',
              amount: 450,
              category: 'toll',
            ),
          ],
      summaryResult: summary == null ? null : AdminExpenseSummary.fromJson(summary),
      total: total,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [adminExpenseRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: AdminExpenseListScreen()),
      ),
    );

    await tester.pumpAndSettle();

    return repository;
  }

  testWidgets('leads with the filtered total, not a sum of the rows', (tester) async {
    await pumpScreen(tester);

    // 2500 + 1200 + 450 = 4150 happens to match here, but the figure drawn is
    // the server's `filtered.total`; the month reference beside it is proof,
    // since no row on screen could produce 12,400.
    expect(find.text('₹ 4,150'), findsOneWidget);
    expect(find.textContaining('3 entries'), findsOneWidget);
    expect(find.textContaining('this month ₹ 12,400'), findsOneWidget);
    expect(find.text('Not totalled'), findsNothing);
  });

  testWidgets('says what the total covers, and names the driver when filtered', (tester) async {
    await pumpScreen(tester);

    // Unfiltered, the scope line has to say so — a figure with no stated
    // scope cannot be checked.
    expect(find.textContaining('All drivers'), findsWidgets);
    expect(find.textContaining('all time'), findsOneWidget);
  });

  testWidgets('the category breakdown shows only what was spent', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Fuel ₹ 3,700'), findsOneWidget);
    expect(find.text('Toll ₹ 450'), findsOneWidget);
    // Zero categories are left out so the strip stays readable.
    expect(find.textContaining('Food ₹'), findsNothing);
    expect(find.textContaining('Maintenance ₹'), findsNothing);
  });

  testWidgets('a failed summary reads "Not totalled" and keeps the list', (tester) async {
    await pumpScreen(tester, summary: null);

    expect(find.text('Not totalled'), findsOneWidget);
    expect(find.textContaining('still complete'), findsOneWidget);

    // The decisive half: the rows are untouched, because the list call
    // succeeded and the two are independent.
    expect(find.text('Ramesh Patil'), findsWidgets);
    expect(find.text('Suresh Kale'), findsOneWidget);
    // Never a confident zero.
    expect(find.text('₹ 0'), findsNothing);
  });

  testWidgets('rows are grouped by day, each heading carrying its own total', (tester) async {
    await pumpScreen(tester);

    // Two days, two headings, each naming the weekday — which is how a driver
    // describes a trip when the admin rings to check it.
    expect(find.text('Monday, 26 Oct 2026'), findsOneWidget);
    expect(find.text('Sunday, 25 Oct 2026'), findsOneWidget);

    // 2500 + 1200 on the 26th — a figure no single row carries, so this is
    // the heading's own sum.
    expect(find.text('₹ 3,700'), findsOneWidget);

    // The 25th holds one row, so its heading total and that row's amount are
    // the same words twice. Not a duplicate: one is the day, one is the entry.
    expect(find.text('₹ 450'), findsNWidgets(2));

    // And the rows do not repeat the date the heading above them carries.
    expect(find.textContaining('26 Oct 2026'), findsOneWidget);
    expect(find.text('Fuel'), findsWidgets);
  });

  testWidgets('the list and the summary are asked the same question', (tester) async {
    final repository = await pumpScreen(tester);

    // Same filter object reaching both calls is what keeps the headline figure
    // and the rows in agreement; the backend shares one query builder for the
    // same reason.
    expect(repository.listFilter, isNotNull);
    expect(repository.summaryFilter, isNotNull);
    expect(repository.summaryFilter!.toQuery(), repository.listFilter!.toQuery());
  });

  testWidgets('an empty result offers a way out of the filters', (tester) async {
    await pumpScreen(tester, items: const []);

    expect(find.text('No expenses found'), findsOneWidget);
    // Nothing is filtered, so there is nothing to clear — offering a Clear
    // button here would imply the filters were hiding something.
    expect(find.text('Clear the filters'), findsNothing);
    expect(find.textContaining('Tap Add Expense'), findsOneWidget);
  });
}
