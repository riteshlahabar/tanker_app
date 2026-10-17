import '../../../core/network/api_result.dart';
import '../../../shared/models/paginated.dart';
import '../../../shared/models/driver_expense.dart';

/// Talks to `/api/driver/expenses/*`. Only ever the signed-in driver's own —
/// the panel scopes every query by the token, so there is no driver id here.
abstract interface class ExpenseRepository {
  Future<ApiResult<Paginated<DriverExpense>>> list({int page = 1});

  Future<ApiResult<ExpenseSummary>> summary();

  Future<ApiResult<DriverExpense>> create({
    required DateTime expenseDate,
    required ExpenseCategory category,
    required double amount,
    int? tankerId,
    String? notes,
  });

  Future<ApiResult<DriverExpense>> update(
    int id, {
    required DateTime expenseDate,
    required ExpenseCategory category,
    required double amount,
    int? tankerId,
    String? notes,
  });

  Future<ApiResult<String>> remove(int id);
}
