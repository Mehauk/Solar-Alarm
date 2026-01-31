import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jni/jni.dart';
import 'package:solar_alarm/data/repositories/alarm_repo.dart';
import 'package:solar_alarm/data/repositories/prayer_repo.dart';
import 'package:solar_alarm/data/services/log_service.dart';
import 'package:solar_alarm/presentation/modules/home/home_screen.dart';
import 'package:solar_alarm/presentation/modules/logs/logs_screen.dart';

void main() {
  final context = Jni.androidApplicationContext;

  final logger = JniLogService(context);
  final alarmRepo = JniAlarmRepository(context);
  final prayerRepo = JniPrayerRepository(context);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<Logger>(create: (context) => logger),
        RepositoryProvider<PrayerRepository>(create: (context) => prayerRepo),
        RepositoryProvider<AlarmRepository>(create: (context) => alarmRepo),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
        routes: {'/logs': (context) => const LogsScreen()},
        themeMode: ThemeMode.dark,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF646E82),
            brightness: Brightness.light,
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF8E98A1),
            brightness: Brightness.dark,
          ),
        ),
      ),
    ),
  );
}
