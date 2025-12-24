part of 'prayer_timings_bloc.dart';

sealed class PrayerTimingsState {
  const PrayerTimingsState();
}

final class PrayerTimingsLoadInProgress extends PrayerTimingsState
    implements UiState {
  const PrayerTimingsLoadInProgress();
}

final class PrayerTimingsLoadSuccess extends PrayerTimingsState
    implements WithViewModel<Prayers>, UiState {
  const PrayerTimingsLoadSuccess(this.model);

  @override
  final Prayers model;
}

final class PrayerTimingsChangeFailure extends PrayerTimingsState
    implements WithErrorMessage, UiState {
  const PrayerTimingsChangeFailure(this.message);

  @override
  final String message;
}

final class PrayerUpdateSuccess extends PrayerTimingsState
    implements WithViewModel<Prayers>, UiState {
  const PrayerUpdateSuccess(this.model);

  @override
  final Prayers model;
}
