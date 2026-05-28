// Top-level immutable snapshot of all user-configurable state.
//
// The Riverpod state we'll set up in Phase 3 will hold an AppSettings
// and notify listeners whenever it changes. Updates always go via
// copyWith() — never mutate fields in place.

import 'break_slot.dart';
import 'break_time.dart';
import 'weekday.dart';

/// Default alert sound — applied to every slot on first install and
/// on "Reset All to Defaults".
const String kDefaultSoundName = 'Chime';

class AppSettings {
  /// Layer 1 of the enable hierarchy — the global ALL pill switch.
  /// When false, nothing fires regardless of other settings.
  final bool globalEnabled;

  /// Layer 2 — per-day master switches. Keyed by every Weekday so the
  /// map is complete, but only Sun–Fri can ever be true (Sat is
  /// permanently off — enforced by isDayEnabled() below).
  final Map<Weekday, bool> perDayEnabled;

  /// The three break slots (Layer 3 enable lives inside each slot).
  final List<BreakSlot> slots;

  /// Settings-screen toggles.
  final bool vibrate;
  final bool flashLed;

  const AppSettings({
    required this.globalEnabled,
    required this.perDayEnabled,
    required this.slots,
    required this.vibrate,
    required this.flashLed,
  });

  /// Factory defaults — exact spec from CLAUDE.md.
  /// Used on first install and after "Reset All to Defaults".
  factory AppSettings.defaults() {
    return AppSettings(
      globalEnabled: true,
      perDayEnabled: const {
        Weekday.sun: true,
        Weekday.mon: true,
        Weekday.tue: true,
        Weekday.wed: true,
        Weekday.thu: true,
        Weekday.fri: true,
        // Sat intentionally omitted — it's always off.
      },
      slots: const [
        BreakSlot(
          id: 1,
          label: 'Morning Break',
          time: BreakTime(10, 0),
          durationMinutes: 20,
          soundName: kDefaultSoundName,
        ),
        BreakSlot(
          id: 2,
          label: 'Lunch Break',
          time: BreakTime(12, 30),
          durationMinutes: 45,
          soundName: kDefaultSoundName,
        ),
        BreakSlot(
          id: 3,
          label: 'Afternoon Break',
          time: BreakTime(15, 0),
          durationMinutes: 20,
          soundName: kDefaultSoundName,
        ),
      ],
      vibrate: true,
      flashLed: false,
    );
  }

  AppSettings copyWith({
    bool? globalEnabled,
    Map<Weekday, bool>? perDayEnabled,
    List<BreakSlot>? slots,
    bool? vibrate,
    bool? flashLed,
  }) {
    return AppSettings(
      globalEnabled: globalEnabled ?? this.globalEnabled,
      perDayEnabled: perDayEnabled ?? this.perDayEnabled,
      slots: slots ?? this.slots,
      vibrate: vibrate ?? this.vibrate,
      flashLed: flashLed ?? this.flashLed,
    );
  }

  /// Convenience: replace a single slot (identified by id) and return
  /// a fresh AppSettings. Saves callers from doing list-replace by hand.
  AppSettings withUpdatedSlot(BreakSlot updated) {
    return copyWith(
      slots: slots
          .map((s) => s.id == updated.id ? updated : s)
          .toList(growable: false),
    );
  }

  /// Number of slots whose per-timer checkbox is currently on.
  int get enabledSlotCount => slots.where((s) => s.enabled).length;

  /// Layer 2 + the Saturday hard-exclusion rolled into one check.
  /// A working day absent from the map defaults to ON — so existing
  /// installs (saved before Friday became a working day) get Friday
  /// enabled automatically without a settings reset.
  bool isDayEnabled(Weekday day) =>
      day.isWorking && (perDayEnabled[day] ?? true);

  /// True when ALL three layers of the enable hierarchy are ON for the
  /// given day & slot — i.e. this slot will actually fire that day.
  bool willFire(Weekday day, BreakSlot slot) =>
      globalEnabled && isDayEnabled(day) && slot.enabled;

  // ── JSON serialization (Step 7) ───────────────────────────────────
  // The `version` field lets future schema changes detect old data
  // and migrate or discard it gracefully.
  static const int storageVersion = 1;

  Map<String, dynamic> toJson() => {
        'version': storageVersion,
        'globalEnabled': globalEnabled,
        // Weekday isn't a string natively, so encode using enum's `.name`
        'perDayEnabled': {
          for (final entry in perDayEnabled.entries)
            entry.key.name: entry.value,
        },
        'slots': slots.map((s) => s.toJson()).toList(),
        'vibrate': vibrate,
        'flashLed': flashLed,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final rawDays = json['perDayEnabled'] as Map<String, dynamic>;
    final dayMap = <Weekday, bool>{};
    for (final entry in rawDays.entries) {
      final day = Weekday.values.firstWhere((d) => d.name == entry.key);
      dayMap[day] = entry.value as bool;
    }
    final slotsList = (json['slots'] as List)
        .map((s) => BreakSlot.fromJson(s as Map<String, dynamic>))
        .toList(growable: false);
    return AppSettings(
      globalEnabled: json['globalEnabled'] as bool,
      perDayEnabled: dayMap,
      slots: slotsList,
      vibrate: json['vibrate'] as bool,
      flashLed: json['flashLed'] as bool,
    );
  }
}
