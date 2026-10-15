import '../../../shared/utils/json_read.dart';
import 'delivery_schedule.dart';
import 'upcoming_delivery_date.dart';

/// `GET /customer/schedule`'s response: null `schedule` is not an error — most
/// customers order ad-hoc and simply have no routine.
class MySchedule {
  const MySchedule({this.schedule, this.upcoming = const []});

  final DeliverySchedule? schedule;
  final List<UpcomingDeliveryDate> upcoming;

  factory MySchedule.fromJson(Map<String, dynamic> json) => MySchedule(
        schedule: json['schedule'] is Map<String, dynamic>
            ? DeliverySchedule.fromJson(json['schedule'] as Map<String, dynamic>)
            : null,
        upcoming:
            JsonRead.asMapList(json['upcoming']).map(UpcomingDeliveryDate.fromJson).toList(),
      );
}
