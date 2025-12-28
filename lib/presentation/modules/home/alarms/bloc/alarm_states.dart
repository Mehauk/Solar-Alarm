part of 'alarm_bloc.dart';

sealed class AlarmState {
  const AlarmState();
}

final class AlarmsLoadSuccess extends AlarmState
    implements UiState, WithViewModel<AlarmsViewModel> {
  const AlarmsLoadSuccess(this.model);

  @override
  final AlarmsViewModel model;
}

final class AlarmsLoadFailure extends AlarmState implements UiState {
  const AlarmsLoadFailure();
}

final class AlarmChangeFailure extends AlarmState implements WithErrorMessage {
  const AlarmChangeFailure(this.message);

  @override
  final String message;
}
