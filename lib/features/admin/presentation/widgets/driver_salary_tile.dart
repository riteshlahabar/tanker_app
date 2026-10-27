import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/colors.dart';
import '../../domain/driver_salary_row.dart';
import 'admin_pill.dart';

/// One driver's line of the Driver Deliveries & Salary report, as a card
/// rather than a row of a nine-column table.
///
/// A `DataTable` of nine columns on a phone is a sideways scroll where the
/// driver's name leaves the screen before the money arrives, so no figure can
/// be read against the person who earned it. The card keeps the master-data
/// anatomy the rest of the app uses — cream 15px, 4px spine, bold lead line —
/// and puts **the work first and the money under it**, which is the order the
/// report is read in.
///
/// Two conventions it inherits rather than invents:
///
/// * a driver with **no salary set** gets the amber "Salary not set" pill, the
///   same as the Drivers list — every driver is on zero until the owner sets
///   the real figures (CLAUDE.md, Blocked on the owner), and a confident
///   "₹ 0 / mo" would read as a decision rather than an omission;
/// * the salary sits on its own footer line, never beside the range's money,
///   because the two must not be added together.
class DriverSalaryTile extends StatelessWidget {
  const DriverSalaryTile({super.key, required this.row});

  final DriverSalaryRow row;

  /// Indian grouping — an order value runs to six or seven figures, and
  /// 12,45,000 reads at a glance where 1245000 does not.
  static final _money = NumberFormat.decimalPattern('en_IN');

  @override
  Widget build(BuildContext context) {
    // Green where work was done, grey where none was: a driver with nothing
    // in the range is a fact to notice, not an error to flag in amber.
    final accent = row.workedInRange ? statusDeliveredColor : iconColorSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Material(
        color: appetitAppContainerColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(15),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: accent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _titleRow(),
                      const SizedBox(height: 6),
                      _detailRow(),
                      const SizedBox(height: 12),
                      _workRow(accent),
                      const SizedBox(height: 10),
                      _moneyRow(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _titleRow() {
    return Row(
      children: [
        const Icon(Icons.person_outline, size: 17, color: appTextColorPrimary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            row.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
        if (row.tanker != null) ...[
          const SizedBox(width: 8),
          AdminPill(label: row.tanker!, color: appColorPrimary),
        ],
      ],
    );
  }

  Widget _detailRow() => Text(
        row.mobile,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: appTextColorSecondary, fontSize: 13),
      );

  /// The two figures the report is about, given the room a table never gave
  /// them. Side by side because one is the count of jobs and the other the
  /// volume carried — read together, they say whether the trips were full.
  Widget _workRow(Color accent) {
    return Row(
      children: [
        Expanded(child: _figure('${row.delivered}', 'Deliveries', accent)),
        Container(width: 1, height: 34, color: Colors.black12),
        Expanded(child: _figure('${row.loads}', 'Tanker-loads', appetitBrownColor)),
      ],
    );
  }

  Widget _figure(String value, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Scaled down rather than wrapped: the cell is a fixed height and a
        // four-digit count must shrink, not spill onto a second line.
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: color, height: 1.1),
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11.5, color: appTextColorSecondary),
        ),
      ],
    );
  }

  /// A `Wrap`, not a `Row`: three labelled amounts plus the salary pill do not
  /// fit a 320dp phone on one line once the figures are real.
  Widget _moneyRow() {
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _amount('Order value', row.orderValue),
        _amount('Refill cost', row.refillCost),
        _amount('Expenses', row.expenses),
        if (row.hasSalary)
          Text(
            '₹ ${_money.format(row.monthlySalary.round())} / mo',
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
          )
        else
          const AdminPill(label: 'Salary not set', color: statusPendingColor),
      ],
    );
  }

  Widget _amount(String label, double value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 12.5, color: appTextColorSecondary),
        children: [
          TextSpan(text: '$label '),
          TextSpan(
            text: '₹ ${_money.format(value.round())}',
            style: const TextStyle(fontWeight: FontWeight.w700, color: appTextColorPrimary),
          ),
        ],
      ),
    );
  }
}
