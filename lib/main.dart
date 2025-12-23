import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_alarm/data/services/log_service.dart';

import 'presentation/pages/home/home.dart';
import 'presentation/pages/logs_page.dart';

void main() {
  runApp(
    RepositoryProvider(
      create: (context) => DebugLogger(),
      child: Builder(
        builder: (context) {
          return MaterialApp(
            home: const Home(),
            routes: {'/logs': (context) => LogsPage(context.read())},
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
