import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_alarm/data/models/prayers.dart';

class Timer {
  const Timer();
  Stream<DateTime> tick() =>
      Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
}

final class TimerState {
  const TimerState(this.currentTime, this.currentPrayer);
  final DateTime currentTime;
  final Prayer? currentPrayer;

  factory TimerState.initial() {
    final time = DateTime.now();
    const prayer = null; // TODO: calc based on prayer times once synced
    return TimerState(time, prayer);
  }
}

final class TimerStarted {
  const TimerStarted();
}

class DigitalClockBloc extends Bloc<TimerStarted, TimerState> {
  final Timer _timer;

  DigitalClockBloc({Timer timer = const Timer()})
    : _timer = timer,
      super(TimerState.initial()) {
    on<TimerStarted>((event, emit) async {
      await emit.forEach(
        _timer.tick(),
        onData: (dt) => TimerState(dt, null), // TODO: c
      );
    });
  }
}
