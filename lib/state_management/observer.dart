final class Observer<T> {
  T _data;
  T get data => _data;

  final T Function(T)? modify;

  Observer(this._data, {this.modify});

  final List<void Function(T data)> _observers = [];

  void addObserver(void Function(T data) obs) => _observers.add(obs);
  void removeObserver(void Function(T data) obs) => _observers.remove(obs);

  void update(T newData) {
    if (modify != null) {
      _data = modify!(newData);
    } else {
      _data = newData;
    }
    _notifyObservers();
  }

  void _notifyObservers() {
    for (var observe in _observers) {
      observe(_data);
    }
  }
}
