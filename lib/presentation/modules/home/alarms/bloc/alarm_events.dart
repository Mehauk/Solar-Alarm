part of 'alarm_bloc.dart';

sealed class AlarmEvent {
  const AlarmEvent();
}

final class AlarmsLoadEvent extends AlarmEvent {
  const AlarmsLoadEvent();
}

final class AlarmUpdateEvent extends AlarmEvent {
  const AlarmUpdateEvent(this.alarm, {this.status, this.oldAlarm});

  final Alarm alarm;
  final AlarmStatus? status;
  final Alarm? oldAlarm;
}

final class AlarmDeleteEvent extends AlarmEvent {
  const AlarmDeleteEvent(this.alarmName);

  final String alarmName;
}
