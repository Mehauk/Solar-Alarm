import 'package:flutter/material.dart';
import 'package:solar_alarm/models/alarm.dart';
import 'package:solar_alarm/models/calendar.dart';

import '../ui/text.dart';
import '../utils/extensions.dart';
import 'alarms.dart';
import 'background.dart';
import 'clock.dart';

class AlarmEdit extends StatefulWidget {
  const AlarmEdit({super.key});

  @override
  State<AlarmEdit> createState() => _AlarmEditState();
}

class _AlarmEditState extends State<AlarmEdit> {
  TimeOfDay time = TimeOfDay.now();
  TimePart currentEdit = TimePart.hour;
  DayPart timeInd = DayPart.am;

  final alarm = Alarm(
    name: "MyNameMyNameMyName",
    timeInMillis:
        DateTime.now().add(const Duration(hours: 2)).millisecondsSinceEpoch,
    // repeatInterval: 1000 * 60 * 60,
    repeatDays: {Weekday.friday},
    statuses: {AlarmStatus.sound, AlarmStatus.vibrate},
    enabled: true,
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Background(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              AlarmTile(alarm, onTap: () {}, onToggle: (b) {}),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 40),
                  _TimeCapsule(
                    time.hour12,
                    editType: TimePart.hour,
                    currentEdit: currentEdit,
                    onTap: () => setState(() => currentEdit = TimePart.hour),
                  ),
                  SText(":", fontSize: 36),
                  _TimeCapsule(
                    time.minute,
                    editType: TimePart.minute,
                    currentEdit: currentEdit,
                    onTap: () => setState(() => currentEdit = TimePart.minute),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    children: [
                      _TimeIndicatorWidget(
                        DayPart.am,
                        timeInd,
                        () => setState(() => timeInd = DayPart.am),
                      ),
                      const SizedBox(height: 1),
                      _TimeIndicatorWidget(
                        DayPart.pm,
                        timeInd,
                        () => setState(() => timeInd = DayPart.pm),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeIndicatorWidget extends StatelessWidget {
  final DayPart indicator;
  final DayPart currentInd;
  final void Function() onTap;
  const _TimeIndicatorWidget(this.indicator, this.currentInd, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius:
              indicator == DayPart.am
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
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
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
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFF2C343C),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
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
        ),
      ),
    );
  }
}
