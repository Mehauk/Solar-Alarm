import 'dart:async';

import 'package:flutter/material.dart';

import '../globals.dart';
import '../models/prayers.dart';
import '../ui/text.dart';
import '../utils/date_utils.dart';
import '../utils/extensions.dart';
import 'prayer_icons.dart';

class Clock extends StatefulWidget {
  const Clock({super.key});

  @override
  State<Clock> createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  late DateTime _currentTime;
  late Timer _timer;
  Prayer? _currentPrayer;

  late final void Function(Prayers? data) _observer;

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

  Prayer? _getCurrentPrayer(Prayers? timings) {
    if (timings == null) return null;

    // Compare the current time with prayer timings to determine the current prayer
    final now = _currentTime;
    Prayer? currentPrayer;

    for (var i = 0; i < timings.ordered.length; i++) {
      final prayer = timings.orderedPrayers[i];
      final time = timings.ordered[i];

      if (now.isBefore(time)) {
        break;
      }
      currentPrayer = prayer;
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
            top: -20,
            left: 0,
            child: SizedBox(
              height: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PrayerIcon(_currentPrayer!, radius: 16),
                  SizedBox(width: 4),
                  SText(
                    _currentPrayer!.name.capitalized,
                    fontSize: 16,
                    weight: STextWeight.bold,
                  ),
                ],
              ),
            ),
          ),
        Positioned(
          bottom: -20,
          right: 0,
          child: SText(
            formattedTime.$2,
            fontSize: 16,
            weight: STextWeight.medium,
            height: 1,
          ),
        ),
      ],
    );
  }
}
