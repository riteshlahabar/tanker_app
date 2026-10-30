import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/features/admin/domain/admin_report_result.dart';
import 'package:tanker_app/features/admin/domain/daily_delivery_row.dart';

void main() {
  AdminReportResult result({
    String key = 'daily-delivery',
    List<String>? headings,
    List<List<dynamic>> rows = const [],
  }) =>
      AdminReportResult(
        key: key,
        title: 'Daily Delivery Summary',
        rangeLabel: '1–28 Oct',
        headings: headings ?? DailyDeliveryRow.headings,
        rows: rows,
        totals: const {'Revenue': '₹ 1,45,000.00'},
      );

  test('reads a day by column position', () {
    final rows = DailyDeliveryRow.fromResult(
      result(rows: [
        // Deliberately ints where money is: PHP sends an integral float
        // without its .0, and `as double` on that throws (CLAUDE.md rule 7).
        ['28 Oct 2026', 9, 7, 1, 14500, 2100, 11],
      ]),
    );

    final day = rows!.single;

    expect(day.dateLabel, '28 Oct 2026');
    expect(day.date?.month, 10);
    expect(day.orders, 9);
    expect(day.delivered, 7);
    expect(day.cancelled, 1);
    expect(day.revenue, 14500.0);
    expect(day.refillCost, 2100.0);
    expect(day.tankers, 11);
    expect(day.traded, isTrue);
    expect(day.revenueIsUnpriced, isFalse);
  });

  test('a day with deliveries but no revenue is unpriced, not free', () {
    // A tanker with no `tanker_rate` prices its orders at nothing, so this is
    // the case the card must write in words instead of a confident "₹ 0".
    final day = DailyDeliveryRow.fromResult(
      result(rows: [
        ['28 Oct 2026', 4, 4, 0, 0, 800, 6],
      ]),
    )!.single;

    expect(day.traded, isTrue);
    expect(day.revenueIsUnpriced, isTrue);
  });

  test('a day with no trade at all is not an unpriced day', () {
    final day = DailyDeliveryRow.fromResult(
      result(rows: [
        ['27 Oct 2026', 0, 0, 0, 0, 0, 0],
      ]),
    )!.single;

    expect(day.traded, isFalse);
    expect(day.revenueIsUnpriced, isFalse);
  });

  test('a changed report falls back to the generic table rather than relabelling money', () {
    // The whole reason this reads by position: a column inserted in the
    // middle would not fail, it would quietly draw the refill cost as
    // revenue. So anything but the exact headings has to refuse.
    expect(
      DailyDeliveryRow.fromResult(result(headings: const ['Date', 'Orders', 'Revenue'])),
      isNull,
    );

    expect(
      DailyDeliveryRow.fromResult(result(
        headings: const [
          'Date',
          'Orders',
          'Delivered',
          'Cancelled',
          'Refill Cost', // swapped with Revenue
          'Revenue',
          'Tankers',
        ],
      )),
      isNull,
    );
  });

  test('another report is never read as this one', () {
    expect(DailyDeliveryRow.fromResult(result(key: 'driver-salary')), isNull);
  });

  test('an unparseable date keeps its label and loses only the weekday', () {
    final day = DailyDeliveryRow.fromResult(
      result(rows: [
        ['Totally not a date', 1, 1, 0, 100, 0, 1],
      ]),
    )!.single;

    expect(day.dateLabel, 'Totally not a date');
    expect(day.date, isNull);
    expect(day.revenue, 100.0);
  });
}
