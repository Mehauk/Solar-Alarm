import 'package:json_annotation/json_annotation.dart';
import 'package:solar_alarm/models/calendar.dart';

part 'alarm.g.dart';

enum AlarmStatus { mute, sound, delayed }

@JsonSerializable()
class Alarm {
  final String name;
  final bool enabled;
  final int timeInMillis;
  final int? repeatInterval;
  final Set<Weekday>? repeatDays;
  final List<AlarmStatus> statuses;

  final DateTime alarmDate;

  Alarm({
    required this.name,
    required this.enabled,
    required this.timeInMillis,
    required this.repeatInterval,
    this.repeatDays,
    this.statuses = const [],
  }) : assert(
         (repeatDays != null ? 1 : 0) + (repeatInterval != null ? 1 : 0) <= 1,
         'Only one of repeatDays, or repeatInterval can be provided.',
       ),
       alarmDate = DateTime.fromMillisecondsSinceEpoch(timeInMillis);

  factory Alarm.fromJson(Map<String, dynamic> json) => _$AlarmFromJson(json);
  Map<String, dynamic> get toJson => _$AlarmToJson(this);
}
