import 'package:jni/jni.dart';
import 'package:solar_alarm/data/services/jni_bindings.g.dart' as bindings;
import 'package:solar_alarm/utils/result.dart';

import '../models/prayers.dart';

abstract interface class PrayerRepository {
  Result<Prayers> getPrayers();
  Result<void> updatePrayerSettings(Prayer prayer, PrayerAlarmStatus status);
}

class JniPrayerRepository implements PrayerRepository {
  final bindings.Prayer _prayerService;
  JniPrayerRepository(JObject context)
    : _prayerService = bindings.Prayer(context);

  @override
  Result<Prayers> getPrayers() => Result.attempt(() {
    return Prayers(_prayerService.getPrayerTimesFromLocation(null, null));
  });

  @override
  Result<void> updatePrayerSettings(Prayer prayer, PrayerAlarmStatus status) {
    return Result.attempt(() {
      _prayerService.updatePrayerSettings(
        JString.fromString(prayer.name),
        JString.fromString(status.name),
      );
    });
  }
}
