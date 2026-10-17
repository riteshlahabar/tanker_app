import 'package:intl/intl.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../shared/models/driver_expense.dart';
import '../../../shared/models/paginated.dart';
import '../../../shared/utils/json_read.dart';
import '../domain/admin_expense_repository.dart';

class AdminExpenseRepositoryImpl implements AdminExpenseRepository {
  const AdminExpenseRepositoryImpl({required ApiClient client}) : _client = client;

  final ApiClient _client;

  static final _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Future<ApiResult<Paginated<DriverExpense>>> list({
    required AdminExpenseFilter filter,
    int page = 1,
  }) =>
      _client.list<DriverExpense>(
        '/admin/expenses',
        query: {
          'page': page,
          'driver_id': ?filter.driverId,
          if (filter.category != null) 'category': filter.category!.value,
          if (filter.from != null) 'from': _dateFormat.format(filter.from!),
          if (filter.to != null) 'to': _dateFormat.format(filter.to!),
          if (filter.search != null && filter.search!.isNotEmpty) 'search': filter.search,
        },
        parse: DriverExpense.fromJson,
      );

  @override
  Future<ApiResult<DriverExpense>> create({
    required int driverId,
    required DateTime expenseDate,
    required ExpenseCategory category,
    required double amount,
    String? notes,
  }) =>
      _client.post<DriverExpense>(
        '/admin/expenses',
        body: {
          'driver_id': driverId,
          ..._body(expenseDate, category, amount, notes),
        },
        parse: (data) => DriverExpense.fromJson(JsonRead.asMap(data)),
      );

  @override
  Future<ApiResult<DriverExpense>> update(
    int id, {
    required DateTime expenseDate,
    required ExpenseCategory category,
    required double amount,
    String? notes,
  }) =>
      _client.put<DriverExpense>(
        // No driver_id: the panel refuses to move an expense between drivers,
        // because that would quietly rewrite both their totals.
        '/admin/expenses/$id',
        body: _body(expenseDate, category, amount, notes),
        parse: (data) => DriverExpense.fromJson(JsonRead.asMap(data)),
      );

  @override
  Future<ApiResult<String>> remove(int id) => _client.delete<String>(
        '/admin/expenses/$id',
        parse: (_) => 'deleted',
      );

  Map<String, dynamic> _body(
    DateTime expenseDate,
    ExpenseCategory category,
    double amount,
    String? notes,
  ) =>
      {
        'expense_date': _dateFormat.format(expenseDate),
        'category': category.value,
        'amount': amount,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };
}
