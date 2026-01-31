import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_alarm/data/repositories/prayer_repo.dart';
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
          create:
              (context) => DigitalClockBloc(
                prayers:
                    context.read<PrayerRepository>().getPrayers().unwrapOrNull,
              )..add(const TimerStarted()),
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
      child: const Scaffold(
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF363E46), Color(0xff2C343C)],
              // colors: [Color(0xFFEEF0F5), Color(0xffE2E4EA)],
            ),
          ),
          child: _HomeLifeCycleWrapper(),
        ),
      ),
    );
  }
}

class _HomeLifeCycleWrapper extends StatefulWidget {
  const _HomeLifeCycleWrapper();

  @override
  State<_HomeLifeCycleWrapper> createState() => __HomeLifeCycleWrapperState();
}

class __HomeLifeCycleWrapperState extends State<_HomeLifeCycleWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      context.read<AlarmBloc>().add(const AlarmsLoadEvent());
      context.read<PrayerTimingsBloc>().add(const PrayersLoadEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}
