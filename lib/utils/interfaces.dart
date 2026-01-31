abstract interface class WithViewModel<T> {
  T get model;
}

abstract interface class EventState {}

abstract interface class UiState {}

abstract interface class WithErrorMessage extends EventState {
  String get message;
}
