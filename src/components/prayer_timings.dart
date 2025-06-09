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
    return SizedBox(
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 24,
            child: Stack(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < (prayers?.ordered.length ?? 0); i++)
                      PrayerIcon(prayers!.orderedPrayers[i], radius: 24),
                  ],
                ),
                Center(
                  child: Divider(color: const Color.fromARGB(57, 255, 193, 7)),
                ),
              ],
            ),
          ),
          for (var i = 0; i < (prayers?.ordered.length ?? 0); i++)
            _PrayerTiming(prayers!.orderedPrayers[i], prayers!.ordered[i]),
        ],
      ),
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
        PrayerIcon(prayer),
        SizedBox(width: 12),
        SText(
          "${prayer.name.capitalized} ${time.formattedTime.$1} ${time.formattedTime.$2}",
        ),
      ],
    );
  }
}
