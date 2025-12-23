import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_alarm/presentation/pages/alarm_edit/clock_analog.dart';
import 'package:solar_alarm/presentation/pages/home/alarms/alarms.dart';
import 'package:solar_alarm/presentation/pages/home/digital_clock/digital_clock_bloc.dart';
import 'package:solar_alarm/presentation/pages/home/prayer_timings/prayer_timings.dart';
import 'package:solar_alarm/presentation/pages/home/prayer_timings/prayer_timings_bloc.dart';

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
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Prayer Alarm'),
          actions: [
            IconButton(
              icon: const Icon(Icons.bug_report),
              onPressed: () => Navigator.of(context).pushNamed('/logs'),
            ),
          ],
        ),
        body: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF363E46), Color(0xff2C343C)],
              // colors: [Color(0xFFEEF0F5), Color(0xffE2E4EA)],
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 60),
              ClockDigital(),
              SizedBox(height: 8),
              PrayerTimingsWidget(),
              SizedBox(height: 16),
              Expanded(child: AlarmsWidget()),
            ],
          ),
        ),
      ),
    );
  }
}
