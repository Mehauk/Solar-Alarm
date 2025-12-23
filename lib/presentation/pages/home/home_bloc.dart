import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_alarm/data/repositories/alarm_repo.dart';
import 'package:solar_alarm/data/repositories/prayer_repo.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AlarmRepository _alarmRepo;
  final PrayerRepository _prayerRepo;

  HomeBloc(this._alarmRepo, this._prayerRepo) : super(HomeInitial()) {
    on<HomeEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
