import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/features/admin/domain/admin_report_result.dart';
import 'package:tanker_app/features/admin/domain/spot_refill_row.dart';

void main() {
  AdminReportResult result({
    String key = 'spot-refill',
    List<String>? headings,
    List<List<dynamic>> rows = const [],
  }) =>
      AdminReportResult(
        key: key,
        title: 'Filling Point Refill Report',
        rangeLabel: '1–28 Oct',
        headings: headings ?? SpotRefillRow.headings,
        rows: rows,
        totals: const {'Total refill cost': '₹ 2,45,000.00'},
      );

  test('reads a filling point by column position', () {
    // Deliberately ints where money is: PHP sends an integral float without
    // its .0, and `as double` on that throws (CLAUDE.md rule 7).
    final point = SpotRefillRow.fromResult(
      result(rows: [
        ['Hingna Road Borewell', 'Plot 14, Hingna MIDC, Nagpur', 350, 42, 14700, 61],
      ]),
    )!.single;

    expect(point.name, 'Hingna Road Borewell');
    expect(point.address, 'Plot 14, Hingna MIDC, Nagpur');
    expect(point.chargePerRefill, 350.0);
    expect(point.refills, 42);
    expect(point.refillCost, 14700.0);
    expect(point.tankers, 61);
    expect(point.used, isTrue);
    expect(point.chargeIsSet, isTrue);
    expect(point.costMissing, isFalse);
  });

  test('a point nobody used is a row of zeroes, not a missing row', () {
    // The server queries spots and counts orders onto them, so every point on
    // the books appears. The card says "Not used" rather than drawing ₹ 0.
    final point = SpotRefillRow.fromResult(
      result(rows: [
        ['Quiet Point', 'Somewhere', 200, 0, 0, 0],
      ]),
    )!.single;

    expect(point.used, isFalse);
    expect(point.costMissing, isFalse);
    expect(point.chargeIsSet, isTrue);
  });

  test('refills with no cost recorded is told apart from a point nobody used', () {
    final point = SpotRefillRow.fromResult(
      result(rows: [
        ['Unconfigured Point', 'Somewhere', 0, 9, 0, 12],
      ]),
    )!.single;

    expect(point.used, isTrue);
    expect(point.costMissing, isTrue);
    // And its charge was never set, which is why nothing was recorded.
    expect(point.chargeIsSet, isFalse);
  });

  test('a changed report falls back to the generic table rather than relabelling money', () {
    // The reason this reads by position: swapping these two columns would not
    // fail, it would draw the per-refill charge as the range's whole cost.
    expect(
      SpotRefillRow.fromResult(result(
        headings: const [
          'Filling Point',
          'Address',
          'Total Refill Cost', // swapped with Charge per Refill
          'Refills',
          'Charge per Refill',
          'Tankers Delivered',
        ],
      )),
      isNull,
    );

    expect(SpotRefillRow.fromResult(result(headings: const ['Filling Point'])), isNull);
  });

  test('another report is never read as this one', () {
    expect(SpotRefillRow.fromResult(result(key: 'daily-delivery')), isNull);
  });
}
