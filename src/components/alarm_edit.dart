import 'package:flutter/material.dart';
import 'package:solar_alarm/models/alarm.dart';
import 'package:solar_alarm/models/calendar.dart';

import '../ui/button.dart';
import '../ui/icon.dart';
import '../ui/text.dart';
import '../ui/text_field.dart';
import '../utils/extensions.dart';
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

  @override
  void initState() {
    super.initState();
    alarm = widget.alarm ?? alarm;
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
                SText("Set Alarm", fontSize: 18),
                const SizedBox(height: 12),
                Wrap(
                  runSpacing: 12,
                  spacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Clock(
                      clockDiameter: 150,
                      time: TimeOfDay.fromDateTime(alarm.date),
                      editingPart: currentEdit,
                      onUpdate: (timeUpdate) {
                        setState(() {
                          DateTime date = alarm.date.copyWith(
                            hour: timeUpdate.hour,
                            minute: timeUpdate.minute,
                            second: 0,
                          );
                          alarm = alarm.copyWith(
                            timeInMillis: date.millisecondsSinceEpoch,
                          );
                        });
                      },
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SText(alarm.date.formattedDate),
                            const SizedBox(width: 4),
                            IconButton(
                              onPressed: () => print(1),
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
                                  () => setState(() => timeInd = DayPeriod.am),
                                ),
                                const SizedBox(height: 1),
                                _TimeIndicatorWidget(
                                  DayPeriod.pm,
                                  timeInd,
                                  () => setState(() => timeInd = DayPeriod.pm),
                                ),
                              ],
                            ),
                            const SizedBox(width: 6),
                          ],
                        ),
                        const SizedBox(height: 16),

                        RepeatingDaysIndicator(
                          alarm.repeatDays ?? {},
                          fontSize: 16,
                          padding: 5.5,
                        ),

                        const SizedBox(height: 16),
                        const SizedBox(
                          height: 40,
                          width: 170,
                          child: STextField(labelText: "Enter alarm name"),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 40),
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
                      onTap: () => print(1),
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
  final void Function() onTap;
  const _TimeIndicatorWidget(this.indicator, this.currentInd, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
          AlarmStatus.ordered.map((as) {
            final Widget child;
            if (statuses.contains(as)) {
              child = SIcon(
                as.icon,
                color: const Color(0xFFFD251E),
                radius: 11,
              );
            } else {
              child = SIcon(
                as.icon,
                radius: 11,
                color: const Color(0x888E98A1),
              );
            }
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: enabled ? () => onTap(as) : null,
              child: Padding(padding: const EdgeInsets.all(6.0), child: child),
            );
          }).toList(),
    );
  }
}

class RepeatingDaysIndicator extends StatelessWidget {
  final Set<Weekday> repeatDays;
  final double fontSize;
  final double padding;

  const RepeatingDaysIndicator(
    this.repeatDays, {
    super.key,
    this.fontSize = 12,
    this.padding = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children:
          Weekday.orderedWeekdays.map((wd) {
            return Padding(
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
            );
          }).toList(),
    );
  }
}
