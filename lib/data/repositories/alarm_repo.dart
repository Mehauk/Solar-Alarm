import 'dart:convert';

import 'package:solar_alarm/utils/result.dart';

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

  Future<Result<void>> setAlarm(Alarm alarm) async {
    final res = await Result.attemptAsync(() async {
      await _platformInvoker.invoke('setAlarm', alarm.toJson());
    });
    _logger.log('PlatformChannel - setAlarm $alarm');
    return res;
  }

  Future<Result<void>> cancelAlarm(String alarmName) async {
    final res = await Result.attemptAsync(() async {
      await _platformInvoker.invoke('cancelAlarm', {'name': alarmName});
    });
    _logger.log('PlatformChannel - cancelAlarm $alarmName');
    return res;
  }

  Future<Result<List<Alarm>>> getAlarms() async {
    return await Result.attemptAsync(() async {
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
    });
  }
}
