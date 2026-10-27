import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/features/admin/domain/admin_expense_repository.dart';
import 'package:tanker_app/shared/models/driver_expense.dart';

void main() {
  group('AdminExpenseFilter', () {
    test('starts empty, so the first load asks for everything', () {
      const filter = AdminExpenseFilter();

      expect(filter.driverId, isNull);
      expect(filter.category, isNull);
      expect(filter.hasRange, isFalse);
    });

    test('hasRange needs both ends, not one', () {
      // The API takes from/to as a pair; sending one alone would silently
      // widen the other end.
      final halfOpen = AdminExpenseFilter(from: DateTime(2026, 10, 1));

      expect(halfOpen.hasRange, isFalse);

      final both = AdminExpenseFilter(from: DateTime(2026, 10, 1), to: DateTime(2026, 10, 31));

      expect(both.hasRange, isTrue);
    });

    test('copyWith keeps what it is not asked to change', () {
      final filter = AdminExpenseFilter(
        driverId: 7,
        category: ExpenseCategory.fuel,
        from: DateTime(2026, 10, 1),
        to: DateTime(2026, 10, 31),
        search: 'diesel',
      );

      final narrowed = filter.copyWith(category: ExpenseCategory.toll);

      expect(narrowed.driverId, 7);
      expect(narrowed.category, ExpenseCategory.toll);
      expect(narrowed.search, 'diesel');
      expect(narrowed.hasRange, isTrue);
    });

    test('each clear flag drops only its own field', () {
      final filter = AdminExpenseFilter(
        driverId: 7,
        category: ExpenseCategory.fuel,
        from: DateTime(2026, 10, 1),
        to: DateTime(2026, 10, 31),
      );

      expect(filter.copyWith(clearDriver: true).driverId, isNull);
      expect(filter.copyWith(clearDriver: true).category, ExpenseCategory.fuel);

      expect(filter.copyWith(clearCategory: true).category, isNull);
      expect(filter.copyWith(clearCategory: true).driverId, 7);

      expect(filter.copyWith(clearRange: true).hasRange, isFalse);
      expect(filter.copyWith(clearRange: true).driverId, 7);
    });

    test('clearing the driver drops the name with the id', () {
      // The name is only ever shown *because* of the id. Leaving it behind
      // would put "Ramesh Patil" on a chip that is no longer filtering, and
      // on the totals card's line saying whose figure is on screen.
      const filter = AdminExpenseFilter(driverId: 7, driverName: 'Ramesh Patil');

      expect(filter.copyWith(clearDriver: true).driverName, isNull);
    });

    test('toQuery is what both the list and the summary send', () {
      // The screen shows a total above the rows it lists, so the two requests
      // must carry the same filters — they share this one builder for that
      // reason. A filter that reached only one of them would print a figure
      // that disagrees with the list under it.
      final filter = AdminExpenseFilter(
        driverId: 7,
        driverName: 'Ramesh Patil',
        category: ExpenseCategory.fuel,
        from: DateTime(2026, 10, 1),
        to: DateTime(2026, 10, 31),
        search: 'diesel',
      );

      expect(filter.toQuery(), {
        'driver_id': 7,
        'category': 'fuel',
        'from': '2026-10-01',
        'to': '2026-10-31',
        'search': 'diesel',
      });

      // The name is display only — sending it would 422 on a validated query.
      expect(filter.toQuery().containsKey('driver_name'), isFalse);
    });

    test('toQuery leaves out what is not set rather than sending blanks', () {
      expect(const AdminExpenseFilter().toQuery(), isEmpty);
      // An empty search box is not a search for "".
      expect(const AdminExpenseFilter(search: '').toQuery(), isEmpty);
    });
  });

  group('AdminExpenseSummary', () {
    test('carries both figures, and every category even at zero', () {
      final summary = AdminExpenseSummary.fromJson(const {
        'filtered': {'entries': 2, 'total': 1500, 'fuel': 1200, 'toll': 300},
        'month': {'entries': 3, 'total': 2400, 'fuel': 2100, 'toll': 300},
      });

      expect(summary.filtered.total, 1500);
      expect(summary.filtered.entries, 2);
      expect(summary.filtered.of(ExpenseCategory.fuel), 1200);
      // Absent from the payload above, present as 0 here, so the header never
      // changes shape with the data.
      expect(summary.filtered.of(ExpenseCategory.maintenance), 0);

      // `month` ignores the filters on purpose — it is the fixed reference.
      expect(summary.month.total, 2400);
    });

    test('integral money arrives as an int and still reads as a double', () {
      // CLAUDE.md rule 7: PHP sends 1500.0 as 1500, and `as double` on an int
      // throws. JsonRead is what stops that.
      final summary = AdminExpenseSummary.fromJson(const {
        'filtered': {'entries': 1, 'total': 1500, 'fuel': 1500},
        'month': {'entries': 1, 'total': 1500.5, 'fuel': 1500.5},
      });

      expect(summary.filtered.total, isA<double>());
      expect(summary.filtered.total, 1500.0);
      expect(summary.month.total, 1500.5);
    });
  });

  group('the admin list row', () {
    test('reads the driver name the admin endpoint adds', () {
      // `driver_name` is only populated on the admin list — the driver's own
      // list has no use for it, so it stays nullable.
      final expense = DriverExpense.fromJson(const {
        'id': 1,
        'driver_id': 7,
        'driver_name': 'Ramesh',
        'expense_date': '2026-10-17',
        'category': 'fuel',
        'amount': 2500,
        'entered_by_admin': true,
      });

      expect(expense.driverName, 'Ramesh');
      expect(expense.enteredByAdmin, isTrue);
    });

    test('a driver-side payload without the name still parses', () {
      final expense = DriverExpense.fromJson(const {
        'id': 1,
        'driver_id': 7,
        'expense_date': '2026-10-17',
        'category': 'toll',
        'amount': 90,
        'entered_by_admin': false,
      });

      expect(expense.driverName, isNull);
    });
  });
}
