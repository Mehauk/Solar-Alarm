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

extension on String {
  String get _capitalized {
    if (length <= 1) return toUpperCase();
    return this[0].toUpperCase() + substring(1);
  }
}

class Prayers {
  final Map<Prayer, DateTime> _times;

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

  static List<Prayer> get actual => [
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

  Prayers._(this._times);

  factory Prayers(Map<dynamic, dynamic> input) {
    Map<Prayer, DateTime> times = {};

    for (var prayer in _orderedPrayers) {
      times[prayer] = DateTime.fromMillisecondsSinceEpoch(
        input[prayer.capitalizedName],
      );
    }

    final prayers = Prayers._(times);
    assert(prayers.ordered.length == orderedPrayers.length);
    return prayers;
  }

  @override
  bool operator ==(Object other) {
    return other is Prayers && other.ordered == ordered;
  }

  @override
  int get hashCode => ordered.hashCode;
}
