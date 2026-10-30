import '../../../shared/utils/json_read.dart';
import 'admin_report_result.dart';

/// One filling point's line of the **Filling Point Refill Report**.
///
/// Read by **position**, and refusing unless the headings match exactly —
/// the contract every report view in this app follows, for the reason
/// `DriverSalaryRow` spells out: a column inserted on the server would not
/// fail, it would quietly draw one amount under another's label.
class SpotRefillRow {
  const SpotRefillRow({
    required this.name,
    required this.address,
    required this.chargePerRefill,
    required this.refills,
    required this.refillCost,
    required this.tankers,
  });

  /// `SpotRefillReport::headings()`, in order.
  static const headings = <String>[
    'Filling Point',
    'Address',
    'Charge per Refill',
    'Refills',
    'Total Refill Cost',
    'Tankers Delivered',
  ];

  final String name;
  final String address;

  /// What this point charges for one fill. Zero means **not configured** —
  /// said in words, never drawn as "₹ 0", because a free filling point and an
  /// unpriced one are different facts and only one of them is likely.
  final double chargePerRefill;

  final int refills;
  final double refillCost;

  /// Tanker-**loads** delivered out of this point, never litres (CLAUDE.md).
  final int tankers;

  /// Every spot on the books appears in this report, used or not — the server
  /// queries spots and counts orders onto them, so a quiet point is a row
  /// with zeroes rather than a missing row.
  bool get used => refills > 0;

  bool get chargeIsSet => chargePerRefill > 0;

  /// Refills happened and yet nothing was charged for them: the point's
  /// charge was not set when the driver filled there, and the money is simply
  /// not recorded. Worth distinguishing from a point nobody used.
  bool get costMissing => used && refillCost <= 0;

  /// Null unless this result is the spot-refill report, drawn exactly as
  /// expected.
  static List<SpotRefillRow>? fromResult(AdminReportResult result) {
    if (result.key != 'spot-refill') return null;

    if (result.headings.length != headings.length) return null;

    for (var i = 0; i < headings.length; i++) {
      if (result.headings[i] != headings[i]) return null;
    }

    return result.rows.where((row) => row.length == headings.length).map(_fromRow).toList();
  }

  static SpotRefillRow _fromRow(List<dynamic> row) => SpotRefillRow(
        name: JsonRead.asString(row[0]),
        address: JsonRead.asString(row[1]),
        // Money arrives as `num` — an integral amount comes without its `.0`,
        // so `as double` would throw (CLAUDE.md rule 7).
        chargePerRefill: JsonRead.asDouble(row[2]),
        refills: JsonRead.asInt(row[3]),
        refillCost: JsonRead.asDouble(row[4]),
        tankers: JsonRead.asInt(row[5]),
      );
}
