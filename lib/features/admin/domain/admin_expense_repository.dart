import '../../../core/network/api_result.dart';
import '../../../shared/models/driver_expense.dart';
import '../../../shared/models/paginated.dart';

/// The filters `/api/admin/expenses` understands, held together so the list
/// screen passes one value around instead of five.
class AdminExpenseFilter {
  const AdminExpenseFilter({
    this.driverId,
    this.category,
    this.from,
    this.to,
    this.search,
  });

  final int? driverId;
  final ExpenseCategory? category;
  final DateTime? from;
  final DateTime? to;
  final String? search;

  AdminExpenseFilter copyWith({
    int? driverId,
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
        category: clearCategory ? null : (category ?? this.category),
        from: clearRange ? null : (from ?? this.from),
        to: clearRange ? null : (to ?? this.to),
        search: search ?? this.search,
      );

  bool get hasRange => from != null && to != null;
}

/// Talks to `/api/admin/expenses`. Unlike the driver's own repository this one
/// names the driver, because an admin files on somebody else's behalf.
abstract interface class AdminExpenseRepository {
  Future<ApiResult<Paginated<DriverExpense>>> list({
    required AdminExpenseFilter filter,
    int page = 1,
  });

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
