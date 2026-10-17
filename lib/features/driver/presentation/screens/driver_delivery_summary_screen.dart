import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/driver_salary.dart';
import '../providers/driver_salary_controller.dart';

/// The driver's own delivery figures — today's, plus the same for a date
/// range — from `GET /api/driver/salary`.
///
/// No money per delivery: drivers are salaried. The salary itself is a
/// read-only line on the Profile tab, not here, so one screen owns it.
class DriverDeliverySummaryScreen extends ConsumerWidget {
  const DriverDeliverySummaryScreen({super.key});

  static final _dateFormat = DateFormat('d MMM yyyy');

  Future<void> _pickRange(BuildContext context, WidgetRef ref, DateTime from, DateTime to) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: from, end: to),
    );

    if (picked == null) return;

    await ref.read(driverSalaryControllerProvider.notifier).setRange(picked.start, picked.end);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(driverSalaryControllerProvider);
    final salary = state.salary;

    if (state.loading && salary == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (salary == null) {
      return Center(child: Text(state.error?.message ?? 'Could not load your deliveries.'));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(driverSalaryControllerProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Today', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          _totalsRow(salary.today),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_dateFormat.format(salary.from)} – ${_dateFormat.format(salary.to)}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              TextButton(
                onPressed: () => _pickRange(context, ref, salary.from, salary.to),
                child: const Text('Change range'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _totalsRow(salary.range),
        ],
      ),
    );
  }

  Widget _totalsRow(DeliveryTotals totals) => Row(
        children: [
          _statTile('Delivered', '${totals.delivered}'),
          _statTile('Tankers', '${totals.tankers}'),
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
