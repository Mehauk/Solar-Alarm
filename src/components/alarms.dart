import 'package:flutter/material.dart';
import 'package:solar_alarm/models/alarm.dart';
import 'package:solar_alarm/models/calendar.dart';

import '../ui/icon.dart';
import '../ui/switch.dart';
import '../ui/text.dart';
import '../utils/extensions.dart';

extension on Alarm {
  DateTime get alarmDate => DateTime.fromMillisecondsSinceEpoch(timeInMillis);
}

class AlarmsWidget extends StatelessWidget {
  const AlarmsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return _Background(
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
                    SIconButton(Icons.add, onTap: () => print(1)),
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
                  children: [
                    AlarmTile(
                      Alarm(
                        name: "MyNameMyNameMyName",
                        timeInMillis:
                            DateTime.now()
                                .add(const Duration(hours: 2))
                                .millisecondsSinceEpoch,
                        // repeatInterval: 1000 * 60 * 60,
                        repeatDays: {Weekday.friday},
                        statuses: {AlarmStatus.sound, AlarmStatus.vibrate},
                        enabled: true,
                      ),
                      onToggle: (bool) {},
                    ),
                  ],
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
  final void Function(bool) onToggle;

  const AlarmTile(this.alarm, {super.key, required this.onToggle});

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
                          SText(alarm.alarmDate.formattedTime.$1, fontSize: 34),
                          const SizedBox(width: 4),
                          Column(
                            children: [
                              if (alarm.alarmDate.formattedTime.$2 == "AM") ...[
                                SText.glow(
                                  "AM",
                                  fontSize: 16,
                                  weight: STextWeight.thin,
                                  color: const Color(0xFFFD251E),
                                ),
                                SText(
                                  "PM",
                                  fontSize: 16,
                                  weight: STextWeight.thin,
                                ),
                              ],
                              if (alarm.alarmDate.formattedTime.$2 == "PM") ...[
                                SText(
                                  "AM",
                                  fontSize: 16,
                                  weight: STextWeight.thin,
                                ),
                                SText.glow(
                                  "PM",
                                  fontSize: 16,
                                  weight: STextWeight.thin,
                                  color: const Color(0xFFFD251E),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SText(alarm.name, fontSize: 16),
                                  const SizedBox(height: 2),
                                  _AlarmStatusesIndicator(alarm.statuses),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (alarm.repeatDays != null)
                            _RepeatingDaysIndicator(alarm.repeatDays!),

                          if (alarm.repeatInterval != null)
                            _RepeatingIntervalIndicator(alarm.repeatInterval!),

                          const SizedBox(height: 2),
                          SText(
                            alarm.alarmDate.formattedDate,
                            fontSize: 12,
                            weight: STextWeight.normal,
                          ),
                        ],
                      ),
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

class _RepeatingIntervalIndicator extends StatelessWidget {
  final int interval;
  const _RepeatingIntervalIndicator(this.interval);

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

class _AlarmStatusesIndicator extends StatelessWidget {
  final Set<AlarmStatus> statuses;

  const _AlarmStatusesIndicator(this.statuses);

  @override
  Widget build(BuildContext context) {
    return Row(
      children:
          AlarmStatus.ordered
              .map((as) {
                if (statuses.contains(as)) {
                  return SIcon.glow(
                    as.icon,
                    color: const Color(0xFFFD251E),
                    radius: 7,
                  );
                } else {
                  return SIcon(
                    as.icon,
                    radius: 7,
                    color: const Color(0x888E98A1),
                  );
                }
              })
              .expand((w) => [w, const SizedBox(width: 4)])
              .toList(),
    );
  }
}

class _RepeatingDaysIndicator extends StatelessWidget {
  final Set<Weekday> repeatDays;

  const _RepeatingDaysIndicator(this.repeatDays);

  @override
  Widget build(BuildContext context) {
    return Row(
      children:
          Weekday.orderedWeekdays.map((wd) {
            if (repeatDays.contains(wd)) {
              return SText.glow(
                "\u2009${wd.oneChar.capitalized}",
                fontSize: 12,
                weight: STextWeight.normal,
                color: const Color(0xFFFD251E),
              );
            }
            return SText(
              "\u2009${wd.oneChar.capitalized}",
              fontSize: 12,
              weight: STextWeight.normal,
            );
          }).toList(),
    );
  }
}

class _Background extends StatelessWidget {
  final Widget child;
  const _Background({required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5D666D), Color(0x0023282D)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 1.5),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF363E46), Color(0xFF2C343C)],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
