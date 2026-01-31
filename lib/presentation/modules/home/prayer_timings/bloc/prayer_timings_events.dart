part of 'prayer_timings_bloc.dart';

sealed class PrayerTimingsEvent {
  const PrayerTimingsEvent();
}

final class PrayersLoadEvent extends PrayerTimingsEvent {
  const PrayersLoadEvent();
}

final class PrayerUpdateEvent extends PrayerTimingsEvent {
  const PrayerUpdateEvent(this._prayer, this._status);

  final Prayer _prayer;
  final PrayerAlarmStatus _status;
}
