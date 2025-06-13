import 'package:flutter/material.dart';
import 'package:solar_alarm/models/prayers.dart';
import 'package:solar_alarm/platform/platform_channel.dart';

import 'components/alarms.dart';
import 'components/clock.dart';
import 'components/prayer_timings.dart';
import 'globals.dart';

void main(List<String> args) {
  runApp(
    MaterialApp(
      home: const _Home(),
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF646E82),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8E98A1),
          brightness: Brightness.dark,
        ),
      ),
    ),
  );
}

class _Home extends StatefulWidget {
  const _Home();

  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  @override
  void initState() {
    getPrayerTimes().then((value) {
      if (value != null) prayerTimingsObserver.update(PrayerTimings(value));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF363E46), Color(0xff2C343C)],
            // colors: [Color(0xFFEEF0F5), Color(0xffE2E4EA)],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 60),
            DigitalClock(),
            SizedBox(height: 8),
            PrayerTimingsWidget(),
            SizedBox(height: 16),
            Expanded(child: AlarmsWidget()),
          ],
        ),
      ),
    );
  }
}
