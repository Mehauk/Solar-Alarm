final class SDateUtils {
  static (String time, String period) formatTime(DateTime time) {
    final hourInt = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final hour = hourInt.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return ('$hour:$minute', period);
  }
}
