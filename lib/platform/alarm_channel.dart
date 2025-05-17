import 'package:flutter/services.dart';

const _platform = MethodChannel('com.example.solar_alarm/alarm');

void scheduleAlarm(DateTime time) async {
  try {
    await _platform.invokeMethod('setAlarm', {
      'year': time.year,
      'month': time.month,
      'day': time.day,
      'hour': time.hour,
      'minute': time.minute,
    });
  } on PlatformException catch (e) {
    print("Failed to set alarm: '${e.message}'.");
  }
}
