import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:solar_alarm/models/alarm.dart';
import 'package:solar_alarm/models/prayers.dart';

const mainChannel = MethodChannel('com.example.solar_alarm/main_channel');

abstract class PlatformChannel {
  static Future<void> setAlarm(Alarm alarm) async {
    try {
      await mainChannel.invokeMethod('setAlarm', {
        'alarmJson': alarm.toJson().toString(),
      });
    } on PlatformException catch (_) {}
  }

  static Future<void> cancelAlarm(String alarmName) async {
    try {
      await mainChannel.invokeMethod('cancelAlarm', {'name': alarmName});
    } on PlatformException catch (_) {}
  }

  static Future<List<Alarm>> getAllAlarms() async {
    List<Alarm> alarms = [];
    try {
      final res = await mainChannel.invokeMethod<List<Object?>>('getAllAlarms');
      print(res);
      alarms =
          res?.whereType<String>().map((jsonString) {
            dynamic json = jsonDecode(jsonString);
            json["statuses"] =
                json["statuses"].whereType<Map<String, dynamic>>().toList();
            return Alarm.fromJson(json);
          }).toList() ??
          [];
    } on PlatformException catch (_) {}

    return alarms;
  }

  static Future<Prayers?> getPrayerTimes() async {
    try {
      final prayers = await mainChannel.invokeMethod('getPrayerTimes');

      return Prayers(prayers as Map);
    } on PlatformException catch (_) {}
    return null;
  }

  static Future<void> setPrayeralarms() async {
    try {
      await mainChannel.invokeMethod('setPrayerAlarms');
    } on PlatformException catch (e) {
      print("Failed to set prayers: '${e.message}'.");
    }
  }
}
