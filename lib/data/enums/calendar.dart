enum Weekday {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  static List<Weekday> get orderedWeekdays => [
    sunday,
    monday,
    tuesday,
    wednesday,
    thursday,
    friday,
    saturday,
  ];

  String get oneChar => name[0];
  String get threeChar => name.substring(0, 3);
}

enum Month {
  january,
  february,
  march,
  april,
  may,
  june,
  july,
  august,
  september,
  october,
  november,
  december;

  static List<Month> get orderedMonths => [
    january,
    february,
    march,
    april,
    may,
    june,
    july,
    august,
    september,
    october,
    november,
    december,
  ];

  String get oneChar => name[0];
  String get threeChar => name.substring(0, 3);
}
