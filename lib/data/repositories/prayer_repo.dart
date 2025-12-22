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

  Future<Prayers?> getPrayers() async {
    final prayers = await _platformInvoker.invoke('getPrayerTimes');
    _logger.log('PlatformChannel - getPrayers $prayers');
    return prayers;
  }

  Future<void> updatePrayerSettings(
    Prayer prayer,
    PrayerAlarmStatus status,
  ) async {
    _logger.log('PlatformChannel - updatePrayerSetting ${prayer.name} $status');
    await _platformInvoker.invoke('updatePrayerSetting', {
      'name': prayer.capitalizedName,
      'status': status.name,
    });
  }
}
