import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../domain/billing_summary.dart';
import '../providers/billing_provider.dart';

/// What the customer has been billed — month by month, day by day, and the
/// tankers behind each figure.
///
/// This tab used to be Notifications, which had no backend to read: every real
/// notice goes to WhatsApp, so it showed the order list a second time under a
/// bell icon. Billing is the question the customer actually opens the app
/// with, and the answer is already in their orders.
///
/// Nothing here is invented or rounded: a day's total is the sum of its
/// orders, and each line shows the loads and the rate those orders were
/// priced at, so the arithmetic can be checked rather than trusted.
class BillingScreen extends ConsumerWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billing = ref.watch(customerBillingProvider);

    return billing.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Could not load your billing',
        message: error.toString(),
      ),
      data: (summary) {
        if (summary.isEmpty) {
          return const EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'Nothing billed yet',
            message: 'Your delivered tankers and what they came to will appear here.',
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(customerBillingProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              _ThisMonthCard(month: summary.months.first),
              const SizedBox(height: 20),
              const _Heading('EVERY MONTH'),
              for (final month in summary.months) _MonthTile(month: month),
              if (summary.truncated) ...[
                const SizedBox(height: 16),
                Text(
                  'Showing your most recent deliveries. Older ones are not counted in '
                  'these totals — ask the office for a full statement.',
                  style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: appTextColorSecondary,
        ),
      ),
    );
  }
}

/// The headline: what this month comes to, and what it is made of.
class _ThisMonthCard extends StatelessWidget {
  const _ThisMonthCard({required this.month});

  final BillingMonth month;

  static final _monthFormat = DateFormat('MMMM yyyy');

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [appBottomNavColor, Color(0xFF6A4A72)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _monthFormat.format(month.month).toUpperCase(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '₹ ${month.total.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _MiniStat(label: 'Deliveries', value: '${month.deliveries}'),
              const SizedBox(width: 24),
              _MiniStat(label: 'Tankers', value: '${month.tankers}'),
              const SizedBox(width: 24),
              _MiniStat(
                label: 'Days',
                value: '${month.days.length}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

/// One month, opening onto its days. Collapsed by default except the newest,
/// so a year of history is a short list rather than a scroll.
class _MonthTile extends StatelessWidget {
  const _MonthTile({required this.month});

  final BillingMonth month;

  static final _monthFormat = DateFormat('MMMM yyyy');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : appetitAppContainerColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Theme(
        // The divider an ExpansionTile draws in dark mode is all but black on
        // the card behind it, which reads as a rendering fault.
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          title: Text(
            _monthFormat.format(month.month),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            '${month.deliveries} deliver${month.deliveries == 1 ? 'y' : 'ies'} · '
            '${month.tankers} tanker${month.tankers == 1 ? '' : 's'}',
            style: const TextStyle(fontSize: 12, color: appTextColorSecondary),
          ),
          trailing: Text(
            '₹ ${month.total.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          children: [for (final day in month.days) _DayRow(day: day)],
        ),
      ),
    );
  }
}

/// One date: the loads, the rate they were charged at, and the amount.
class _DayRow extends StatelessWidget {
  const _DayRow({required this.day});

  final BillingDay day;

  static final _dayFormat = DateFormat('EEE, d MMM');

  @override
  Widget build(BuildContext context) {
    final rate = day.sharedRate;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_dayFormat.format(day.date), style: const TextStyle(fontSize: 13.5)),
                const SizedBox(height: 2),
                Text(
                  rate != null
                      // The whole arithmetic on one line, which is what makes
                      // the figure on the right checkable.
                      ? '${day.tankers} × ₹ ${rate.toStringAsFixed(0)}'
                      : '${day.tankers} tankers at mixed rates',
                  style: const TextStyle(fontSize: 11.5, color: appTextColorSecondary),
                ),
              ],
            ),
          ),
          Text(
            '₹ ${day.total.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
          ),
        ],
      ),
    );
  }
}
