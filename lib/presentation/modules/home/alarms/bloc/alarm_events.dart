part of 'alarm_bloc.dart';

sealed class AlarmEvent {
  const AlarmEvent();
}

final class AlarmsLoadEvent extends AlarmEvent {
  const AlarmsLoadEvent();
}

final class AlarmUpdateEvent extends AlarmEvent {
  const AlarmUpdateEvent(this.alarm, [this.status]);

  final AlarmStatus? status;
  final Alarm alarm;
}
