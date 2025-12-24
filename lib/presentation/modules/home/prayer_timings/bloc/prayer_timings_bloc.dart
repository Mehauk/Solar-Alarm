import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_alarm/data/models/prayers.dart';
import 'package:solar_alarm/data/repositories/prayer_repo.dart';
import 'package:solar_alarm/utils/interfaces.dart';
import 'package:solar_alarm/utils/result.dart';

part 'prayer_timings_events.dart';
part 'prayer_timings_states.dart';

class PrayerTimingsBloc extends Bloc<PrayerTimingsEvent, PrayerTimingsState> {
  final PrayerRepository _prayerRepository;

  PrayerTimingsBloc(this._prayerRepository)
    : super(const PrayerTimingsLoadInProgress()) {
    on<PrayersLoadEvent>((event, emit) async {
      final prayers = await _prayerRepository.getPrayers();
      switch (prayers) {
        case Ok(value: var data):
          emit(PrayerTimingsLoadSuccess(data));
        case Err(message: var e):
          emit(PrayerTimingsChangeFailure(e));
      }
    });

    on<PrayerUpdateEvent>((event, emit) async {
      final result = await _prayerRepository.updatePrayerSettings(
        event._prayer,
        event._status,
      );

      switch (result) {
        case Ok():
          if (state is WithViewModel) {
            final prayers = (state as WithViewModel<Prayers>).model;
            prayers.statuses[event._prayer] = event._status;
            emit(PrayerUpdateSuccess(prayers));
          }
        case Err(message: var e):
          emit(PrayerTimingsChangeFailure(e));
      }
    });
  }
}
