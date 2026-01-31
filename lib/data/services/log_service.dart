import 'package:flutter/foundation.dart';
import 'package:jni/jni.dart';
import 'package:solar_alarm/data/services/jni_bindings_service.dart'
    as jni_bindings;

abstract interface class Logger {
  void log(String message);
  void clear();
  List<String> history();
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
  void clear() => _history.clear();

  @override
  List<String> history() => _history;
}

class JniLogService implements Logger {
  final jni_bindings.Logger _logger;
  JniLogService(JObject context) : _logger = jni_bindings.Logger(context);

  @override
  void log(String message) {
    _logger.append(
      JString.fromString("Flutter-FileLogger"),
      JString.fromString(message),
    );
  }

  @override
  void clear() => _logger.clear();

  @override
  List<String> history() {
    return _logger.history().reversed.map((e) => e.toDartString()).toList();
  }
}
