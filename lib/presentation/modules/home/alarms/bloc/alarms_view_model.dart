import 'package:flutter/material.dart';
import 'package:solar_alarm/data/models/alarm.dart';

class AlarmsViewModel {
  final Map<Alarm, GlobalKey> alarmKeys;
  final List<Alarm> alarms;

  AlarmsViewModel(this.alarms)
    : alarmKeys = Map.fromIterable(alarms, value: (_) => GlobalKey());
}
