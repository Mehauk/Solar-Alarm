import 'package:flutter/services.dart';

const _platform = MethodChannel('com.example.solar_alarm/alarm');

void scheduleAlarm(DateTime time, String alarmName) async {
  print(time.millisecondsSinceEpoch);
  try {
    await _platform.invokeMethod('setAlarm', {
      'time': time.millisecondsSinceEpoch,
      'name': alarmName,
    });
  } on PlatformException catch (e) {
    print("Failed to set alarm: '${e.message}'.");
  }
}
