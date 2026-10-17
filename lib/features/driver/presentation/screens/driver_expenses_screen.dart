import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/models/driver_expense.dart';
import '../providers/driver_expenses_controller.dart';
import '../../../../shared/widgets/expense_list_tile.dart';
import '../widgets/expense_totals_header.dart';
import 'expense_form_screen.dart';

/// Expenses tab body — what this driver spent, newest first, with this
/// month's totals above it and an Add button.
class DriverExpensesScreen extends ConsumerStatefulWidget {
  const DriverExpensesScreen({super.key});

  @override
  ConsumerState<DriverExpensesScreen> createState() => _DriverExpensesScreenState();
}

class _DriverExpensesScreenState extends ConsumerState<DriverExpensesScreen> {
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
      ref.read(driverExpensesControllerProvider.notifier).loadMore();
    }
  }

  Future<void> _openForm([DriverExpense? existing]) => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => ExpenseFormScreen(existing: existing)),
      );

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(driverExpensesControllerProvider);

    return Scaffold(
      // The tab body sits inside the shell, which already draws the app bar
      // and the bottom bar, so this Scaffold only carries the action button.
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(driverExpensesControllerProvider.notifier).refresh(),
        child: _body(state),
      ),
    );
  }

  Widget _body(DriverExpensesState state) {
    final items = state.paginated.items;

    if (state.loading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      // Still scrollable, so pull-to-refresh works on an empty list.
      return ListView(
        controller: _scrollController,
        children: [
          ExpenseTotalsHeader(summary: state.summary),
          const SizedBox(height: 40),
          EmptyState(
            icon: Icons.receipt_long_outlined,
            title: state.error?.message ?? 'No expenses yet',
            message: state.error == null
                ? 'Tap Add when you fill up or pay a toll.'
                : 'Pull down to try again.',
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      // One for the totals header, one per row, one more for the footer
      // spinner while the next page loads.
      itemCount: items.length + (state.loadingMore ? 2 : 1),
      itemBuilder: (context, index) {
        if (index == 0) return ExpenseTotalsHeader(summary: state.summary);

        final row = index - 1;

        if (row >= items.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return ExpenseListTile(
          expense: items[row],
          onTap: () => _openForm(items[row]),
        );
      },
    );
  }
}
