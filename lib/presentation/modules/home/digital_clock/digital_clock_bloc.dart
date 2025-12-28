import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_alarm/data/models/prayers.dart';

class Timer {
  const Timer();
  Stream<DateTime> tick() =>
      Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
}

final class TimerViewModel {
  const TimerViewModel(this.currentTime, this.currentPrayer);
  final DateTime currentTime;
  final Prayer? currentPrayer;

  factory TimerViewModel.initial(Prayer? currentPrayer) {
    final time = DateTime.now();
    return TimerViewModel(time, currentPrayer);
  }
}

final class TimerStarted {
  const TimerStarted();
}

class DigitalClockBloc extends Bloc<TimerStarted, TimerViewModel> {
  final Timer _timer;
  final Prayers? prayers;

  DigitalClockBloc({Timer timer = const Timer(), required this.prayers})
    : _timer = timer,
      super(TimerViewModel.initial(prayers?.prayerAtTime(DateTime.now()))) {
    on<TimerStarted>((event, emit) async {
      await emit.forEach(
        _timer.tick(),
        onData: (dt) => TimerViewModel(dt, prayers?.prayerAtTime(dt)),
      );
    });
  }
}
