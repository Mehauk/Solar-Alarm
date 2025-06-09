final class Observer<T> {
  T _data;

  Observer(this._data);

  List<void Function(T data)> observers = [];

  void modify(T newData) {
    _data = newData;
    _notifyObservers();
  }

  void _notifyObservers() {
    for (var observe in observers) {
      observe(_data);
    }
  }
}
