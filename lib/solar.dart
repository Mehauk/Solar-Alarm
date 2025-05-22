import 'dart:math';

DateTime calculateSolarNoon(double latitude, double longitude, int millisNow) {
  // Step 1: Get the day of the year
  final DateTime dateUtc = DateTime.fromMillisecondsSinceEpoch(
    millisNow,
    isUtc: true,
  );
  final dayOfYear =
      DateTime.utc(
        dateUtc.year,
        dateUtc.month,
        dateUtc.day,
      ).difference(DateTime.utc(dateUtc.year, 1, 1)).inDays +
      1;
  print("DAY $dayOfYear");

  // Step 2: Calculate the fractional year in radians
  final gamma = (2 * pi / 365) * (dayOfYear - 1);
  print("gamma $gamma");

  // Step 3: Calculate the Equation of Time (EoT)
  const scalingFactor =
      229.18 / (60 * 24); // ~0.15915, this converts to minutes
  final eqTime =
      60 *
      24 *
      scalingFactor *
      (0.000075 +
          0.001868 * cos(gamma) -
          0.032077 * sin(gamma) -
          0.014615 * cos(2 * gamma) -
          0.040849 * sin(2 * gamma));

  // Step 4: Solar Noon in UTC minutes from midnight
  final solarNoonMinutes = 720 - (4 * longitude) - eqTime;

  // Step 5: Convert minutes to hours, minutes, and seconds
  final hours = solarNoonMinutes ~/ 60;
  final minutes = (solarNoonMinutes % 60).floor();
  final seconds = ((solarNoonMinutes % 1) * 60).round();
  print("HMS: $hours:$minutes:$seconds");

  return DateTime.utc(
    dateUtc.year,
    dateUtc.month,
    dateUtc.day,
    hours,
    minutes,
    seconds,
  );
}
