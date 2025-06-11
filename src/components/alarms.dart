import 'package:flutter/material.dart';
import 'package:solar_alarm/models/alarm.dart';
import 'package:solar_alarm/models/calendar.dart';

import '../ui/icon.dart';
import '../ui/switch.dart';
import '../ui/text.dart';
import '../utils/extensions.dart';
import 'alarm_edit.dart';
import 'background.dart';

class AlarmsWidget extends StatefulWidget {
  const AlarmsWidget({super.key});

  @override
  State<AlarmsWidget> createState() => _AlarmsWidgetState();
}

class _AlarmsWidgetState extends State<AlarmsWidget> {
  List<Alarm> alarms = [
    Alarm(
      name: "MyNameMyNameMyName",
      timeInMillis:
          DateTime.now().add(const Duration(hours: 2)).millisecondsSinceEpoch,
      // repeatInterval: 1000 * 60 * 60,
      repeatDays: {Weekday.friday},
      statuses: {AlarmStatus.sound, AlarmStatus.vibrate},
      enabled: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Background(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 36),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SText("Alarms", fontSize: 18),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SIconButton(
                      Icons.add,
                      onTap:
                          () => showBottomSheet(
                            context: context,
                            builder: (context) => const AlarmEdit(),
                          ),
                    ),
                    const SizedBox(width: 4),
                    SIconButton(Icons.more_horiz, onTap: () => print(1)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children:
                      alarms
                          .asMap()
                          .entries
                          .map(
                            (e) => AlarmTile(
                              e.value,
                              onTap: () {},
                              onToggle: (b) {
                                setState(() {
                                  alarms[e.key] = alarms[e.key].copyWith(
                                    enabled: b,
                                  );
                                });
                              },
                            ),
                          )
                          .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AlarmTile extends StatelessWidget {
  final Alarm alarm;
  final void Function() onTap;
  final void Function(bool value) onToggle;

  const AlarmTile(
    this.alarm, {
    super.key,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Durations.short2,
      opacity: alarm.enabled ? 1 : 0.9,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Material(
          elevation: 10,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
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
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3F4850), Color(0xFF363E46)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 14,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SText(alarm.date.formattedTime.$1, fontSize: 34),
                          const SizedBox(width: 4),
                          Column(
                            children: [
                              SText(
                                "AM",
                                fontSize: 16,
                                weight: STextWeight.thin,
                                color:
                                    alarm.date.formattedTime.$2 == "AM"
                                        ? const Color(0xFFFD251E)
                                        : const Color(0xFF8E98A1),
                                glow: alarm.date.formattedTime.$2 == "AM",
                              ),
                              SText(
                                "PM",
                                fontSize: 16,
                                weight: STextWeight.thin,
                                color:
                                    alarm.date.formattedTime.$2 == "PM"
                                        ? const Color(0xFFFD251E)
                                        : const Color(0xFF8E98A1),
                                glow: alarm.date.formattedTime.$2 == "PM",
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (alarm.repeatDays != null)
                            RepeatingDaysIndicator(alarm.repeatDays!),

                          if (alarm.repeatInterval != null)
                            RepeatingIntervalIndicator(alarm.repeatInterval!),

                          if (alarm.noRepeat)
                            SText(
                              alarm.date.formattedDate,
                              fontSize: 12,
                              weight: STextWeight.normal,
                            ),
                        ],
                      ),
                      const SizedBox(width: 6),
                      Expanded(child: AlarmStatusesIndicator(alarm.statuses)),
                      const SizedBox(width: 6),
                      SSwitch(alarm.enabled, onChanged: onToggle),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AlarmStatusesIndicator extends StatelessWidget {
  final Set<AlarmStatus> statuses;

  const AlarmStatusesIndicator(this.statuses, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children:
          AlarmStatus.ordered.map((as) {
            if (statuses.contains(as)) {
              return SIcon.glow(
                as.icon,
                color: const Color(0xFFFD251E),
                radius: 11,
              );
            } else {
              return SIcon(as.icon, radius: 11, color: const Color(0x888E98A1));
            }
          }).toList(),
    );
  }
}

class RepeatingIntervalIndicator extends StatelessWidget {
  final int interval;
  const RepeatingIntervalIndicator(this.interval, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SIcon.glow(Icons.repeat, radius: 6, color: const Color(0xFFFD251E)),
        const SizedBox(width: 4),
        SText(
          Duration(milliseconds: interval).toString().split(".")[0],
          fontSize: 12,
          weight: STextWeight.normal,
        ),
      ],
    );
  }
}

class RepeatingDaysIndicator extends StatelessWidget {
  final Set<Weekday> repeatDays;

  const RepeatingDaysIndicator(this.repeatDays, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children:
          Weekday.orderedWeekdays.map((wd) {
            return SText(
              "\u2009${wd.oneChar.capitalized}",
              fontSize: 12,
              weight: STextWeight.normal,
              color:
                  repeatDays.contains(wd)
                      ? const Color(0xFFFD251E)
                      : const Color(0xFF8E98A1),
              glow: repeatDays.contains(wd),
            );
          }).toList(),
    );
  }
}
