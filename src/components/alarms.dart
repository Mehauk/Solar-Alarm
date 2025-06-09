import 'package:flutter/material.dart';

import '../models/calendar.dart';
import '../ui/icon.dart';
import '../ui/switch.dart';
import '../ui/text.dart';
import '../utils/extensions.dart';

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
                      repeatDays: {Weekday.monday, Weekday.thursday},
                      alarmDate: DateTime.now().add(
                        const Duration(days: 1, hours: 3),
                      ),
                    ),
                    AlarmTile(
                      alarmDate: DateTime.now()
                          .add(const Duration(days: 2))
                          .subtract(const Duration(hours: 4)),
                    ),
                    AlarmTile(
                      repeatInterval: 24 * 60 * 60 * 1000,
                      alarmDate: DateTime.now().add(
                        const Duration(days: 3, hours: 2),
                      ),
                    ),
                    AlarmTile(
                      repeatInterval: 24 * 60 * 60 * 1000,
                      alarmDate: DateTime.now().add(const Duration(days: 1)),
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

class AlarmTile extends StatefulWidget {
  final DateTime alarmDate;
  final Set<Weekday>? repeatDays;
  final int? repeatInterval;

  const AlarmTile({
    super.key,
    required this.alarmDate,
    this.repeatDays,
    this.repeatInterval,
  }) : assert(
         (repeatDays != null ? 1 : 0) + (repeatInterval != null ? 1 : 0) <= 1,
         'Only one of repeatDays, or repeatInterval can be provided.',
       );

  @override
  State<AlarmTile> createState() => _AlarmTileState();
}

class _AlarmTileState extends State<AlarmTile> {
  bool enabled = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Durations.short2,
      opacity: enabled ? 1 : 0.9,
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
                          SText(
                            widget.alarmDate.formattedTime.$1,
                            fontSize: 34,
                          ),
                          const SizedBox(width: 4),
                          Column(
                            children: [
                              if (widget.alarmDate.formattedTime.$2 ==
                                  "AM") ...[
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
                              if (widget.alarmDate.formattedTime.$2 ==
                                  "PM") ...[
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.repeatDays != null)
                            _RepeatingDaysIndicator(widget.repeatDays!),

                          if (widget.repeatInterval != null)
                            _RepeatingIntervalIndicator(widget.repeatInterval!),

                          if (widget.repeatDays == null &&
                              widget.repeatInterval == null)
                            SText(
                              widget.alarmDate.formattedDate,
                              fontSize: 12,
                              weight: STextWeight.normal,
                            ),

                          const SizedBox(width: 12),
                          SSwitch(
                            enabled,
                            onChanged: (v) => setState(() => enabled = v),
                          ),
                        ],
                      ),
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
