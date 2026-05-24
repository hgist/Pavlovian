// Enum for days of the week.
//
// Includes all 7 days so the UI can show Fri/Sat as crossed-out,
// but `isWorking` returns true only for Sun–Thu (the work week
// for this app).
//
// Dart enums can have fields, constructors, and methods — unlike
// Java enums where this is unusual, in Dart it's idiomatic and common.

enum Weekday {
  sun(label: 'Sun', fullName: 'Sunday'),
  mon(label: 'Mon', fullName: 'Monday'),
  tue(label: 'Tue', fullName: 'Tuesday'),
  wed(label: 'Wed', fullName: 'Wednesday'),
  thu(label: 'Thu', fullName: 'Thursday'),
  fri(label: 'Fri', fullName: 'Friday'),
  sat(label: 'Sat', fullName: 'Saturday');

  final String label;     // "Sun"
  final String fullName;  // "Sunday"
  const Weekday({required this.label, required this.fullName});

  /// True for Sun–Thu. Fri & Sat are never working days for this app.
  bool get isWorking => index <= Weekday.thu.index;

  /// Convert a Dart DateTime's weekday (Mon=1, Sun=7) into our enum.
  /// Used in Step 12 to know what day it is when scheduling alarms.
  static Weekday fromDateTime(DateTime dt) {
    switch (dt.weekday) {
      case DateTime.sunday:    return Weekday.sun;
      case DateTime.monday:    return Weekday.mon;
      case DateTime.tuesday:   return Weekday.tue;
      case DateTime.wednesday: return Weekday.wed;
      case DateTime.thursday:  return Weekday.thu;
      case DateTime.friday:    return Weekday.fri;
      case DateTime.saturday:  return Weekday.sat;
      default: throw StateError('Unknown weekday: ${dt.weekday}');
    }
  }
}
