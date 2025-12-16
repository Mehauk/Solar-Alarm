import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

enum LogLevel { debug, info, warn, error }

class Logger {
  static const _fileName = 'app_logs.txt';
  static const int _maxBytes = 2 * 1024 * 1024; // 2MB
  static const int _keepBytes =
      1 * 1024 * 1024; // keep last 1MB when truncating

  static Future<File> _logFile() async {
    final dir = await getApplicationDocumentsDirectory();
    print(dir);
    final file = File('${dir.path}/$_fileName');
    if (!await file.exists()) {
      try {
        await file.create(recursive: true);
      } catch (_) {}
    }
    return file;
  }

  static String _levelToString(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warn:
        return 'WARN';
      case LogLevel.error:
        return 'ERROR';
    }
  }

  static Future<void> _enforceSizeLimit(File file) async {
    try {
      if (await file.exists()) {
        final len = await file.length();
        if (len > _maxBytes) {
          final bytes = await file.readAsBytes();
          final start = len - _keepBytes;
          final keepStart = start < 0 ? 0 : start;
          final kept = bytes.sublist(keepStart);
          await file.writeAsBytes(kept, flush: true);
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Logger._enforceSizeLimit failed: $e');
    }
  }

  static Future<void> append(
    String tag,
    String message, {
    LogLevel level = LogLevel.info,
  }) async {
    try {
      final file = await _logFile();
      await _enforceSizeLimit(file);
      final timestamp = DateTime.now().toUtc().toIso8601String();
      final line = '$timestamp ${_levelToString(level)} $tag: $message\n';
      await file.writeAsString(line, mode: FileMode.append, flush: true);
    } catch (e) {
      // If logging to file fails, fall back to console
      // ignore: avoid_print
      print('Logger.append failed: $e');
    }
  }

  static Future<String> readAll() async {
    try {
      final file = await _logFile();
      return await file.readAsString();
    } catch (e) {
      // ignore: avoid_print
      print('Logger.readAll failed: $e');
      return '';
    }
  }

  static Future<List<String>> tail(int lines) async {
    try {
      final all = await readAll();
      final arr = all.split('\n');
      if (arr.isEmpty) return [];
      final filtered = arr.where((s) => s.trim().isNotEmpty).toList();
      final start = filtered.length - lines;
      return filtered.sublist(start < 0 ? 0 : start);
    } catch (e) {
      // ignore: avoid_print
      print('Logger.tail failed: $e');
      return [];
    }
  }

  static Future<void> clear() async {
    try {
      final file = await _logFile();
      if (await file.exists()) {
        await file.writeAsString('');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Logger.clear failed: $e');
    }
  }
}
