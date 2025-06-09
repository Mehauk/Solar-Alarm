import 'package:flutter/material.dart';

import '../globals.dart';
import '../models/prayers.dart';
import '../ui/text.dart';
import '../utils/extensions.dart';
import 'prayer_icons.dart';

class PrayerTimingsWidget extends StatefulWidget {
  const PrayerTimingsWidget({super.key});

  @override
  State<PrayerTimingsWidget> createState() => _PrayerTimingsWidgetState();
}

class _PrayerTimingsWidgetState extends State<PrayerTimingsWidget> {
  Prayers? prayers;
  late final void Function(Prayers? data) _observer;

  @override
  void initState() {
    super.initState();

    prayers = prayerTimingsObserver.data;

    _observer = (prayerTimings) {
      setState(() => prayers = prayerTimings);
    };
    prayerTimingsObserver.addObserver(_observer);
  }

  @override
  void dispose() {
    prayerTimingsObserver.removeObserver(_observer);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < (prayers?.ordered.length ?? 0); i++)
          _PrayerTiming(prayers!.orderedPrayers[i], prayers!.ordered[i]),
      ],
    );
  }
}

class _PrayerTiming extends StatelessWidget {
  final Prayer prayer;
  final DateTime time;

  const _PrayerTiming(this.prayer, this.time);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 180,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrayerIcon(prayer, weight: PrayerIconWeight.thin, radius: 12),
              const SizedBox(width: 8),
              SText(prayer.name.capitalized, fontSize: 16),
              const Expanded(child: SizedBox()),
              SText(
                "${time.formattedTime.$1} ${time.formattedTime.$2}",
                fontSize: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
