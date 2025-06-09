import 'package:flutter/material.dart';
import 'package:solar_alarm/platform/platform_channel.dart';

import 'components/clock.dart';
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              Container(
                height: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: Clock()),
              ),
              Expanded(child: SingleChildScrollView()),
            ],
          ),
        ),
      ),
    );
  }
}
