import 'package:flutter/material.dart';
import 'package:solar_alarm/platform/alarm_channel.dart';
import 'package:solar_alarm/solar.dart';

void sendZenith() {
  // Coordinates for Edmonton, Alberta, Canada
  final latitude = 53.5461; // Edmonton latitude
  final longitude = -113.4938; // Edmonton longitude

  // Current UTC time (You can replace this with any specific UTC date if needed)
  final now = DateTime.now().toUtc(); // Get the current UTC time

  // Calculate solar noon for Edmonton
  final solarNoon = calculateSolarNoon(latitude, longitude, now).toLocal();
  final temp = solarNoon.add(Duration(minutes: 60));
  print(temp);
  if (!temp.isAfter(DateTime.now())) {
    print("CANECLED");
    return;
  }

  scheduleAlarm(temp);
}

void sendAlarm() {
  scheduleAlarm(DateTime.now().add(Duration(seconds: 10)));
  print("SENT");
}

void main(List<String> args) {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: TextButton(onPressed: sendAlarm, child: Text("SEND ALARM")),
        ),
      ),
    ),
  );
}
