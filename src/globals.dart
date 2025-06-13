import 'package:solar_alarm/models/prayers.dart';
import 'package:solar_alarm/state_management/observer.dart';

final prayerTimingsObserver = Observer<PrayerTimings?>(null);
final currentPrayerObserver = Observer<Prayer?>(null);
