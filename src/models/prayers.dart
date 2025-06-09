enum Prayer { fajr, sunrise, dhuhr, asr, maghrib, isha, midnight }

class Prayers {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  List<DateTime> get ordered => [
    fajr,
    sunrise,
    dhuhr,
    asr,
    maghrib,
    isha,
    midnight,
  ];
  List<Prayer> get orderedPrayers => [
    Prayer.fajr,
    Prayer.sunrise,
    Prayer.dhuhr,
    Prayer.asr,
    Prayer.maghrib,
    Prayer.isha,
    Prayer.midnight,
  ];

  DateTime get sunset => maghrib;
  DateTime get midnight => dhuhr.add(const Duration(hours: 12));

  Prayers(Map<dynamic, dynamic> input)
    : fajr = DateTime.fromMillisecondsSinceEpoch(input["Fajr"]),
      sunrise = DateTime.fromMillisecondsSinceEpoch(input["Sunrise"]),
      dhuhr = DateTime.fromMillisecondsSinceEpoch(input["Dhuhr"]),
      asr = DateTime.fromMillisecondsSinceEpoch(input["Asr"]),
      maghrib = DateTime.fromMillisecondsSinceEpoch(input["Maghrib"]),
      isha = DateTime.fromMillisecondsSinceEpoch(input["Isha"]) {
    assert(ordered.length == orderedPrayers.length);
  }

  @override
  bool operator ==(Object other) {
    return other is Prayers && other.ordered == ordered;
  }

  @override
  int get hashCode => ordered.hashCode;
}
