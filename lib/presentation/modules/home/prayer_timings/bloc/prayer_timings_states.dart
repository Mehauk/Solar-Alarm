part of 'prayer_timings_bloc.dart';

sealed class PrayerTimingsState {
  const PrayerTimingsState();
}

final class PrayerTimingsLoadSuccess extends PrayerTimingsState
    implements WithViewModel<Prayers>, UiState {
  const PrayerTimingsLoadSuccess(this.model);

  @override
  final Prayers model;
}

final class PrayerTimingsLoadFailure extends PrayerTimingsState
    implements UiState {
  const PrayerTimingsLoadFailure();
}

final class PrayerTimingsChangeFailure extends PrayerTimingsState
    implements WithErrorMessage {
  const PrayerTimingsChangeFailure(this.message);

  @override
  final String message;
}
