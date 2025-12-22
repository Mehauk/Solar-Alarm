import 'dart:io';

import 'package:flutter/foundation.dart';

abstract interface class Logger {
  void log(String message);

  List<String> history();

  void clear();
}

class DebugLogger implements Logger {
  final List<String> _history = [];

  @override
  void log(String message) {
    if (kDebugMode) {
      _history.add(message);
      print(message);
    }
  }

  @override
  List<String> history() => _history;

  @override
  void clear() => _history.clear();
}

class FileLogger implements Logger {
  final File _logFile;

  const FileLogger(this._logFile);

  @override
  void log(String message) {
    _logFile.writeAsStringSync(message, mode: FileMode.append, flush: true);
  }

  @override
  List<String> history() => _logFile.readAsLinesSync();

  @override
  void clear() => _logFile.writeAsBytesSync([], flush: true);
}
