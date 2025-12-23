import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_alarm/data/repositories/prayer_repo.dart';
import 'package:solar_alarm/data/services/log_service.dart';
import 'package:solar_alarm/data/services/platform_service.dart';

import 'presentation/pages/home/home_screen.dart';
import 'presentation/pages/logs/logs_screen.dart';

void main() {
  final logger = DebugLogger();
  final invoker = PlatformInvoker('com.example.solar_alarm/main_channel');
  final prayerRepo = PrayerRepository(platformInvoker: invoker, logger: logger);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => logger),
        RepositoryProvider(create: (context) => prayerRepo),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            home: const HomeScreen(),
            routes: {'/logs': (context) => LogsScreen(context.read())},
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
          );
        },
      ),
    ),
  );
}
