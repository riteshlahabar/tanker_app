import 'package:intl/intl.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../shared/models/paginated.dart';
import '../../../shared/utils/json_read.dart';
import '../../../shared/models/driver_expense.dart';
import '../domain/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  const ExpenseRepositoryImpl({required ApiClient client}) : _client = client;

  final ApiClient _client;

  static final _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Future<ApiResult<Paginated<DriverExpense>>> list({int page = 1}) =>
      _client.list<DriverExpense>(
        '/driver/expenses',
        query: {'page': page},
        parse: DriverExpense.fromJson,
      );

  @override
  Future<ApiResult<ExpenseSummary>> summary() => _client.get<ExpenseSummary>(
        '/driver/expenses/summary',
        parse: (data) => ExpenseSummary.fromJson(JsonRead.asMap(data)),
      );

  @override
  Future<ApiResult<DriverExpense>> create({
    required DateTime expenseDate,
    required ExpenseCategory category,
    required double amount,
    int? tankerId,
    String? notes,
  }) =>
      _client.post<DriverExpense>(
        '/driver/expenses',
        body: _body(expenseDate, category, amount, tankerId, notes),
        parse: (data) => DriverExpense.fromJson(JsonRead.asMap(data)),
      );

  @override
  Future<ApiResult<DriverExpense>> update(
    int id, {
    required DateTime expenseDate,
    required ExpenseCategory category,
    required double amount,
    int? tankerId,
    String? notes,
  }) =>
      _client.put<DriverExpense>(
        '/driver/expenses/$id',
        body: _body(expenseDate, category, amount, tankerId, notes),
        parse: (data) => DriverExpense.fromJson(JsonRead.asMap(data)),
      );

  @override
  Future<ApiResult<String>> remove(int id) => _client.delete<String>(
        '/driver/expenses/$id',
        parse: (_) => 'deleted',
      );

  /// One body builder for create and update: the panel takes the same fields
  /// for both, so the two can never drift.
  Map<String, dynamic> _body(
    DateTime expenseDate,
    ExpenseCategory category,
    double amount,
    int? tankerId,
    String? notes,
  ) =>
      {
        'expense_date': _dateFormat.format(expenseDate),
        'category': category.value,
        'amount': amount,
        'tanker_id': ?tankerId,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };
}
