import 'dart:convert';

import '../models/alarm.dart';
import '../services/log_service.dart';
import '../services/platform_service.dart';

class AlarmRepository {
  final Invoker _platformInvoker;
  final Logger _logger;

  const AlarmRepository({
    required Invoker platformInvoker,
    required Logger logger,
  }) : _platformInvoker = platformInvoker,
       _logger = logger;

  Future<void> setAlarm(Alarm alarm) async {
    _logger.log('PlatformChannel - setAlarm $alarm');
    await _platformInvoker.invoke('setAlarm', alarm.toJson());
  }

  Future<void> cancelAlarm(String alarmName) async {
    _logger.log('PlatformChannel - cancelAlarm $alarmName');
    await _platformInvoker.invoke('cancelAlarm', {'name': alarmName});
  }

  Future<List<Alarm>> getAlarms() async {
    final res = await _platformInvoker.invoke<List<Object?>>('getAllAlarms');
    List<Alarm> alarms = [];
    alarms =
        res?.whereType<String>().map((jsonString) {
          dynamic json = jsonDecode(jsonString);
          json["statuses"] =
              json["statuses"].whereType<Map<String, dynamic>>().toList();
          return Alarm.fromJson(json);
        }).toList() ??
        [];
    _logger.log('PlatformChannel - getAlarms ${alarms.length}');
    return alarms;
  }
}
