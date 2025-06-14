import 'package:solar_alarm/models/alarm.dart';
import 'package:solar_alarm/models/prayers.dart';
import 'package:solar_alarm/state_management/observer.dart';

final prayerTimingsObserver = Observer<Prayers?>(null);
final currentPrayerObserver = Observer<Prayer?>(null);
final alarmsObserver = Observer<List<Alarm>>(
  [],
  modify: (data) => data..sort((a, b) => a.name.compareTo(b.name)),
);
