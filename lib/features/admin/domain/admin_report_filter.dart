/// The filter set `ReportFilters::fromRequest()` reads — date range always,
/// plus whichever single entity id the report's own `filterFields()` asked
/// for.
class AdminReportFilter {
  const AdminReportFilter({
    this.from,
    this.to,
    this.driverId,
    this.customerId,
    this.spotId,
    this.tankerId,
    this.search,
  });

  final DateTime? from;
  final DateTime? to;
  final int? driverId;
  final int? customerId;
  final int? spotId;
  final int? tankerId;
  final String? search;

  AdminReportFilter copyWith({
    DateTime? from,
    DateTime? to,
    int? driverId,
    int? customerId,
    int? spotId,
    int? tankerId,
    String? search,
  }) =>
      AdminReportFilter(
        from: from ?? this.from,
        to: to ?? this.to,
        driverId: driverId ?? this.driverId,
        customerId: customerId ?? this.customerId,
        spotId: spotId ?? this.spotId,
        tankerId: tankerId ?? this.tankerId,
        search: search ?? this.search,
      );
}
