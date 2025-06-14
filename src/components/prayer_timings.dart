import 'package:flutter/material.dart';
import 'package:solar_alarm/models/prayers.dart';

import '../globals.dart';
import '../ui/text.dart';
import '../utils/formatting_extensions.dart';
import 'prayer_icons.dart';

class PrayerTimingsWidget extends StatefulWidget {
  const PrayerTimingsWidget({super.key});

  @override
  State<PrayerTimingsWidget> createState() => _PrayerTimingsWidgetState();
}

class _PrayerTimingsWidgetState extends State<PrayerTimingsWidget> {
  PrayerTimings? _prayers;
  Prayer? _currentPrayer;
  late final void Function(PrayerTimings? data) _prayersObserver;
  late final void Function(Prayer? data) _currentPrayerObserver;

  @override
  void initState() {
    super.initState();

    _prayers = prayerTimingsObserver.data;

    _prayersObserver = (prayerTimings) {
      setState(() => _prayers = prayerTimings);
    };

    prayerTimingsObserver.addObserver(_prayersObserver);

    _currentPrayerObserver = (prayer) {
      setState(() => _currentPrayer = prayer);
    };
    currentPrayerObserver.addObserver(_currentPrayerObserver);
  }

  @override
  void dispose() {
    prayerTimingsObserver.removeObserver(_prayersObserver);
    currentPrayerObserver.removeObserver(_currentPrayerObserver);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < (_prayers?.ordered.length ?? 0); i++)
          _PrayerTiming(
            _prayers!.orderedPrayers[i],
            _prayers!.ordered[i],
            _currentPrayer,
          ),
      ],
    );
  }
}

class _PrayerTiming extends StatelessWidget {
  final Prayer prayer;
  final Prayer? currentPrayer;
  final DateTime time;

  const _PrayerTiming(this.prayer, this.time, this.currentPrayer);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 220,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrayerIcon(prayer, weight: PrayerIconWeight.thin, radius: 12),
              const SizedBox(width: 8),
              SText(prayer.name.capitalized, fontSize: 16),
              const Expanded(child: SizedBox()),
              SText(
                "${time.formattedTime.$1} ${time.formattedTime.$2.uname}",
                fontSize: 16,
              ),
              SText(
                "I",
                fontSize: 24,
                color:
                    currentPrayer == prayer
                        ? const Color(0xFF8E98A1)
                        : Colors.transparent,
                glow: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
