import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_alarm/presentation/modules/home/alarms/alarms.dart';
import 'package:solar_alarm/presentation/modules/home/alarms/bloc/alarm_bloc.dart';
import 'package:solar_alarm/presentation/modules/home/digital_clock/digital_clock.dart';
import 'package:solar_alarm/presentation/modules/home/digital_clock/digital_clock_bloc.dart';
import 'package:solar_alarm/presentation/modules/home/prayer_timings/bloc/prayer_timings_bloc.dart';
import 'package:solar_alarm/presentation/modules/home/prayer_timings/prayer_timings.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => DigitalClockBloc()..add(const TimerStarted()),
        ),
        BlocProvider(
          create:
              (context) =>
                  PrayerTimingsBloc(context.read())
                    ..add(const PrayersLoadEvent()),
        ),
        BlocProvider(
          create:
              (context) =>
                  AlarmBloc(context.read())..add(const AlarmsLoadEvent()),
        ),
      ],
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF363E46), Color(0xff2C343C)],
              // colors: [Color(0xFFEEF0F5), Color(0xffE2E4EA)],
            ),
          ),
          child: Column(
            children: [
              if (kDebugMode) ...[
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      padding: const EdgeInsets.all(5),
                      icon: const Icon(Icons.bug_report, size: 20),
                      onPressed: () => Navigator.of(context).pushNamed('/logs'),
                    ),
                  ],
                ),
              ] else
                const SizedBox(height: 60),
              const ClockDigital(),
              const SizedBox(height: 8),
              const PrayerTimingsWidget(),
              const SizedBox(height: 16),
              const Expanded(child: AlarmsWidget()),
            ],
          ),
        ),
      ),
    );
  }
}
