import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_alarm/data/models/alarm.dart';
import 'package:solar_alarm/data/repositories/alarm_repo.dart';
import 'package:solar_alarm/presentation/modules/home/alarms/bloc/alarms_view_model.dart';
import 'package:solar_alarm/utils/interfaces.dart';
import 'package:solar_alarm/utils/result.dart';

part 'alarm_events.dart';
part 'alarm_states.dart';

class AlarmBloc extends Bloc<AlarmEvent, AlarmState> {
  final AlarmRepository _alarmRepository;

  AlarmBloc(this._alarmRepository)
    : super(
        _alarmRepository.getAlarms().map(
          (v) => AlarmsLoadSuccess(AlarmsViewModel(v)),
          (s) => const AlarmsLoadFailure(),
        ),
      ) {
    on<AlarmsLoadEvent>((event, emit) {
      final alarms = _alarmRepository.getAlarms();

      switch (alarms) {
        case Ok<List<Alarm>>(value: var alarms):
          emit(AlarmsLoadSuccess(AlarmsViewModel(alarms)));
        case Err<List<Alarm>>():
          emit(const AlarmsLoadFailure());
      }
    });

    on<AlarmDeleteEvent>((event, emit) {
      final delRes = _alarmRepository.cancelAlarm(event.alarmName);

      switch (delRes) {
        case Ok<void>():
          add(const AlarmsLoadEvent());
        case Err<void>(message: var e):
          emit(AlarmChangeFailure(e));
      }
    });

    on<AlarmUpdateEvent>((event, emit) {
      Alarm newAlarm;
      if (event.status != null) {
        if (event.alarm.statuses.contains(event.status)) {
          newAlarm = event.alarm.copyWith(
            statuses: {...event.alarm.statuses}..remove(event.status),
          );
        } else {
          newAlarm = event.alarm.copyWith(
            statuses: {...event.alarm.statuses}..add(event.status!),
          );
        }
      } else {
        newAlarm = event.alarm;
      }

      if (newAlarm.repeatDays.isNotEmpty) {
        newAlarm = newAlarm.copyWith(
          timeInMillis:
              DateTime.now()
                  .copyWith(
                    hour: newAlarm.time.hour,
                    minute: newAlarm.time.minute,
                  )
                  .millisecondsSinceEpoch,
        );
      }

      if (event.oldAlarm != null) {
        final delRes = _alarmRepository.cancelAlarm(event.oldAlarm!.name);
        if (delRes is Err) return emit(AlarmChangeFailure(delRes.message));
      }

      final res = _alarmRepository.setAlarm(newAlarm);

      switch (res) {
        case Ok<void>():
          add(const AlarmsLoadEvent());
        case Err<void>(message: var e):
          emit(AlarmChangeFailure(e));
      }
    });
  }
}
