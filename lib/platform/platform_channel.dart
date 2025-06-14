import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:solar_alarm/models/alarm.dart';

const mainChannel = MethodChannel('com.example.solar_alarm/main_channel');

abstract class PlatformChannel {
  // NEEDS WORK!!!!! undo comments
  static Future<void> setAlarm(Alarm alarm) async {
    print(alarm.toJson());
    try {
      // await mainChannel.invokeMethod('setAlarm', {
      //   'alarmJson': alarm.toJson().toString(),
      // });
    } on PlatformException catch (e) {
      print("Failed to set alarm: '${e.message}'.");
    }
  }

  // NEEDS WORK!!!!! undo comments
  static Future<void> cancelAlarm(String alarmName) async {
    try {
      // await mainChannel.invokeMethod('cancelAlarm', {'name': alarmName});
    } on PlatformException catch (e) {
      print("Failed to cancel alarm: '${e.message}'.");
    }
  }

  static Future<List<Alarm>> getAllAlarms() async {
    List<Alarm> alarms = [];
    try {
      final res0 = await mainChannel.invokeMethod('getAllAlarms');
      print(res0);
      final res = await mainChannel.invokeMethod<List<Object?>>('getAllAlarms');
      print(res);
      alarms =
          res
              ?.whereType<String>()
              .map((jsonString) => Alarm.fromJson(jsonDecode(jsonString)))
              .toList() ??
          [];
    } on PlatformException catch (e) {
      print("Failed to cancel alarm: '${e.message}'.");
    }

    return alarms;
  }

  static Future<Map?> getPrayerTimes() async {
    try {
      final prayers = await mainChannel.invokeMethod('getPrayerTimes');

      return prayers as Map;
    } on PlatformException catch (e) {
      print("Failed to get prayers: '${e.message}'.");
    }
    return null;
  }

  static Future<void> setPrayerTimes() async {
    try {
      await mainChannel.invokeMethod('setPrayerTimes');
    } on PlatformException catch (e) {
      print("Failed to set prayers: '${e.message}'.");
    }
  }
}
