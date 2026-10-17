import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/driver_expense.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/expense_list_tile.dart';
import '../../../../shared/widgets/shell_tab_bar.dart';
import '../providers/admin_expenses_controller.dart';
import '../widgets/admin_expense_filter_bar.dart';
import 'admin_expense_form_screen.dart';

/// Every driver's spending, from the drawer. Mirrors the web panel's Driver
/// Expenses screen: the same filters, and the same ability to record one on a
/// driver's behalf when they have not.
class AdminExpenseListScreen extends ConsumerStatefulWidget {
  const AdminExpenseListScreen({super.key});

  @override
  ConsumerState<AdminExpenseListScreen> createState() => _AdminExpenseListScreenState();
}

class _AdminExpenseListScreenState extends ConsumerState<AdminExpenseListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 200) {
      ref.read(adminExpensesControllerProvider.notifier).loadMore();
    }
  }

  Future<void> _openForm([DriverExpense? existing]) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => AdminExpenseFormScreen(existing: existing)),
    );

    if (mounted) {
      await ref.read(adminExpensesControllerProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminExpensesControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Driver Expenses')),
      bottomNavigationBar: const ShellTabBar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: Column(
        children: [
          AdminExpenseFilterBar(filter: state.filter),
          Expanded(child: _list(state)),
        ],
      ),
    );
  }

  Widget _list(AdminExpensesState state) {
    if (state.loading && state.paginated.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.paginated.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long_outlined,
        title: state.error?.message ?? 'No expenses found',
        message: state.isFiltered
            ? 'Nothing matches these filters.'
            : 'Tap Add to record one for a driver.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(adminExpensesControllerProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.paginated.items.length + (state.loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.paginated.items.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final expense = state.paginated.items[index];

          return ExpenseListTile(
            expense: expense,
            // The admin is looking across everybody, so the name leads the row.
            showDriver: true,
            onTap: () => _openForm(expense),
          );
        },
      ),
    );
  }
}
