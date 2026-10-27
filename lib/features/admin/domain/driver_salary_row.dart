import '../../../shared/utils/json_read.dart';
import 'admin_report_result.dart';

/// One driver's line of the **Driver Deliveries & Salary** report.
///
/// Every report answers in the same `headings` + `rows` shape — a row is a
/// `List`, not an object — so a screen that draws named fields has to read by
/// position. That is exactly the contract `DailyReportMessage` reads on the
/// server, and it carries the same risk: a column inserted in the middle
/// would not fail, it would quietly relabel money.
///
/// So [fromResult] refuses unless the headings are **exactly** the nine this
/// was written against. A changed report falls back to the generic table,
/// which is always right because it draws whatever it is given.
class DriverSalaryRow {
  const DriverSalaryRow({
    required this.name,
    required this.mobile,
    required this.tanker,
    required this.delivered,
    required this.loads,
    required this.orderValue,
    required this.refillCost,
    required this.monthlySalary,
    required this.expenses,
  });

  /// `DriverSalaryReport::headings()`, in order. Appended to on the server,
  /// never inserted into — the same rule the nightly WhatsApp depends on.
  static const headings = <String>[
    'Driver',
    'Mobile',
    'Tanker',
    'Delivered',
    'Tankers',
    'Order Value',
    'Refill Cost',
    'Monthly Salary',
    'Expenses',
  ];

  final String name;
  final String mobile;

  /// The vehicle number of the driver's current tanker, or null where the
  /// report sent its em dash for "none".
  final String? tanker;

  final int delivered;
  final int loads;
  final double orderValue;
  final double refillCost;

  /// A standing monthly figure, **never** prorated across the report's range
  /// and never added to [expenses] — see CLAUDE.md. Zero means not set yet,
  /// which the card says in words rather than drawing ₹ 0.
  final double monthlySalary;

  /// What this driver spent over the range. Range-bound, unlike the salary.
  final double expenses;

  bool get hasSalary => monthlySalary > 0;

  bool get workedInRange => delivered > 0;

  /// Null unless this result is the driver-salary report, drawn exactly as
  /// expected.
  static List<DriverSalaryRow>? fromResult(AdminReportResult result) {
    if (result.key != 'driver-salary') return null;

    const expected = headings;

    if (result.headings.length != expected.length) return null;

    for (var i = 0; i < expected.length; i++) {
      if (result.headings[i] != expected[i]) return null;
    }

    return result.rows.where((row) => row.length == expected.length).map(_fromRow).toList();
  }

  static DriverSalaryRow _fromRow(List<dynamic> row) {
    final tanker = JsonRead.asString(row[2]).trim();

    return DriverSalaryRow(
      name: JsonRead.asString(row[0]),
      mobile: JsonRead.asString(row[1]),
      // The report writes an em dash where there is no current assignment.
      tanker: tanker.isEmpty || tanker == '—' ? null : tanker,
      delivered: JsonRead.asInt(row[3]),
      loads: JsonRead.asInt(row[4]),
      // Money arrives as `num` — an integral amount comes without its `.0`,
      // so `as double` would throw (CLAUDE.md rule 7).
      orderValue: JsonRead.asDouble(row[5]),
      refillCost: JsonRead.asDouble(row[6]),
      monthlySalary: JsonRead.asDouble(row[7]),
      expenses: JsonRead.asDouble(row[8]),
    );
  }
}
