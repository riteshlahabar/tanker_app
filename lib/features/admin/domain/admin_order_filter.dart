import '../../../shared/models/order_status.dart';

/// What the admin's Orders list is currently filtered by. Immutable, so the
/// controller can diff "did anything actually change" before re-querying.
class AdminOrderFilter {
  const AdminOrderFilter({this.search, this.status, this.driverId, this.from, this.to});

  final String? search;
  final OrderStatus? status;
  final int? driverId;
  final DateTime? from;
  final DateTime? to;

  AdminOrderFilter copyWith({
    String? search,
    OrderStatus? status,
    int? driverId,
    DateTime? from,
    DateTime? to,
    bool clearStatus = false,
    bool clearDriver = false,
    bool clearDateRange = false,
  }) =>
      AdminOrderFilter(
        search: search ?? this.search,
        status: clearStatus ? null : (status ?? this.status),
        driverId: clearDriver ? null : (driverId ?? this.driverId),
        from: clearDateRange ? null : (from ?? this.from),
        to: clearDateRange ? null : (to ?? this.to),
      );
}
