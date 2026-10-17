import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/shared/models/driver_expense.dart';

void main() {
  group('DriverExpense.fromJson', () {
    test('reads an amount the panel sent as an int', () {
      // PHP's json_encode emits an integral float as 2500, not 2500.0 —
      // `as double` on that throws.
      final expense = DriverExpense.fromJson(const {
        'id': 1,
        'driver_id': 7,
        'expense_date': '2026-10-17',
        'category': 'fuel',
        'amount': 2500,
        'entered_by_admin': false,
      });

      expect(expense.amount, 2500.0);
      expect(expense.category, ExpenseCategory.fuel);
      expect(expense.expenseDate.year, 2026);
    });

    test('marks a row the office added, so the driver knows where it came from', () {
      final mine = DriverExpense.fromJson(const {
        'id': 1,
        'driver_id': 7,
        'expense_date': '2026-10-17',
        'category': 'fuel',
        'amount': 100,
        'entered_by_admin': false,
      });

      final theirs = DriverExpense.fromJson(const {
        'id': 2,
        'driver_id': 7,
        'expense_date': '2026-10-17',
        'category': 'fuel',
        'amount': 100,
        'entered_by_admin': true,
        'entered_by_name': 'Owner',
      });

      expect(mine.enteredByAdmin, isFalse);
      expect(theirs.enteredByAdmin, isTrue);
      expect(theirs.enteredByName, 'Owner');
    });
  });

  group('ExpenseCategory', () {
    test('matches the panel enum value for value', () {
      expect(
        ExpenseCategory.values.map((c) => c.value).toList(),
        ['fuel', 'toll', 'maintenance', 'food', 'other'],
      );
    });

    test('an unknown category falls back rather than crashing an older build', () {
      // A category added on the panel must never take the app down.
      expect(ExpenseCategory.parse('helicopter'), ExpenseCategory.other);
      expect(ExpenseCategory.parse(null), ExpenseCategory.other);
    });
  });

  group('ExpenseTotals', () {
    test('every category is present even at zero, so the header keeps its shape', () {
      final totals = ExpenseTotals.fromJson(const {
        'entries': 3,
        'total': 2590,
        'fuel': 2500,
        'toll': 90,
      });

      expect(totals.entries, 3);
      expect(totals.total, 2590.0);
      expect(totals.of(ExpenseCategory.fuel), 2500.0);
      expect(totals.of(ExpenseCategory.toll), 90.0);
      // Absent from the payload entirely — still readable as zero.
      expect(totals.of(ExpenseCategory.food), 0.0);
      expect(totals.byCategory.length, ExpenseCategory.values.length);
    });

    test('summary splits today from this month', () {
      final summary = ExpenseSummary.fromJson(const {
        'today': {'entries': 1, 'total': 500, 'fuel': 500},
        'month': {'entries': 4, 'total': 3000, 'fuel': 2900, 'toll': 100},
      });

      expect(summary.today.total, 500.0);
      expect(summary.month.total, 3000.0);
      expect(summary.month.of(ExpenseCategory.toll), 100.0);
    });
  });
}
