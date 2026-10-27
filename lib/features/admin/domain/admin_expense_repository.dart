import 'package:intl/intl.dart';

import '../../../core/network/api_result.dart';
import '../../../shared/models/driver_expense.dart';
import '../../../shared/models/paginated.dart';

/// The filters `/api/admin/expenses` understands, held together so the list
/// screen passes one value around instead of five.
class AdminExpenseFilter {
  const AdminExpenseFilter({
    this.driverId,
    this.driverName,
    this.category,
    this.from,
    this.to,
    this.search,
  });

  final int? driverId;

  /// Carried beside the id purely so the screen can **name** the driver — on
  /// the filter chip and in the line that says what the total covers. A chip
  /// reading "Driver chosen" and a figure that does not say whose it is are
  /// the same fault twice: the admin cannot check the number without
  /// reopening the picker.
  final String? driverName;

  final ExpenseCategory? category;
  final DateTime? from;
  final DateTime? to;
  final String? search;

  AdminExpenseFilter copyWith({
    int? driverId,
    String? driverName,
    ExpenseCategory? category,
    DateTime? from,
    DateTime? to,
    String? search,
    bool clearDriver = false,
    bool clearCategory = false,
    bool clearRange = false,
  }) =>
      AdminExpenseFilter(
        driverId: clearDriver ? null : (driverId ?? this.driverId),
        driverName: clearDriver ? null : (driverName ?? this.driverName),
        category: clearCategory ? null : (category ?? this.category),
        from: clearRange ? null : (from ?? this.from),
        to: clearRange ? null : (to ?? this.to),
        search: search ?? this.search,
      );

  bool get hasRange => from != null && to != null;

  /// The query string, built **once** for both the list and the summary.
  ///
  /// The panel applies these filters in a single repository method for the
  /// same reason (`ExpenseRepository::filtered()`): the screen shows a total
  /// above the rows it lists, and a total built from a slightly different
  /// query would be worse than none — the admin would be reconciling two
  /// figures that were never asking the same thing.
  Map<String, dynamic> toQuery() => {
        'driver_id': ?driverId,
        if (category != null) 'category': category!.value,
        if (from != null) 'from': _apiDate.format(from!),
        if (to != null) 'to': _apiDate.format(to!),
        if (search != null && search!.isNotEmpty) 'search': search,
      };

  static final _apiDate = DateFormat('yyyy-MM-dd');
}

/// Talks to `/api/admin/expenses`. Unlike the driver's own repository this one
/// names the driver, because an admin files on somebody else's behalf.
abstract interface class AdminExpenseRepository {
  Future<ApiResult<Paginated<DriverExpense>>> list({
    required AdminExpenseFilter filter,
    int page = 1,
  });

  /// Spending totals for the **same** filter the list was fetched with, so the
  /// headline figure and the rows under it never answer different questions.
  Future<ApiResult<AdminExpenseSummary>> summary({required AdminExpenseFilter filter});

  Future<ApiResult<DriverExpense>> create({
    required int driverId,
    required DateTime expenseDate,
    required ExpenseCategory category,
    required double amount,
    String? notes,
  });

  Future<ApiResult<DriverExpense>> update(
    int id, {
    required DateTime expenseDate,
    required ExpenseCategory category,
    required double amount,
    String? notes,
  });

  Future<ApiResult<String>> remove(int id);
}
