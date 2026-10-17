import 'package:flutter/material.dart';

import '../utils/json_read.dart';

/// Mirrors the panel's `ExpenseCategoryEnum`. The colours are the app's own —
/// the panel's badge classes are Cuba's and do not travel.
enum ExpenseCategory {
  fuel('fuel', 'Fuel', Color(0xFF1157FA)),
  toll('toll', 'Toll', Color(0xFF0DA6B8)),
  maintenance('maintenance', 'Maintenance', Color(0xFFE2A03F)),
  food('food', 'Food', Color(0xFF927160)),
  other('other', 'Other', Color(0xFF7A7A7A));

  const ExpenseCategory(this.value, this.label, this.color);

  final String value;
  final String label;
  final Color color;

  /// Falls back to [other] rather than throwing: a category added on the panel
  /// must never crash an older build.
  static ExpenseCategory parse(String? raw) => values.firstWhere(
        (category) => category.value == raw,
        orElse: () => ExpenseCategory.other,
      );
}

class DriverExpense {
  const DriverExpense({
    required this.id,
    required this.driverId,
    required this.expenseDate,
    this.driverName,
    required this.category,
    required this.amount,
    required this.enteredByAdmin,
    this.tankerId,
    this.tankerLabel,
    this.notes,
    this.enteredByName,
  });

  final int id;
  final int driverId;

  /// Only the admin list needs this — a driver reading their own expenses
  /// already knows whose they are.
  final String? driverName;
  final DateTime expenseDate;
  final ExpenseCategory category;

  /// `num` on the wire — an integral amount arrives as an `int`.
  final double amount;

  /// True when the office recorded it rather than the driver. Shown on the
  /// row, or a driver has no way to tell where an entry came from.
  final bool enteredByAdmin;
  final int? tankerId;
  final String? tankerLabel;
  final String? notes;
  final String? enteredByName;

  factory DriverExpense.fromJson(Map<String, dynamic> json) => DriverExpense(
        id: JsonRead.asInt(json['id']),
        driverId: JsonRead.asInt(json['driver_id']),
        driverName: JsonRead.asStringOrNull(json['driver_name']),
        expenseDate: JsonRead.asDate(json['expense_date']) ?? DateTime.now(),
        category: ExpenseCategory.parse(JsonRead.asStringOrNull(json['category'])),
        amount: JsonRead.asDouble(json['amount']),
        enteredByAdmin: JsonRead.asBool(json['entered_by_admin']),
        tankerId: json['tanker_id'] == null ? null : JsonRead.asInt(json['tanker_id']),
        tankerLabel: JsonRead.asStringOrNull(json['tanker_label']),
        notes: JsonRead.asStringOrNull(json['notes']),
        enteredByName: JsonRead.asStringOrNull(json['entered_by_name']),
      );
}

/// Totals by category for one period, as `ExpenseSummaryController` returns
/// them. Every category is present even at zero, so the header never changes
/// shape with the data.
class ExpenseTotals {
  const ExpenseTotals({
    required this.entries,
    required this.total,
    required this.byCategory,
  });

  final int entries;
  final double total;
  final Map<ExpenseCategory, double> byCategory;

  factory ExpenseTotals.fromJson(Map<String, dynamic> json) => ExpenseTotals(
        entries: JsonRead.asInt(json['entries']),
        total: JsonRead.asDouble(json['total']),
        byCategory: {
          for (final category in ExpenseCategory.values)
            category: JsonRead.asDouble(json[category.value]),
        },
      );

  static const empty = ExpenseTotals(entries: 0, total: 0, byCategory: {});

  double of(ExpenseCategory category) => byCategory[category] ?? 0;
}

class ExpenseSummary {
  const ExpenseSummary({required this.today, required this.month});

  final ExpenseTotals today;
  final ExpenseTotals month;

  factory ExpenseSummary.fromJson(Map<String, dynamic> json) => ExpenseSummary(
        today: ExpenseTotals.fromJson(JsonRead.asMap(json['today'])),
        month: ExpenseTotals.fromJson(JsonRead.asMap(json['month'])),
      );

  static const empty = ExpenseSummary(today: ExpenseTotals.empty, month: ExpenseTotals.empty);
}
