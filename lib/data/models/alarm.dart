import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/calendar.dart';

part 'alarm.freezed.dart';
part 'alarm.g.dart';

@freezed
sealed class AlarmStatus with _$AlarmStatus {
  const AlarmStatus._();

  const factory AlarmStatus.vibrate() = VibrateStatus;
  const factory AlarmStatus.sound() = SoundStatus;
  const factory AlarmStatus.delayed(int delayedUntil) = DelayedStatus;

  factory AlarmStatus.fromJson(Map<String, dynamic> json) =>
      _$AlarmStatusFromJson(json);

  IconData get icon => switch (this) {
    VibrateStatus() => Icons.vibration,
    SoundStatus() => Icons.volume_up,
    DelayedStatus() => Icons.timer_off_outlined,
  };

  static const List<AlarmStatus> ordered = [
    AlarmStatus.vibrate(),
    AlarmStatus.sound(),
    AlarmStatus.delayed(0),
  ];

  @override
  bool operator ==(Object other) {
    return other is AlarmStatus && runtimeType == other.runtimeType;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

extension DelayedStatusDateTime on DelayedStatus {
  DateTime get date => DateTime.fromMillisecondsSinceEpoch(delayedUntil);
}

@freezed
abstract class Alarm with _$Alarm {
  const Alarm._();

  const factory Alarm({
    required String name,
    required bool enabled,
    required int timeInMillis,
    int? repeatInterval,
    @Default({}) Set<Weekday> repeatDays,
    @AlarmStatusSetConverter() @Default({}) Set<AlarmStatus> statuses,
  }) = _Alarm;

  DateTime get date => DateTime.fromMillisecondsSinceEpoch(timeInMillis);
  TimeOfDay get time => TimeOfDay.fromDateTime(date);

  factory Alarm.fromJson(Map<String, dynamic> json) => _$AlarmFromJson(json);

  @override
  bool operator ==(Object other) {
    return other is Alarm && name == other.name;
  }

  @override
  int get hashCode => name.hashCode;
}

class AlarmStatusSetConverter
    implements JsonConverter<Set<AlarmStatus>, List<Map<String, dynamic>>> {
  const AlarmStatusSetConverter();

  @override
  Set<AlarmStatus> fromJson(List<Map<String, dynamic>> json) =>
      json.map(AlarmStatus.fromJson).toSet();

  @override
  List<Map<String, dynamic>> toJson(Set<AlarmStatus> object) =>
      object.map((s) => s.toJson()).toList();
}
