import 'package:flutter/material.dart';
import 'package:solar_alarm/platform/platform_channel.dart';

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
  int seconds = 5;

  void sendAlarm() {
    scheduleAlarm(
      DateTime.now().add(Duration(seconds: seconds)),
      "ALARM!",
      Duration(seconds: seconds),
    );
  }

  void sendCancelAlarm() {
    cancelAlarm("ALARM!");
  }

  sendgetPrayerTimes() async {
    prayers = await getPrayerTimes();
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
                child: Text("SEND ALARM"),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: sendCancelAlarm,
                child: Text("CANCEL ALARM"),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: sendgetPrayerTimes,
                child: Text("GET PRAYERS"),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: setPrayerTimes,
                child: Text("SET PRAYERS"),
              ),
            ),
            Expanded(
              child: TextField(
                decoration: InputDecoration(labelText: "Seconds"),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: seconds.toString()),
                onChanged: (value) {
                  setState(() {
                    seconds = int.tryParse(value) ?? seconds;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
