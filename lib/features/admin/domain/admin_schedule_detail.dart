import '../../../shared/models/upcoming_delivery_date.dart';
import '../../../shared/utils/json_read.dart';
import 'admin_schedule.dart';

/// `GET /api/admin/schedules/{id}`'s response — the schedule plus its own
/// upcoming-dates list, the same pairing the customer's `MySchedule` reads.
class AdminScheduleDetail {
  const AdminScheduleDetail({required this.schedule, this.upcoming = const []});

  final AdminSchedule schedule;
  final List<UpcomingDeliveryDate> upcoming;

  factory AdminScheduleDetail.fromJson(Map<String, dynamic> json) => AdminScheduleDetail(
        schedule: AdminSchedule.fromJson(JsonRead.asMap(json['schedule'])),
        upcoming:
            JsonRead.asMapList(json['upcoming']).map(UpcomingDeliveryDate.fromJson).toList(),
      );
}
