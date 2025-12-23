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

  AlarmBloc(this._alarmRepository) : super(const AlarmsLoadInProgress()) {
    on<AlarmsLoadEvent>((event, emit) async {
      final alarms = await _alarmRepository.getAlarms();

      switch (alarms) {
        case Ok<List<Alarm>>(value: var alarms):
          emit(AlarmsLoadSuccess(AlarmsViewModel(alarms)));
        case Err<List<Alarm>>():
          emit(const AlarmsLoadFailure());
      }
    });

    on<AlarmUpdateEvent>((event, emit) async {
      final Alarm newAlarm;
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

      final res = await _alarmRepository.setAlarm(newAlarm);

      switch (res) {
        case Ok<void>():
          add(const AlarmsLoadEvent());
        case Err<void>(message: var e):
          emit(AlarmUpdateFailure(e));
      }
    });
  }
}
