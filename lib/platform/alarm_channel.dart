import 'package:flutter/services.dart';
import 'package:solar_alarm/platform/_config.dart';
import 'package:solar_alarm/utils/error_handling.dart';

void scheduleAlarm(DateTime time, String alarmName) async {
  try {
    await platform.invokeMethod('setAlarm', {
      'time': time.millisecondsSinceEpoch,
      'name': alarmName,
    });
  } on PlatformException catch (e) {
    errors.add("Failed to set alarm: '${e.message}'.");
  }
}
