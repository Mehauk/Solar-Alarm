import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:solar_alarm/models/alarm.dart';
import 'package:solar_alarm/models/prayers.dart';

const mainChannel = MethodChannel('com.example.solar_alarm/main_channel');

abstract class PlatformChannel {
  static Future<void> setAlarm(Alarm alarm) async {
    print("BOGOGOSO $alarm");
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
      alarms =
          res?.whereType<String>().map((jsonString) {
            dynamic json = jsonDecode(jsonString);
            json["statuses"] =
                json["statuses"].whereType<Map<String, dynamic>>().toList();
            return Alarm.fromJson(json);
          }).toList() ??
          [];
    } on PlatformException catch (_) {}

    print("BOGOGOSO$alarms");
    return alarms;
  }

  static Future<Prayers?> getPrayerTimes() async {
    try {
      final prayers = await mainChannel.invokeMethod('getPrayerTimes');

      return Prayers(prayers as Map);
    } on PlatformException catch (_) {}
    return null;
  }

  static Future<void> updatePrayerSetting(
    Prayer prayer,
    PrayerAlarmStatus status,
  ) async {
    try {
      await mainChannel.invokeMethod('updatePrayerSetting', {
        'name': prayer.capitalizedName,
        'status': status.name,
      });
    } on PlatformException catch (_) {}
  }
}
