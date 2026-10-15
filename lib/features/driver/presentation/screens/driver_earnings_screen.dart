import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/driver_earnings.dart';
import '../providers/driver_earnings_controller.dart';

/// Earnings tab body — today's figures plus the same for a date range,
/// straight from `GET /api/driver/earnings`.
class DriverEarningsScreen extends ConsumerWidget {
  const DriverEarningsScreen({super.key});

  static final _dateFormat = DateFormat('d MMM yyyy');

  Future<void> _pickRange(BuildContext context, WidgetRef ref, DateTime from, DateTime to) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: from, end: to),
    );

    if (picked == null) return;

    await ref.read(driverEarningsControllerProvider.notifier).setRange(picked.start, picked.end);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(driverEarningsControllerProvider);
    final earnings = state.earnings;

    if (state.loading && earnings == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (earnings == null) {
      return Center(child: Text(state.error?.message ?? 'Could not load earnings.'));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(driverEarningsControllerProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Today', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          _totalsRow(earnings.today),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_dateFormat.format(earnings.from)} – ${_dateFormat.format(earnings.to)}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              TextButton(
                onPressed: () => _pickRange(context, ref, earnings.from, earnings.to),
                child: const Text('Change range'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _totalsRow(earnings.range),
        ],
      ),
    );
  }

  Widget _totalsRow(EarningsTotals totals) => Row(
        children: [
          _statTile('Delivered', '${totals.delivered}'),
          _statTile('Earning', '₹ ${totals.earning.toStringAsFixed(0)}'),
          _statTile('Order value', '₹ ${totals.orderValue.toStringAsFixed(0)}'),
        ],
      );

  Widget _statTile(String label, String value) => Expanded(
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      );
}
