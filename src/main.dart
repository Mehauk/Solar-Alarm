import 'package:flutter/material.dart';
import 'package:solar_alarm/platform/platform_channel.dart';

import 'components/clock.dart';
import 'components/prayer_timings.dart';
import 'globals.dart';
import 'models/prayers.dart';

void main(List<String> args) {
  runApp(
    MaterialApp(
      home: const _Home(),
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF646E82),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF8E98A1),
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
      if (value != null) prayerTimingsObserver.modify(Prayers(value));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Clock(),
            SizedBox(height: 8),
            PrayerTimingsWidget(),
            SizedBox(height: 16),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF5D666D), Color(0x0023282D)],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 1.5),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF363E46), Color(0xFF2C343C)],
                      ),
                    ),
                    child: SizedBox(height: 300, width: double.maxFinite),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
