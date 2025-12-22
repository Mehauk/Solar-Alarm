import 'package:flutter/services.dart';

abstract interface class Invoker {
  Future<T?> invoke<T>(String method, [Map<String, Object?>? args]);
}

class Platform implements Invoker {
  final MethodChannel _channel;

  Platform(String channel) : _channel = MethodChannel(channel);

  @override
  Future<T?> invoke<T>(method, [args]) => _channel.invokeMethod(method, args);
}
