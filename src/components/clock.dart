import 'dart:async';

import 'package:flutter/material.dart';

import '../globals.dart';
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
  String? _currentPrayer;

  late final void Function(Map<dynamic, dynamic>? data) _observer;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _startTimer();

    _currentPrayer = _getCurrentPrayer(prayerTimingsObserver.data);

    _observer = (prayerTimings) {
      setState(() {
        _currentPrayer = _getCurrentPrayer(prayerTimings);
      });
    };
    prayerTimingsObserver.addObserver(_observer);
  }

  String? _getCurrentPrayer(Map<dynamic, dynamic>? prayerTimings) {
    if (prayerTimings == null) return null;

    // Compare the current time with prayer timings to determine the current prayer
    final now = _currentTime;
    String? currentPrayer;

    for (var entry in prayerTimings.entries) {
      final prayerName = entry.key;
      final prayerTime = DateTime.fromMillisecondsSinceEpoch(entry.value);

      if (now.isBefore(prayerTime)) {
        break;
      }
      currentPrayer = prayerName;
    }

    return currentPrayer;
  }

  void _startTimer() {
    final int secondsUntilNextMinute = 60 - _currentTime.second;
    _timer = Timer(Duration(seconds: secondsUntilNextMinute), () {
      setState(() => _currentTime = DateTime.now());
      _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
        setState(() {
          _currentTime = DateTime.now();
          _currentPrayer = _getCurrentPrayer(prayerTimingsObserver.data);
        });
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    prayerTimingsObserver.removeObserver(_observer);
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

        if (_currentPrayer != null)
          Positioned(
            bottom: -35,
            left: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SIcon(Icons.wb_sunny_outlined, radius: 16),
                SizedBox(width: 4),
                SText(_currentPrayer!, fontSize: 16, weight: STextWeight.bold),
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
