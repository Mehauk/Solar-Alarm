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
  const PrayerTimingsLoadSuccess(this.prayers);
  final Prayers prayers;

  @override
  Prayers get model => prayers;
}

final class PrayerTimingsLoadFailure extends PrayerTimingsState
    implements WithErrorMessage, UiState {
  const PrayerTimingsLoadFailure(this.message);

  @override
  final String message;
}

final class PrayerUpdateSuccess extends PrayerTimingsState
    implements WithViewModel<Prayers>, UiState {
  const PrayerUpdateSuccess(this.prayers);
  final Prayers prayers;

  @override
  Prayers get model => prayers;
}

final class PrayerUpdateFailure extends PrayerTimingsState
    implements WithErrorMessage {
  const PrayerUpdateFailure(this.message);

  @override
  final String message;
}
