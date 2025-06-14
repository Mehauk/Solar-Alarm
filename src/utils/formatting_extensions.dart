import 'package:flutter/material.dart';
import 'package:solar_alarm/models/calendar.dart';

extension FormatString on String {
  String get capitalized {
    if (length <= 1) return toUpperCase();
    return this[0].toUpperCase() + substring(1);
  }
}

extension FormatDateTime on DateTime {
  (String time, DayPeriod period) get formattedTime {
    final hourInt = this.hour % 12 == 0 ? 12 : this.hour % 12;
    final hour = hourInt.toString().padLeft(2, '0');
    final minute = this.minute.toString().padLeft(2, '0');
    final period = this.hour >= 12 ? DayPeriod.pm : DayPeriod.am;
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

  String get formattedDateWithYear {
    final weekdays =
        Weekday.orderedWeekdays.map((wd) => wd.threeChar.capitalized).toList();

    final months =
        Month.orderedMonths.map((m) => m.threeChar.capitalized).toList();

    final weekday = weekdays[this.weekday % 7];
    final day = this.day.toString().padLeft(2, '0');
    final month = months[this.month - 1];
    final year = this.year;

    return '$weekday, $day $month $year';
  }

  String? get deicticWord {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(year, month, day);

    final difference = target.difference(today).inDays;

    switch (difference) {
      case 0:
        return 'Today';
      case 1:
        return 'Tomorrow';
      case -1:
        return 'Yesterday';
      default:
        return null; // fallback
    }
  }
}

extension FormatTime on TimeOfDay {
  int get hour12 {
    final hour12 = hour % 12;
    if (hour12 == 0) return 12;
    return hour12;
  }
}

extension FormatDayPeriod on DayPeriod {
  String get uname => name.toUpperCase();
}
