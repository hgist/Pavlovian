// Enum for days of the week.
//
// All 7 days are now "working" — each can be independently
// toggled on/off via the day-master checkbox. `isWorking` is
// kept as a hook for any future hard-exclusion logic but
// currently returns true for every day.
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

  /// All 7 days are configurable. Kept as a hook for future
  /// per-day hard-exclusion rules; always true for now.
  bool get isWorking => true;

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
