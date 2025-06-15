final class Observable<T> {
  T _data;
  T get data => _data;

  final T Function(T)? _modify;

  Observable(this._data, {final T Function(T)? modify}) : _modify = modify;

  final List<void Function(T data)> _observers = [];

  void addObserver(void Function(T data) obs) => _observers.add(obs);
  void removeObserver(void Function(T data) obs) => _observers.remove(obs);

  void update(T newData) {
    if (_modify != null) {
      _data = _modify(newData);
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
