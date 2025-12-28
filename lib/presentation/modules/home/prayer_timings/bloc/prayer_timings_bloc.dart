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
    : super(
        _prayerRepository.getPrayers().map(
          (v) => PrayerTimingsLoadSuccess(v),
          (s) => PrayerTimingsChangeFailure(s),
        ),
      ) {
    on<PrayersLoadEvent>((event, emit) {
      final prayers = _prayerRepository.getPrayers();
      switch (prayers) {
        case Ok(value: var data):
          emit(PrayerTimingsLoadSuccess(data));
        case Err(message: var e):
          emit(PrayerTimingsChangeFailure(e));
      }
    });

    on<PrayerUpdateEvent>((event, emit) {
      final result = _prayerRepository.updatePrayerSettings(
        event._prayer,
        event._status,
      );

      switch (result) {
        case Ok():
          add(const PrayersLoadEvent());
        case Err(message: var e):
          emit(PrayerTimingsChangeFailure(e));
      }
    });
  }
}
