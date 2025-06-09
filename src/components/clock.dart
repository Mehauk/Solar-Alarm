import 'dart:async';

import 'package:flutter/material.dart';

import '../ui/icon.dart';
import '../ui/text.dart';
import '../utils/date_utils.dart';

class Clock extends StatefulWidget {
  const Clock({super.key});

  @override
  State<Clock> createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  late DateTime _currentTime;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _startTimer();
  }

  void _startTimer() {
    final int secondsUntilNextMinute = 60 - _currentTime.second;
    _timer = Timer(Duration(seconds: secondsUntilNextMinute), () {
      setState(() => _currentTime = DateTime.now());
      _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
        setState(() => _currentTime = DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    (String time, String period) formattedTime = SDateUtils.formatTime(
      _currentTime,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SText.shadow(
          formattedTime.$1,
          fontSize: 84,
          height: 0.85,
          weight: STextWeight.medium,
        ),

        Positioned(
          bottom: -35,
          left: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SIcon(Icons.wb_sunny_outlined, radius: 16),
              SizedBox(width: 4),
              SText("Dhuhr", fontSize: 16, weight: STextWeight.bold),
            ],
          ),
        ),
        Positioned(
          bottom: -16,
          right: 0,
          child: SText(
            formattedTime.$2,
            fontSize: 16,
            weight: STextWeight.medium,
          ),
        ),
      ],
    );
  }
}
