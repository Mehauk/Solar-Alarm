import 'package:flutter/material.dart';
import 'package:solar_alarm/models/calendar.dart';

extension FormatString on String {
  String get capitalized {
    if (length <= 1) return toUpperCase();
    return this[0].toUpperCase() + substring(1);
  }
}

extension FormatDateTime on DateTime {
  (String time, String period) get formattedTime {
    final hourInt = this.hour % 12 == 0 ? 12 : this.hour % 12;
    final hour = hourInt.toString().padLeft(2, '0');
    final minute = this.minute.toString().padLeft(2, '0');
    final period = this.hour >= 12 ? 'PM' : 'AM';
    return ('$hour:$minute', period);
  }

  String get formattedDate {
    final weekdays =
        Weekday.orderedWeekdays.map((wd) => wd.threeChar.capitalized).toList();
    final months =
        Month.orderedMonths.map((m) => m.threeChar.capitalized).toList();

    final weekday = weekdays[this.weekday % 7];
    final day = this.day.toString().padLeft(2, '0');
    final month = months[this.month - 1];
    return '$weekday, $day $month';
  }
}

extension FormatTime on TimeOfDay {
  int get hour12 {
    final hour12 = hour % 12;
    if (hour12 == 0) return 12;
    return hour12;
  }
}
