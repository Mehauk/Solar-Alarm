import 'package:flutter/services.dart';
import 'package:solar_alarm/models/alarm.dart';

const mainChannel = MethodChannel('com.example.solar_alarm/main_channel');

Future<void> scheduleAlarm(Alarm alarm) async {
  try {
    await mainChannel.invokeMethod('setAlarm', {
      'alarmJson': alarm.toJson.toString(),
    });
  } on PlatformException catch (e) {
    print("Failed to set alarm: '${e.message}'.");
  }
}

Future<void> cancelAlarm(String alarmName) async {
  try {
    await mainChannel.invokeMethod('cancelAlarm', {'name': alarmName});
  } on PlatformException catch (e) {
    print("Failed to cancel alarm: '${e.message}'.");
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

Future<void> setPrayerTimes() async {
  try {
    await mainChannel.invokeMethod('setPrayerTimes');
  } on PlatformException catch (e) {
    print("Failed to set prayers: '${e.message}'.");
  }
}
