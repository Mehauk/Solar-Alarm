import 'package:flutter/services.dart';

const mainChannel = MethodChannel('com.example.solar_alarm/main_channel');

void scheduleAlarm(DateTime time, String alarmName) async {
  try {
    await mainChannel.invokeMethod('setAlarm', {
      'time': time.millisecondsSinceEpoch,
      'name': alarmName,
    });
  } on PlatformException catch (e) {
    print("Failed to set alarm: '${e.message}'.");
  }
}

Future<Map?> getPrayerTimes() async {
  try {
    final prayers = await mainChannel.invokeMethod('getPrayerTimes');

    return prayers as Map;
  } on PlatformException catch (e) {
    print("Failed to get prayers: '${e.message}'.");
  }
  return null;
}
