/// The admin schedule list's own filters — `customer_id`/`status`/`paused`/
/// `search`, exactly what `ScheduleApiListController` reads.
class AdminScheduleFilter {
  const AdminScheduleFilter({this.customerId, this.status, this.paused, this.search});

  final int? customerId;
  final bool? status;
  final bool? paused;
  final String? search;

  AdminScheduleFilter copyWith({
    int? customerId,
    bool? status,
    bool? paused,
    String? search,
    bool clearStatus = false,
    bool clearPaused = false,
  }) =>
      AdminScheduleFilter(
        customerId: customerId ?? this.customerId,
        status: clearStatus ? null : (status ?? this.status),
        paused: clearPaused ? null : (paused ?? this.paused),
        search: search ?? this.search,
      );
}
