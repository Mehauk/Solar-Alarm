import 'package:solar_alarm/utils/result.dart';

import '../models/prayers.dart';
import '../services/log_service.dart';
import '../services/platform_service.dart';

class PrayerRepository {
  final Invoker _platformInvoker;
  final Logger _logger;

  const PrayerRepository({
    required Invoker platformInvoker,
    required Logger logger,
  }) : _platformInvoker = platformInvoker,
       _logger = logger;

  Future<Result<Prayers>> getPrayers() async {
    final prayers = await Result.attemptAsync(() async {
      return Prayers(await _platformInvoker.invoke('getPrayerTimes'));
    });
    _logger.log('PlatformChannel - getPrayers $prayers');
    return prayers;
  }

  Future<Result<void>> updatePrayerSettings(
    Prayer prayer,
    PrayerAlarmStatus status,
  ) async {
    return await Result.attemptAsync(() async {
      await _platformInvoker.invoke('updatePrayerSetting', {
        'name': prayer.capitalizedName,
        'status': status.name,
      });
      _logger.log(
        'PlatformChannel - updatePrayerSetting ${prayer.name} $status',
      );
    });
  }
}
