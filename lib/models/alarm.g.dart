// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Alarm _$AlarmFromJson(Map<String, dynamic> json) => Alarm(
  name: json['name'] as String,
  timeInMillis: (json['timeInMillis'] as num).toInt(),
  repeatInterval: (json['repeatInterval'] as num).toInt(),
);

Map<String, dynamic> _$AlarmToJson(Alarm instance) => <String, dynamic>{
  'name': instance.name,
  'timeInMillis': instance.timeInMillis,
  'repeatInterval': instance.repeatInterval,
};
