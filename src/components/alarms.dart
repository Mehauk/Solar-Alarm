import 'package:flutter/material.dart';
import 'package:solar_alarm/models/alarm.dart';

import '../globals.dart';
import '../ui/icon.dart';
import '../ui/switch.dart';
import '../ui/text.dart';
import '../utils/extensions.dart';
import 'alarm_edit.dart';
import 'gradient_bordered_box.dart';

class AlarmsWidget extends StatefulWidget {
  const AlarmsWidget({super.key});

  @override
  State<AlarmsWidget> createState() => _AlarmsWidgetState();
}

class _AlarmsWidgetState extends State<AlarmsWidget> {
  List<Alarm> alarms = [];
  late final void Function(List<Alarm>) obs;

  @override
  void initState() {
    super.initState();

    alarms = alarmsObserver.data;
    obs = (newAlarms) {
      setState(() => alarms = newAlarms);
    };

    alarmsObserver.addObserver(obs);
  }

  @override
  void dispose() {
    alarmsObserver.removeObserver(obs);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBorderedBox(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 36),
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
                          () => showModalBottomSheet(
                            enableDrag: false,
                            isScrollControlled: true,
                            context: context,
                            builder: (context) => const AlarmEdit(),
                          ),
                    ),
                    // const SizedBox(width: 4),
                    // SIconButton(
                    //   Icons.more_horiz,
                    //   onTap:
                    //       () => showDialog(
                    //         context: context,
                    //         builder: (context) {
                    //           return TimePickerDialog(
                    //             initialTime: TimeOfDay.now(),
                    //           );
                    //         },
                    //       ),
                    // ),
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
                              onTap:
                                  () => showModalBottomSheet(
                                    enableDrag: false,
                                    isScrollControlled: true,
                                    context: context,
                                    builder:
                                        (context) => AlarmEdit(alarm: e.value),
                                  ),
                              onToggle: (b) {
                                setState(() {
                                  alarms[e.key] = alarms[e.key].copyWith(
                                    enabled: b,
                                  );
                                });
                              },
                              onStatusTap: (status) {
                                setState(() {
                                  if (alarms[e.key].statuses.contains(status)) {
                                    alarms[e.key] = alarms[e.key].copyWith(
                                      statuses: {...alarms[e.key].statuses}
                                        ..remove(status),
                                    );
                                  } else {
                                    alarms[e.key] = alarms[e.key].copyWith(
                                      statuses: {...alarms[e.key].statuses}
                                        ..add(status),
                                    );
                                  }
                                });
                              },
                            ),
                          )
                          .expand((w) => [w, const SizedBox(height: 18)])
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
  final void Function(AlarmStatus status) onStatusTap;

  const AlarmTile(
    this.alarm, {
    super.key,
    required this.onTap,
    required this.onToggle,
    required this.onStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Durations.short2,
      opacity: alarm.enabled ? 1 : 0.7,
      child: Material(
        elevation: 10,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: GradientBorderedBox(
          borderRadius: BorderRadius.circular(16),
          border: const EdgeInsets.all(1.0),
          borderGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5D666D), Color(0xFF363E46)],
          ),
          backgroundGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3F4850), Color(0xFF363E46)],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 11),
                child: Column(
                  children: [
                    Column(
                      children: [
                        SText(
                          alarm.name.toUpperCase(),
                          fontSize: 16,
                          shadow: true,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SText(
                                  alarm.date.formattedTime.$1,
                                  fontSize: 34,
                                ),
                                const SizedBox(width: 4),
                                Column(
                                  children: [
                                    SText(
                                      "AM",
                                      fontSize: 16,
                                      weight: STextWeight.thin,
                                      color:
                                          alarm.date.formattedTime.$2 ==
                                                  DayPeriod.am
                                              ? const Color(0xFFFD251E)
                                              : const Color(0xFF8E98A1),
                                      glow:
                                          alarm.date.formattedTime.$2 ==
                                          DayPeriod.am,
                                    ),
                                    SText(
                                      "PM",
                                      fontSize: 16,
                                      weight: STextWeight.thin,
                                      color:
                                          alarm.date.formattedTime.$2 ==
                                                  DayPeriod.pm
                                              ? const Color(0xFFFD251E)
                                              : const Color(0xFF8E98A1),
                                      glow:
                                          alarm.date.formattedTime.$2 ==
                                          DayPeriod.pm,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Expanded(child: SizedBox()),

                            SText(alarm.date.formattedDate, fontSize: 12),

                            if (alarm.repeatInterval != null) ...[
                              const SizedBox(width: 4),
                              RepeatingIntervalIndicator(alarm.repeatInterval!),
                            ],

                            if (alarm.repeatDays.isNotEmpty) ...[
                              const SizedBox(width: 4),
                              RepeatingDaysIndicator(alarm.repeatDays),
                            ],

                            const SizedBox(width: 6),
                            SSwitch(alarm.enabled, onChanged: onToggle),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 140,
                      child: AlarmStatusesIndicator(
                        alarm.statuses,
                        onTap: onStatusTap,
                        enabled: alarm.enabled,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
