import 'dart:math';

import 'package:flutter/material.dart';
import 'package:solar_alarm/platform/alarm_channel.dart';
import 'package:solar_alarm/platform/prayer_channel.dart';

final int rando = Random().nextInt(10000);

void sendAlarm() {
  final int rando = Random().nextInt(10000);
  scheduleAlarm(DateTime.now().add(Duration(seconds: 10)), "MYname $rando");
}

void main(List<String> args) {
  runApp(MaterialApp(home: _Home()));
}

class _Home extends StatefulWidget {
  const _Home();

  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  Map<dynamic, dynamic>? prayers;

  _getPrayerTimes() async {
    prayers = await getPrayerTimes(DateTime.now());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    prayers?.entries
                        .map(
                          (e) => Text(
                            "${e.key} : ${DateTime.fromMillisecondsSinceEpoch(e.value)}",
                          ),
                        )
                        .toList() ??
                    [],
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: sendAlarm,
                child: Text("SEND ALARM $rando"),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: _getPrayerTimes,
                child: Text("GET PRAYERS"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
