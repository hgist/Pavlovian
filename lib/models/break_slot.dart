// One configurable break in the day — time, length, label, sound, enabled.
//
// Pure data — no Flutter imports, no business logic. ViewModels in
// `lib/viewmodels/` will hold collections of these and decide when
// to fire notifications based on their state.
//
// Note: `running` (countdown state) and `remainingSeconds` are NOT
// in this model. They belong to a separate transient state object
// we'll add in Step 13, because they're runtime-only and shouldn't
// be persisted.

import 'break_time.dart';

/// Sentinel for `copyWith` parameters where we need to distinguish
/// "not passed" from "passed as null" (because soundUri = null is a
/// meaningful state — meaning "use the bundled sound").
const Object _undefined = Object();

class BreakSlot {
  /// Stable identifier (1, 2, 3) — matches the slot number badge in the UI
  /// and is used as the Android notification-channel suffix later.
  final int id;

  /// Human-readable label, e.g. "Morning Break".
  final String label;

  /// Wall-clock time the alert should fire.
  final BreakTime time;

  /// How long the break lasts — used for the end-of-break countdown
  /// in Step 13. Stored as integer minutes; UI enforces 5-min steps.
  final int durationMinutes;

  /// Display name of the sound, e.g. "Chime" or "Spaceline".
  /// For bundled sounds (Chime/Bell/Ping/Soft) this is also used as
  /// the Android raw-resource lookup (lowercased). For system-picked
  /// sounds the actual data is in [soundUri].
  final String soundName;

  /// Optional `content://...` URI when the user picked a system
  /// ringtone (e.g. Samsung's Spaceline). `null` means the sound is
  /// one of our bundled assets and [soundName] is used directly.
  final String? soundUri;

  /// Per-slot master switch — disables this slot across the whole week.
  /// Layer 3 of the three-level enable hierarchy.
  final bool enabled;

  const BreakSlot({
    required this.id,
    required this.label,
    required this.time,
    required this.durationMinutes,
    required this.soundName,
    this.soundUri,
    this.enabled = true,
  });

  /// Returns a new BreakSlot with the supplied fields replaced.
  /// Idiomatic Dart pattern for immutable state updates — used heavily
  /// by Riverpod in Step 6.
  BreakSlot copyWith({
    String? label,
    BreakTime? time,
    int? durationMinutes,
    String? soundName,
    Object? soundUri = _undefined,
    bool? enabled,
  }) {
    return BreakSlot(
      id: id, // id never changes
      label: label ?? this.label,
      time: time ?? this.time,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      soundName: soundName ?? this.soundName,
      soundUri: identical(soundUri, _undefined)
          ? this.soundUri
          : soundUri as String?,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BreakSlot &&
          other.id == id &&
          other.label == label &&
          other.time == time &&
          other.durationMinutes == durationMinutes &&
          other.soundName == soundName &&
          other.enabled == enabled;

  @override
  int get hashCode =>
      Object.hash(id, label, time, durationMinutes, soundName, enabled);

  @override
  String toString() =>
      'BreakSlot(#$id "$label" @ ${time.toDisplay()}, '
      '${durationMinutes}min, sound=$soundName, enabled=$enabled)';

  // ── JSON serialization (Step 7) ───────────────────────────────────
  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'time': time.toJson(),
        'durationMinutes': durationMinutes,
        'soundName': soundName,
        if (soundUri != null) 'soundUri': soundUri,
        'enabled': enabled,
      };

  factory BreakSlot.fromJson(Map<String, dynamic> json) => BreakSlot(
        id: json['id'] as int,
        label: json['label'] as String,
        time: BreakTime.fromJson(json['time'] as Map<String, dynamic>),
        durationMinutes: json['durationMinutes'] as int,
        soundName: json['soundName'] as String,
        soundUri: json['soundUri'] as String?,
        enabled: json['enabled'] as bool,
      );
}
