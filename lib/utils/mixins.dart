mixin Toggleable<T extends Enum> on Enum {
  T get me;
  List<T> get ordered;

  T get toggle {
    final order = ordered;
    final index = order.indexOf(me) + 1;
    if (index == order.length) return order[0];
    return order[index];
  }

  int get vindex => ordered.indexOf(me);
  bool get isOn => vindex != 0;
}
