import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_alarm/presentation/core/icon.dart';
import 'package:solar_alarm/presentation/modules/home/alarms/bloc/alarm_bloc.dart';
import 'package:solar_alarm/utils/interfaces.dart';
import 'package:solar_alarm/utils/widget_extensions.dart';

import '../../../../data/models/alarm.dart';
import '../../../../utils/extensions.dart';
import '../../../core/gradient_bordered_box.dart';
import '../../../core/switch.dart';
import '../../../core/text.dart';
import 'alarm_edit/alarm_edit_dialogue.dart';

class AlarmsWidget extends StatelessWidget {
  const AlarmsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AlarmBloc, AlarmState>(
      listenWhen: (previous, current) => current is WithErrorMessage,
      listener: (context, state) {
        ScaffoldMessenger.of(
          context,
        ).showErrorSnackbar(state as WithErrorMessage);
      },
      buildWhen: (previous, current) => current is UiState,
      builder: (context, state) {
        switch (state as UiState) {
          case AlarmsLoadInProgress():
            return const Center(child: CircularProgressIndicator());
          case AlarmsLoadSuccess(model: var model):
            return GradientBorderedBox(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 36,
                    ),
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
                                  builder:
                                      (c) => BlocProvider.value(
                                        value: context.read<AlarmBloc>(),
                                        child: const AlarmEdit(),
                                      ),
                                );
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  final key = model.alarmKeys[res];
                                  if (key?.currentContext != null) {
                                    Scrollable.ensureVisible(
                                      key!.currentContext!,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children:
                              model.alarms
                                  .asMap()
                                  .entries
                                  .map(
                                    (e) => KeyedSubtree(
                                      key: model.alarmKeys[e.value],
                                      child: AlarmTile(
                                        e.value,
                                        onTap:
                                            () => showModalBottomSheet(
                                              enableDrag: false,
                                              isScrollControlled: true,
                                              context: context,
                                              builder:
                                                  (c) => BlocProvider.value(
                                                    value:
                                                        context
                                                            .read<AlarmBloc>(),
                                                    child: AlarmEdit(
                                                      alarm: e.value,
                                                    ),
                                                  ),
                                            ),
                                        onToggle: (alarmEnabled) {
                                          context.read<AlarmBloc>().add(
                                            AlarmUpdateEvent(
                                              model.alarms[e.key].copyWith(
                                                enabled: alarmEnabled,
                                              ),
                                            ),
                                          );
                                        },
                                        onStatusTap: (status) {
                                          context.read<AlarmBloc>().add(
                                            AlarmUpdateEvent(
                                              model.alarms[e.key].copyWith(),
                                              status: status,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                  .expand(
                                    (w) => [w, const SizedBox(height: 18)],
                                  )
                                  .toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          case AlarmsLoadFailure():
            return Center(
              child: IconButton(
                onPressed: () {
                  context.read<AlarmBloc>().add(const AlarmsLoadEvent());
                },
                icon: const Icon(Icons.refresh),
              ),
            );
        }

        throw UnimplementedError();
      },
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
