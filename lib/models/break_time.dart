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

  /// Returns a new BreakTime with the minute rounded to the nearest
  /// multiple of [step]. Wraps over midnight if the rounding crosses
  /// the last allowed step before 24:00.
  ///
  /// Examples with step=5:
  ///   02:23 -> 02:25   (round up)
  ///   02:27 -> 02:25   (round down)
  ///   23:58 -> 00:00   (wraps)
  /// With step=1 the value is unchanged (every minute is already
  /// "on a step boundary").
  BreakTime roundedToNearest(int step) {
    if (step <= 1) return this;
    final rounded = ((minute + step ~/ 2) ~/ step) * step;
    if (rounded >= 60) {
      return BreakTime((hour + 1) % 24, rounded - 60);
    }
    return BreakTime(hour, rounded);
  }

  /// Back-compat alias for the old 5-min-step helper. Now driven by
  /// the global [kTimeGranularityMin] constant in app_settings.dart
  /// so flipping the constant changes behaviour everywhere at once.
  /// Kept as a method so tests written against the old name still pass.
  BreakTime roundedToNearest5() => roundedToNearest(5);

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

  // ── JSON serialization (Step 7) ───────────────────────────────────
  Map<String, dynamic> toJson() => {'hour': hour, 'minute': minute};

  factory BreakTime.fromJson(Map<String, dynamic> json) =>
      BreakTime(json['hour'] as int, json['minute'] as int);
}
