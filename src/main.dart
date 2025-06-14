import 'package:flutter/material.dart';
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

class _HomeState extends State<_Home> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    PlatformChannel.getPrayerTimes().then((value) {
      prayerTimingsObserver.update(value);
    });

    PlatformChannel.getAllAlarms().then((value) {
      alarmsObserver.update(value);
    });

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      PlatformChannel.getAllAlarms().then((value) {
        alarmsObserver.update(value);
      });
    }

    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
