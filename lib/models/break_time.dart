// A simple value class representing a wall-clock time in 24-hour format.
//
// Pure Dart — no Flutter imports. Lives in `models/` per MVVM layering.
//
// For C/Java programmers: this is the equivalent of a small immutable
// POJO with overridden equals/hashCode/toString. Fields are `final`
// (Dart's equivalent of Java `final`), and the constructor is `const`
// so two BreakTime(10, 0) literals compile to a single shared instance.

class BreakTime implements Comparable<BreakTime> {
  final int hour;    // 0–23
  final int minute;  // 0–59

  const BreakTime(this.hour, this.minute)
      : assert(hour >= 0 && hour < 24, 'hour must be 0–23'),
        assert(minute >= 0 && minute < 60, 'minute must be 0–59');

  /// Parses "HH:MM" (e.g. "10:00", "12:30").
  /// Throws FormatException on bad input.
  factory BreakTime.parse(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) {
      throw FormatException('Expected "HH:MM", got "$hhmm"');
    }
    return BreakTime(int.parse(parts[0]), int.parse(parts[1]));
  }

  /// Returns "HH:MM" with zero-padding (e.g. "09:05", "12:30").
  String toDisplay() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  /// Total minutes since midnight — handy for sorting & duration math.
  int get totalMinutes => hour * 60 + minute;

  @override
  int compareTo(BreakTime other) => totalMinutes - other.totalMinutes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BreakTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() => 'BreakTime(${toDisplay()})';
}
