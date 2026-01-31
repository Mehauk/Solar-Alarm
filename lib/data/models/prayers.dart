import 'package:jni/jni.dart';

import '../../utils/mixins.dart';

enum Prayer {
  fajr,
  sunrise,
  dhuhr,
  asr,
  maghrib,
  isha,
  midnight;

  String get capitalizedName => name._capitalized;
}

enum PrayerAlarmStatus with Toggleable<PrayerAlarmStatus> {
  disabled,
  vibrate,
  sound;

  @override
  PrayerAlarmStatus get me => this;

  @override
  List<PrayerAlarmStatus> get ordered => values;

  static PrayerAlarmStatus fromName(String name) {
    return PrayerAlarmStatus.values.firstWhere((v) => v.name == name);
  }
}

extension on String {
  String get _capitalized {
    if (length <= 1) return toUpperCase();
    return this[0].toUpperCase() + substring(1);
  }
}

class Prayers {
  final Map<Prayer, DateTime> _times;
  final Map<Prayer, PrayerAlarmStatus> statuses;

  DateTime get fajr => _times[Prayer.fajr]!;
  DateTime get sunrise => _times[Prayer.sunrise]!;
  DateTime get dhuhr => _times[Prayer.dhuhr]!;
  DateTime get asr => _times[Prayer.asr]!;
  DateTime get maghrib => _times[Prayer.maghrib]!;
  DateTime get isha => _times[Prayer.isha]!;

  List<DateTime> get ordered => [
    fajr,
    sunrise,
    dhuhr,
    asr,
    maghrib,
    isha,
    midnight,
  ];

  static List<Prayer> get _actualPrayers => [
    Prayer.fajr,
    Prayer.dhuhr,
    Prayer.asr,
    Prayer.maghrib,
    Prayer.isha,
  ];

  static List<Prayer> get _orderedPrayers => [
    Prayer.fajr,
    Prayer.sunrise,
    Prayer.dhuhr,
    Prayer.asr,
    Prayer.maghrib,
    Prayer.isha,
  ];

  static List<Prayer> get orderedPrayers => [
    ..._orderedPrayers,
    Prayer.midnight,
  ];

  DateTime get sunset => maghrib;
  DateTime get midnight => dhuhr.add(const Duration(hours: 12));

  Prayer prayerAtTime(DateTime time) {
    final now = time;
    Prayer? currentPrayer;

    for (var i = 0; i < ordered.length; i++) {
      final prayer = orderedPrayers[i];
      final time = ordered[i];

      if (now.isBefore(time)) {
        break;
      }
      currentPrayer = prayer;
    }

    if (currentPrayer == null) {
      if (midnight.subtract(const Duration(days: 1)).isAfter(now)) {
        currentPrayer = Prayer.isha;
      } else {
        currentPrayer = Prayer.midnight;
      }
    }

    return currentPrayer;
  }

  Prayers._(this._times, this.statuses);

  factory Prayers.fromJMap(JMap<JString, JObject> input) {
    Map<Prayer, DateTime> times = {};
    Map<Prayer, PrayerAlarmStatus> statuses = {};

    for (var prayer in Prayers._orderedPrayers) {
      times[prayer] = DateTime.fromMillisecondsSinceEpoch(
        input[prayer.capitalizedName.toJString()]!.as(JLong.type).longValue(),
      );
    }

    for (var prayer in Prayers._actualPrayers) {
      statuses[prayer] = PrayerAlarmStatus.fromName(
        (input["__statuses__".toJString()]!.as(
              JMap.type(JString.type, JString.type),
            ))[prayer.capitalizedName.toJString()]?.toDartString() ??
            PrayerAlarmStatus.disabled.name,
      );
    }

    final prayers = Prayers._(times, statuses);
    assert(prayers.ordered.length == orderedPrayers.length);
    return prayers;
  }

  @override
  bool operator ==(Object other) {
    return other is Prayers &&
        other.ordered == ordered &&
        statuses == other.statuses;
  }

  @override
  int get hashCode => Object.hash(ordered.hashCode, statuses.hashCode);
}
