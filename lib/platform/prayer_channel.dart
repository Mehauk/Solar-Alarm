import 'package:flutter/services.dart';
import 'package:solar_alarm/platform/_config.dart';
import 'package:solar_alarm/utils/error_handling.dart';

Future<Map?> getPrayerTimes(DateTime date) async {
  try {
    final prayers = await platform.invokeMethod('getPrayerTimes', {
      "date": date.millisecondsSinceEpoch,
    });

    return prayers as Map;
  } on PlatformException catch (e) {
    errors.add("Failed to get prayers: '${e.message}'.");
  }
  return null;
}
