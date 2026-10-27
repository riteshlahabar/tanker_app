import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/colors.dart';
import '../../../../shared/models/driver_expense.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/expense_list_tile.dart';
import '../../../../shared/widgets/shell_tab_bar.dart';
import '../../domain/admin_expense_repository.dart';
import '../providers/admin_expenses_controller.dart';
import '../widgets/admin_expense_filter_bar.dart';
import '../widgets/admin_expense_totals_card.dart';
import 'admin_expense_form_screen.dart';

/// Every driver's spending, from the drawer. Mirrors the web panel's Driver
/// Expenses screen: the same filters, and the same ability to record one on a
/// driver's behalf when they have not.
///
/// The page is read top to bottom as one question and its answer — **how much
/// are we spending** (the totals card), **on what** (the filters, which move
/// the card with them), and **the entries themselves**, grouped by day so a
/// date is read once per day rather than repeated down every row.
///
/// The whole thing scrolls as one list rather than a fixed header over a
/// scrolling body: the card is the least urgent thing on screen once the
/// admin starts reading rows, and keeping it pinned would cost a third of a
/// phone's height to a figure they have already read.
class AdminExpenseListScreen extends ConsumerStatefulWidget {
  const AdminExpenseListScreen({super.key});

  @override
  ConsumerState<AdminExpenseListScreen> createState() => _AdminExpenseListScreenState();
}

class _AdminExpenseListScreenState extends ConsumerState<AdminExpenseListScreen> {
  final _scrollController = ScrollController();

  static final _dayHeading = DateFormat('EEEE, d MMM yyyy');
  static final _money = NumberFormat.decimalPattern('en_IN');

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
        label: const Text('Add Expense'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(adminExpensesControllerProvider.notifier).refresh(),
        child: ListView(
          controller: _scrollController,
          // 90 at the bottom clears the extended FAB, which otherwise sits on
          // top of the last row.
          padding: const EdgeInsets.only(bottom: 90),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: AdminExpenseTotalsCard(summary: state.summary, filter: state.filter),
            ),
            AdminExpenseFilterBar(filter: state.filter),
            const SizedBox(height: 6),
            ..._body(state),
          ],
        ),
      ),
    );
  }

  List<Widget> _body(AdminExpensesState state) {
    if (state.loading && state.paginated.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 64),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (state.paginated.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: EmptyState(
            icon: Icons.receipt_long_outlined,
            title: state.error?.message ?? 'No expenses found',
            message: state.isFiltered
                ? 'Nothing matches these filters.'
                : 'Tap Add Expense to record one for a driver.',
          ),
        ),
        if (state.isFiltered)
          Center(
            child: TextButton.icon(
              onPressed: () => ref
                  .read(adminExpensesControllerProvider.notifier)
                  .setFilter(const AdminExpenseFilter()),
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Clear the filters'),
            ),
          ),
      ];
    }

    return [
      ..._groupedRows(state.paginated.items),
      if (state.loadingMore)
        const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        )
      else if (!state.paginated.hasMore)
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Center(
            child: Text(
              'That is every expense for this filter.',
              style: TextStyle(fontSize: 12, color: appTextColorSecondary),
            ),
          ),
        ),
    ];
  }

  /// The rows, with a heading at each change of day.
  ///
  /// The server already orders by `expense_date` descending, so a day is a run
  /// of adjacent rows and grouping is a single pass — no sorting here, which
  /// would also be wrong: it would reorder only the page in hand.
  ///
  /// Each heading carries that day's own total, which is the figure an admin
  /// reconciles against a driver's claim for the day.
  List<Widget> _groupedRows(List<DriverExpense> expenses) {
    // Totals first, in one pass, so a heading does not rescan the list for its
    // own day — that turned a long page into an O(n²) build.
    final dayTotals = <DateTime, double>{};

    for (final expense in expenses) {
      final day = DateUtils.dateOnly(expense.expenseDate);

      dayTotals[day] = (dayTotals[day] ?? 0) + expense.amount;
    }

    final rows = <Widget>[];
    DateTime? current;

    for (var i = 0; i < expenses.length; i++) {
      final expense = expenses[i];
      final day = DateUtils.dateOnly(expense.expenseDate);

      if (day != current) {
        current = day;
        rows.add(_DayHeading(
          label: _dayHeading.format(day),
          total: _money.format((dayTotals[day] ?? 0).round()),
          first: i == 0,
        ));
      }

      rows.add(
        ExpenseListTile(
          expense: expense,
          // The admin is looking across everybody, so the name leads the row.
          showDriver: true,
          // The heading above already carries the date.
          showDate: false,
          onTap: () => _openForm(expense),
        ),
      );
    }

    return rows;
  }
}

/// A day's heading: the date, a hairline, and that day's total.
///
/// The total here is honest about its scope — it sums the rows **loaded**, and
/// a day is never split across a page because the server orders by date, so by
/// the time a day's heading is on screen with rows under it the day is whole.
/// The one exception is the last day on the page, which is why the list keeps
/// paging on scroll rather than stopping.
class _DayHeading extends StatelessWidget {
  const _DayHeading({required this.label, required this.total, required this.first});

  final String label;
  final String total;

  /// No top gap on the first heading — the filter bar already provides it.
  final bool first;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, first ? 6 : 18, 16, 6),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: appTextColorSecondary,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1,
              color: appTextColorSecondary.withValues(alpha: 0.15),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '₹ $total',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: appTextColorSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
