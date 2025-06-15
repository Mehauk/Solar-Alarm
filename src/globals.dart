import 'package:solar_alarm/models/alarm.dart';
import 'package:solar_alarm/models/prayers.dart';
import 'package:solar_alarm/state_management/observable.dart';

final prayerTimingsObservable = Observable<Prayers?>(null);
final currentPrayerObservable = Observable<Prayer?>(null);

final alarmsObservable = Observable<List<Alarm>>(
  [],
  modify: (data) => data..sort((a, b) => a.name.compareTo(b.name)),
);
