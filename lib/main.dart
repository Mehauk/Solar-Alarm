import 'package:flutter/material.dart';

import 'presentation/pages/home.dart';
import 'presentation/pages/logs_page.dart';

void main() {
  runApp(
    MaterialApp(
      home: const Home(),
      routes: {'/logs': (context) => const LogsPage()},
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
  );
}
