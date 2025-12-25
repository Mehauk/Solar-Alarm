import 'dart:convert';

import 'package:jni/jni.dart';
import 'package:solar_alarm/data/services/jni_bindings.g.dart' as bindings;
import 'package:solar_alarm/utils/result.dart';

import '../models/alarm.dart';

abstract interface class AlarmRepository {
  Result<void> setAlarm(Alarm alarm);
  Result<void> cancelAlarm(String alarmName);
  Result<List<Alarm>> getAlarms();
}

class JniAlarmRepository implements AlarmRepository {
  final bindings.Alarm _alarmService;
  JniAlarmRepository(JObject context) : _alarmService = bindings.Alarm(context);

  @override
  Result<void> setAlarm(Alarm alarm) => Result.attempt(() {
    _alarmService.setAlarm(
      alarm.toJson().toString().toJString(),
      true,
      false,
      false,
    );
  });

  @override
  Result<void> cancelAlarm(String name) => Result.attempt(() {
    _alarmService.cancelAlarm(name.toJString());
  });

  @override
  Result<List<Alarm>> getAlarms() => Result.attempt(() {
    return _alarmService.getAllAlarms().map((e) {
      final map = jsonDecode(e.toDartString()) as Map<String, dynamic>;

      map["statuses"] =
          (map["statuses"] as List).whereType<Map<String, dynamic>>().toList();

      return Alarm.fromJson(map);
    }).toList();
  });
}
