import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solar_alarm/models/calendar.dart';

part 'alarm.freezed.dart';
part 'alarm.g.dart';

enum AlarmStatus { vibrate, sound, delayed }

@freezed
abstract class Alarm with _$Alarm {
  @Assert(
    "(repeatDays != null ? 1 : 0) + (repeatInterval != null ? 1 : 0) <= 1",
    'Only one of repeatDays, or repeatInterval can be provided.',
  )
  const factory Alarm({
    required String name,
    required bool enabled,
    required int timeInMillis,
    int? repeatInterval,
    Set<Weekday>? repeatDays,
    @Default({}) Set<AlarmStatus> statuses,
  }) = _Alarm;

  factory Alarm.fromJson(Map<String, dynamic> json) => _$AlarmFromJson(json);
}
