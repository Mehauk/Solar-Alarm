import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solar_alarm/models/calendar.dart';

part 'alarm.freezed.dart';
part 'alarm.g.dart';

enum AlarmStatus {
  vibrate,
  sound,
  delayed;

  static List<AlarmStatus> get ordered => [vibrate, sound, delayed];

  IconData get icon {
    switch (this) {
      case vibrate:
        return Icons.vibration;
      case AlarmStatus.sound:
        return Icons.volume_up;
      case AlarmStatus.delayed:
        return Icons.timer_off_outlined;
    }
  }
}

@freezed
@JsonSerializable()
class Alarm with _$Alarm {
  @override
  final DateTime date;
  @override
  final String name;
  @override
  final bool enabled;
  @override
  final int timeInMillis;
  @override
  final int? repeatInterval;
  @override
  final Set<Weekday> repeatDays;
  @override
  final Set<AlarmStatus> statuses;

  Alarm({
    required this.name,
    required this.enabled,
    required this.timeInMillis,
    this.repeatInterval,
    this.repeatDays = const {},
    this.statuses = const {},
  }) : date = DateTime.fromMillisecondsSinceEpoch(timeInMillis),
       assert(
         (repeatDays.isNotEmpty ? 1 : 0) + (repeatInterval != null ? 1 : 0) <=
             1,
         'Only one of repeatDays, or repeatInterval can be provided.',
       );

  TimeOfDay get time => TimeOfDay.fromDateTime(date);
  bool get noRepeat => repeatDays.isEmpty && repeatInterval == null;

  factory Alarm.fromJson(Map<String, dynamic> json) => _$AlarmFromJson(json);
  Map<String, dynamic> get toJson => _$AlarmToJson(this);

  @override
  bool operator ==(Object other) {
    return other is Alarm && name == other.name;
  }

  @override
  int get hashCode => name.hashCode;
}
