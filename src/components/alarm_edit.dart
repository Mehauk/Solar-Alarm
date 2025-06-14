import 'package:flutter/material.dart';
import 'package:solar_alarm/models/alarm.dart';
import 'package:solar_alarm/models/calendar.dart';
import 'package:solar_alarm/platform/platform_channel.dart';

import '../globals.dart';
import '../ui/button.dart';
import '../ui/icon.dart';
import '../ui/text.dart';
import '../ui/text_field.dart';
import '../utils/formatting_extensions.dart';
import 'clock.dart';
import 'gradient_bordered_box.dart';

class AlarmEdit extends StatefulWidget {
  final Alarm? alarm;
  const AlarmEdit({super.key, this.alarm});

  @override
  State<AlarmEdit> createState() => _AlarmEditState();
}

class _AlarmEditState extends State<AlarmEdit> {
  Alarm alarm = Alarm(
    name: "",
    enabled: true,
    timeInMillis: DateTime.now().millisecondsSinceEpoch,
  );
  TimePart currentEdit = TimePart.hour;
  DayPeriod timeInd = DayPeriod.am;

  TextEditingController nameController = TextEditingController();

  void deleteAlarm(BuildContext context) async {
    Alarm newAlarm = alarm;
    List<Alarm> newAlarms = [...alarmsObserver.data];

    if (widget.alarm != null) {
      newAlarms.remove(widget.alarm);
      await PlatformChannel.cancelAlarm(newAlarm.name);
    }

    alarmsObserver.update(newAlarms);
    showSnackbar("Deleted Alarm: ${newAlarm.name}");
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> saveChanges(BuildContext context) async {
    Alarm newAlarm = alarm.copyWith(enabled: true);
    List<Alarm> newAlarms = [...alarmsObserver.data];

    if (widget.alarm != null) {
      newAlarms.remove(widget.alarm);
      await PlatformChannel.cancelAlarm(newAlarm.name);
    }

    final replaceIndex = newAlarms.indexOf(newAlarm);
    if (replaceIndex >= 0) {
      newAlarms.removeAt(replaceIndex);
      showSnackbar("Replaced Alarm: ${newAlarm.name}");
    }

    await PlatformChannel.setAlarm(newAlarm);
    newAlarms.add(newAlarm);
    alarmsObserver.update(newAlarms);
    if (context.mounted) Navigator.pop(context, newAlarm);
  }

  void showSnackbar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 20,
        behavior: SnackBarBehavior.floating,
        padding: EdgeInsets.zero,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          right: 20,
          left: 20,
        ),
        backgroundColor: Colors.transparent,
        content: GradientBorderedBox(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: SText(text, fontSize: 16)),
          ),
        ),
      ),
    );
  }

  void updateDate(DateTime date) {
    final TimeOfDay alarmTime = alarm.time;
    DateTime newDate = date.copyWith(
      hour: alarmTime.hour,
      minute: alarmTime.minute,
    );
    setState(() {
      alarm = alarm.copyWith(timeInMillis: newDate.millisecondsSinceEpoch);
    });
  }

  void updateTime(TimeOfDay timeUpdate) {
    setState(() {
      DateTime date = alarm.date.copyWith(
        hour: (timeUpdate.hour + (timeInd == DayPeriod.pm ? 12 : 0)) % 24,
        minute: timeUpdate.minute,
        second: 0,
      );
      alarm = alarm.copyWith(timeInMillis: date.millisecondsSinceEpoch);
    });
  }

  void updateDayPeriod(DayPeriod period) {
    timeInd = period;
    updateTime(alarm.time);
  }

  void updateStatus(AlarmStatus status) {
    setState(() {
      if (alarm.statuses.contains(status)) {
        alarm = alarm.copyWith(statuses: {...alarm.statuses}..remove(status));
      } else {
        alarm = alarm.copyWith(statuses: {...alarm.statuses}..add(status));
      }
    });
  }

  void updateRepeatingDay(Weekday day) {
    setState(() {
      if (alarm.repeatDays.contains(day)) {
        alarm = alarm.copyWith(repeatDays: {...alarm.repeatDays}..remove(day));
      } else {
        alarm = alarm.copyWith(repeatDays: {...alarm.repeatDays}..add(day));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    alarm = widget.alarm ?? alarm;
    timeInd = alarm.date.formattedTime.$2;
    nameController.value = TextEditingValue(text: alarm.name);
    nameController.addListener(() {
      setState(() => alarm = alarm.copyWith(name: nameController.text.trim()));
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400 + MediaQuery.of(context).viewInsets.bottom,
      child: GradientBorderedBox(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SText("Set Alarm", fontSize: 18),
                    InkWell(
                      onTap: () => deleteAlarm(context),
                      child: const SIcon(
                        Icons.delete_forever_outlined,
                        radius: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  runSpacing: 12,
                  spacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Clock(
                      clockDiameter: 150,
                      time: TimeOfDay.fromDateTime(alarm.date),
                      editingPart: currentEdit,
                      onUpdate: updateTime,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (alarm.date.deicticWord != null)
                                  SText(alarm.date.deicticWord!, fontSize: 12),
                                SText(alarm.date.formattedDate, fontSize: 12),
                              ],
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              onPressed:
                                  () => showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return CalendarDatePicker(
                                        initialDate: alarm.date,
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now().add(
                                          const Duration(days: 365 * 100),
                                        ),
                                        onDateChanged: (date) {
                                          updateDate(date);
                                          Navigator.pop(context);
                                        },
                                      );
                                    },
                                  ),
                              icon: const SIcon(Icons.calendar_month),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _TimeCapsule(
                              alarm.time.hour12,
                              editType: TimePart.hour,
                              currentEdit: currentEdit,
                              onTap:
                                  () => setState(
                                    () => currentEdit = TimePart.hour,
                                  ),
                            ),
                            SText(":", fontSize: 36),
                            _TimeCapsule(
                              alarm.time.minute,
                              editType: TimePart.minute,
                              currentEdit: currentEdit,
                              onTap:
                                  () => setState(
                                    () => currentEdit = TimePart.minute,
                                  ),
                            ),
                            const SizedBox(width: 6),
                            Column(
                              children: [
                                _TimeIndicatorWidget(
                                  DayPeriod.am,
                                  timeInd,
                                  updateDayPeriod,
                                ),
                                const SizedBox(height: 1),
                                _TimeIndicatorWidget(
                                  DayPeriod.pm,
                                  timeInd,
                                  updateDayPeriod,
                                ),
                              ],
                            ),
                            const SizedBox(width: 6),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Material(
                          color: Colors.transparent,
                          child: RepeatingDaysIndicator(
                            alarm.repeatDays,
                            fontSize: 16,
                            padding: 5.5,
                            onDayToggled: updateRepeatingDay,
                          ),
                        ),

                        const SizedBox(height: 16),
                        SizedBox(
                          width: 170,
                          child: STextField(
                            labelText: "Name required",
                            controller: nameController,
                          ),
                        ),

                        const SizedBox(height: 8),
                        SizedBox(
                          width: 170,
                          child: Material(
                            color: Colors.transparent,
                            child: AlarmStatusesIndicator(
                              alarm.statuses,
                              onTap: updateStatus,
                              enabled: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SButton(
                      onTap: () => Navigator.pop(context),
                      destructive: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 14,
                      ),
                      child: SizedBox(
                        width: 70,
                        child: Center(
                          child: SText(
                            "Cancel",
                            fontSize: 22,
                            color: const Color(0xDDFD251E),
                          ),
                        ),
                      ),
                    ),
                    SButton(
                      onTap:
                          alarm.name.isEmpty
                              ? null
                              : () => saveChanges(context),
                      child: SizedBox(
                        width: 50,
                        child: Center(child: SText("Save", fontSize: 22)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeIndicatorWidget extends StatelessWidget {
  final DayPeriod indicator;
  final DayPeriod currentInd;
  final void Function(DayPeriod) onTap;
  const _TimeIndicatorWidget(this.indicator, this.currentInd, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(indicator),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius:
              indicator == DayPeriod.am
                  ? const BorderRadius.only(topRight: Radius.circular(8))
                  : const BorderRadius.only(bottomRight: Radius.circular(8)),
          border: Border.all(
            color:
                indicator == currentInd
                    ? const Color(0xFFFD251E)
                    : const Color(0xFF8E98A1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: SText(
            indicator.name.toUpperCase(),
            glow: indicator == currentInd,
            color:
                indicator == currentInd
                    ? const Color(0xFFFD251E)
                    : const Color(0xFF8E98A1),
          ),
        ),
      ),
    );
  }
}

class _TimeCapsule extends StatelessWidget {
  final int t;
  final TimePart editType;
  final TimePart currentEdit;
  final void Function() onTap;
  const _TimeCapsule(
    this.t, {
    required this.editType,
    required this.currentEdit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: GestureDetector(
        onTap: onTap,
        child: GradientBorderedBox(
          borderRadius: BorderRadius.circular(8),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: SText(
              t.toString().padLeft(2, "0"),
              fontSize: 32,
              glow: editType == currentEdit,
              color:
                  editType == currentEdit
                      ? const Color(0xFFFD251E)
                      : const Color(0xFF8E98A1),
            ),
          ),
        ),
      ),
    );
  }
}

class AlarmStatusesIndicator extends StatelessWidget {
  final Set<AlarmStatus> statuses;
  final void Function(AlarmStatus) onTap;
  final bool enabled;

  const AlarmStatusesIndicator(
    this.statuses, {
    super.key,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:
          AlarmStatus.ordered.map((as0) {
            Widget child;
            if (statuses.contains(as0)) {
              child = SIcon(
                as0.icon,
                color: const Color(0xFFFD251E),
                radius: 11,
              );
            } else {
              child = SIcon(
                as0.icon,
                radius: 11,
                color: const Color(0x888E98A1),
              );
            }

            if (as0 is DelayedStatus && statuses.contains(as0)) {
              final delay =
                  (statuses.firstWhere((s) => s == as0) as DelayedStatus);
              if (delay.date.isBefore(DateTime.now())) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  onTap(as0);
                });
              }
              child = SizedBox(
                width: 22,
                height: 22,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    child,
                    if (enabled)
                      Positioned(
                        right: -110,
                        child: SizedBox(
                          width: 100,
                          child: SText(
                            "Canceled untill ${delay.date.formattedDateWithYear}",
                            maxLines: 2,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }

            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap:
                  enabled
                      ? () async {
                        if (as0 is DelayedStatus && !statuses.contains(as0)) {
                          final tomorrow = DateTime.now().add(
                            const Duration(days: 1),
                          );
                          final date = await showModalBottomSheet<DateTime?>(
                            context: context,
                            builder: (context) {
                              return CalendarDatePicker(
                                initialDate: tomorrow,
                                firstDate: tomorrow,
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365 * 100),
                                ),
                                onDateChanged:
                                    (DateTime value) =>
                                        Navigator.pop(context, value),
                              );
                            },
                          );

                          if (date != null) {
                            onTap(DelayedStatus(date.millisecondsSinceEpoch));
                          }
                        } else {
                          onTap(as0);
                        }
                      }
                      : null,
              child: Padding(padding: const EdgeInsets.all(6.0), child: child),
            );
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
        const SIcon(Icons.repeat, radius: 6, color: Color(0xFFFD251E)),
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
  final double fontSize;
  final double padding;
  final void Function(Weekday)? onDayToggled;

  const RepeatingDaysIndicator(
    this.repeatDays, {
    super.key,
    this.fontSize = 12,
    this.padding = 0,
    this.onDayToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children:
          Weekday.orderedWeekdays.map((wd) {
            return InkWell(
              onTap: onDayToggled != null ? () => onDayToggled!(wd) : null,
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: SText(
                  "\u2009${wd.oneChar.capitalized}",
                  fontSize: fontSize,
                  weight: STextWeight.normal,
                  color:
                      repeatDays.contains(wd)
                          ? const Color(0xFFFD251E)
                          : const Color(0xFF8E98A1),
                ),
              ),
            );
          }).toList(),
    );
  }
}
