import 'dart:async';

import 'package:flutter/material.dart';
import 'package:solar_alarm/models/prayers.dart';

import '../globals.dart';
import '../ui/text.dart';
import '../utils/extensions.dart';
import 'prayer_icons.dart';

part 'digital_clock.dart';

enum TimePart { hour, minute }

enum DayPart { am, pm }

class Clock extends StatelessWidget {
  const Clock({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5D666D), Color(0xFF363E46)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFF2C343C),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            ),
          ),
        ),
      ),
    );
  }
}
