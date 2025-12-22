import 'package:flutter/material.dart';
import 'package:solar_alarm/platform/platform_channel.dart';

import 'logs_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    PlatformChannel.getPrayerTimes().then((value) {
      prayerTimingsObservable.update(value);
    });

    PlatformChannel.getAllAlarms().then((value) {
      alarmsObservable.update(value);
    });

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      PlatformChannel.getAllAlarms().then((value) {
        alarmsObservable.update(value);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solar Alarm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () => Navigator.of(context).pushNamed('/logs'),
          ),
        ],
      ),
      body: const DecoratedBox(
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
