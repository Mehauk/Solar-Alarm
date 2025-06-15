import 'package:flutter/material.dart';
import 'package:solar_alarm/models/prayers.dart';
import 'package:solar_alarm/platform/platform_channel.dart';

import '../globals.dart';
import '../ui/icon.dart';
import '../ui/switch.dart';
import '../ui/text.dart';
import '../utils/formatting_extensions.dart';
import 'prayer_icons.dart';

class PrayerTimingsWidget extends StatefulWidget {
  const PrayerTimingsWidget({super.key});

  @override
  State<PrayerTimingsWidget> createState() => _PrayerTimingsWidgetState();
}

class _PrayerTimingsWidgetState extends State<PrayerTimingsWidget> {
  Prayers? _prayers;
  Prayer? _currentPrayer;

  late final void Function(Prayers? data) _prayersObserver;
  late final void Function(Prayer? data) _currentPrayerObserver;

  void updatePrayerStatus(Prayer prayer, PrayerAlarmStatus s) {
    PlatformChannel.updatePrayerSetting(prayer, s);
    setState(() => _prayers!.statuses[prayer] = s);
  }

  @override
  void initState() {
    super.initState();

    _prayers = prayerTimingsObservable.data;

    _prayersObserver = (prayerTimings) {
      setState(() => _prayers = prayerTimings);
    };

    prayerTimingsObservable.addObserver(_prayersObserver);

    _currentPrayerObserver = (prayer) {
      setState(() => _currentPrayer = prayer);
    };
    currentPrayerObservable.addObserver(_currentPrayerObserver);
  }

  @override
  void dispose() {
    prayerTimingsObservable.removeObserver(_prayersObserver);
    currentPrayerObservable.removeObserver(_currentPrayerObserver);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < (_prayers?.ordered.length ?? 0); i++)
          _PrayerTiming(
            Prayers.orderedPrayers[i],
            _prayers!.ordered[i],
            _currentPrayer,
            _prayers!.statuses[Prayers.orderedPrayers[i]],
            (s) => updatePrayerStatus(Prayers.orderedPrayers[i], s),
          ),
      ],
    );
  }
}

class _PrayerTiming extends StatelessWidget {
  final Prayer prayer;
  final Prayer? currentPrayer;
  final DateTime time;
  final PrayerAlarmStatus? status;
  final void Function(PrayerAlarmStatus s)? onUpdateStatus;

  const _PrayerTiming(
    this.prayer,
    this.time,
    this.currentPrayer,
    this.status,
    this.onUpdateStatus,
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SText(
            "I",
            fontSize: 24,
            color:
                currentPrayer == prayer
                    ? const Color(0xFF8E98A1)
                    : Colors.transparent,
            glow: true,
          ),
          Expanded(
            child: Row(
              children: [
                PrayerIcon(prayer, weight: PrayerIconWeight.thin, radius: 12),
                const SizedBox(width: 8),
                SText(prayer.name.capitalized, fontSize: 16),
              ],
            ),
          ),

          SText(
            "${time.formattedTime.$1} ${time.formattedTime.$2.uname}",
            fontSize: 16,
          ),

          const SizedBox(width: 4),
          SizedBox(
            width: 52,
            child:
                status != null
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SSwitch(
                          status!,
                          onChanged: onUpdateStatus ?? (_) {},
                          trackSize: const Size(27, 7),
                          toggleSize: const Size(14, 14),
                        ),
                        const SizedBox(width: 4),
                        if (status!.icon != null)
                          SIcon(status!.icon!, radius: 7),
                      ],
                    )
                    : null,
          ),
        ],
      ),
    );
  }
}

extension on PrayerAlarmStatus {
  IconData? get icon => switch (this) {
    PrayerAlarmStatus.disabled => null,
    PrayerAlarmStatus.vibrate => Icons.vibration,
    PrayerAlarmStatus.sound => Icons.volume_up,
  };
}
