extension Caps on String {
  String get capitalized {
    if (length <= 1) return toUpperCase();
    return this[0].toUpperCase() + substring(1);
  }
}

extension FormatTime on DateTime {
  (String time, String period) get formattedTime {
    final hourInt = this.hour % 12 == 0 ? 12 : this.hour % 12;
    final hour = hourInt.toString().padLeft(2, '0');
    final minute = this.minute.toString().padLeft(2, '0');
    final period = this.hour >= 12 ? 'PM' : 'AM';
    return ('$hour:$minute', period);
  }
}
