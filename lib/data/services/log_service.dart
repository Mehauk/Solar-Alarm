import 'dart:io';

import 'package:flutter/foundation.dart';

abstract interface class Logger {
  void log(String message);
}

class DebugLogger implements Logger {
  @override
  void log(String message) {
    if (kDebugMode) {
      print(message);
    }
  }
}

class FileLogger implements Logger {
  final File logFile;

  const FileLogger(this.logFile);

  @override
  void log(String message) {
    logFile.writeAsStringSync(message, mode: FileMode.append, flush: true);
  }
}
