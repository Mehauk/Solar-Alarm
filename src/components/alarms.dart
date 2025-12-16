import 'package:flutter/material.dart';
import 'package:solar_alarm/models/alarm.dart';
import 'package:solar_alarm/platform/platform_channel.dart';
import 'package:solar_alarm/utils/logger.dart';

import '../globals.dart';
import '../ui/icon.dart';
import '../ui/switch.dart';
import '../ui/text.dart';
import '../utils/formatting_extensions.dart';
import 'alarm_edit.dart';
import 'gradient_bordered_box.dart';

class AlarmsWidget extends StatefulWidget {
  const AlarmsWidget({super.key});

  @override
  State<AlarmsWidget> createState() => _AlarmsWidgetState();
}

class _AlarmsWidgetState extends State<AlarmsWidget> {
  final Map<Alarm, GlobalKey> _alarmKeys = {};
  List<Alarm> alarms = [];
  late final void Function(List<Alarm>) obs;

  final ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();

    alarms = alarmsObservable.data;
    for (var a in alarms) {
      _alarmKeys[a] = GlobalKey();
    }
    obs = (newAlarms) {
      setState(() => alarms = newAlarms);
      for (var a in alarms) {
        _alarmKeys[a] = GlobalKey();
      }
    };

    alarmsObservable.addObserver(obs);
  }

  @override
  void dispose() {
    alarmsObservable.removeObserver(obs);
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
                      onTap: () async {
                        final res = await showModalBottomSheet<Alarm?>(
                          enableDrag: false,
                          isScrollControlled: true,
                          context: context,
                          builder: (context) => const AlarmEdit(),
                        );
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          final key = _alarmKeys[res];
                          if (key?.currentContext != null) {
                            Scrollable.ensureVisible(
                              key!.currentContext!,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          }
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: controller,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children:
                      alarms
                          .asMap()
                          .entries
                          .map(
                            (e) => KeyedSubtree(
                              key: _alarmKeys[e.value],
                              child: AlarmTile(
                                e.value,
                                onTap:
                                    () => showModalBottomSheet(
                                      enableDrag: false,
                                      isScrollControlled: true,
                                      context: context,
                                      builder:
                                          (context) =>
                                              AlarmEdit(alarm: e.value),
                                    ),
                                onToggle: (alarmEnabled) {
                                  setState(() {
                                    alarms[e.key] = alarms[e.key].copyWith(
                                      enabled: alarmEnabled,
                                    );
                                  });
                                  Logger.append(
                                    'AlarmsWidget',
                                    'toggle ${alarms[e.key]}',
                                    level: LogLevel.debug,
                                  );
                                  PlatformChannel.setAlarm(alarms[e.key]);
                                },
                                onStatusTap: (status) {
                                  setState(() {
                                    if (alarms[e.key].statuses.contains(
                                      status,
                                    )) {
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
                                  PlatformChannel.setAlarm(alarms[e.key]);
                                },
                              ),
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
              onLongPress: () {},
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 0, 11),
                child: Column(
                  children: [
                    Column(
                      children: [
                        SText(
                          alarm.name.toUpperCase(),
                          fontSize: 16,
                          shadow: true,
                        ),
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

                            if (alarm.repeatDays.isEmpty)
                              SText(alarm.date.formattedDate, fontSize: 12),

                            if (alarm.repeatDays.isEmpty &&
                                alarm.repeatInterval != null) ...[
                              const SizedBox(width: 4),
                              RepeatingIntervalIndicator(alarm.repeatInterval!),
                            ],

                            if (alarm.repeatDays.isNotEmpty) ...[
                              RepeatingDaysIndicator(alarm.repeatDays),
                            ],

                            const SizedBox(width: 6),
                            SSwitch(
                              padding: const EdgeInsets.fromLTRB(0, 16, 15, 15),
                              alarm.enabled
                                  ? SSwitchStatus.on
                                  : SSwitchStatus.off,
                              onChanged: (s) {
                                onToggle(s == SSwitchStatus.on);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
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
