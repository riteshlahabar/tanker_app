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
