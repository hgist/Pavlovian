// Top-level immutable snapshot of all user-configurable state.
//
// The Riverpod state we'll set up in Phase 3 will hold an AppSettings
// and notify listeners whenever it changes. Updates always go via
// copyWith() — never mutate fields in place.

import 'break_slot.dart';
import 'break_time.dart';
import 'weekday.dart';

/// Default alert sound — applied to every slot on first install and
/// on "Reset All to Defaults". Attribution for the rooster crow goes
/// in the Settings footer (assets/sounds/rooster.mp3).
const String kDefaultSoundName = 'Rooster';

/// Default end-of-break sound — intentionally different from the slot
/// default so users distinguish "break time" vs "break over" by ear.
/// Whimsical cuckoo pairs nicely with the rooster start-of-break.
const String kDefaultEndSoundName = 'Cuckoo';

/// Minute step for slot times and durations. 1 = single-minute precision
/// (useful for testing — quick "fire in 1 min" verification). Raise back
/// to 5 for production once the app graduates from testing.
const int kTimeGranularityMin = 1;

/// Internal sentinel for nullable copyWith parameters (so callers can
/// distinguish "not passed" from "passed as null").
const Object _undefinedSettings = Object();

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

  /// Display name of the sound used by the manual "▶ test" button.
  final String testSoundName;

  /// Optional system-ringtone URI for the test sound. `null` means
  /// the test uses one of our bundled sounds — [testSoundName] is the
  /// resource name then.
  final String? testSoundUri;

  /// Display name of the sound used by the END-OF-BREAK notification
  /// (fired when a countdown started via "▶ start" on a slot card
  /// reaches zero). Kept separate from each slot's [BreakSlot.soundName]
  /// so the "break over" tone can differ from the "break time" tone.
  final String endSoundName;

  /// Optional system-ringtone URI for the end-of-break sound. `null`
  /// means use the bundled resource named by [endSoundName].
  final String? endSoundUri;

  const AppSettings({
    required this.globalEnabled,
    required this.perDayEnabled,
    required this.slots,
    required this.vibrate,
    required this.flashLed,
    required this.testSoundName,
    this.testSoundUri,
    required this.endSoundName,
    this.endSoundUri,
  });

  /// Factory defaults.
  ///
  /// [soundName] becomes the alert sound for ALL slot defaults AND for
  /// the Test notification — they're always in sync. On first install
  /// this is "Chime". On "Reset All to Defaults" the SettingsNotifier
  /// passes the current testSoundName so the user's preferred sound is
  /// preserved across resets.
  factory AppSettings.defaults({String soundName = kDefaultSoundName}) {
    return AppSettings(
      globalEnabled: true,
      perDayEnabled: const {
        Weekday.sun: true,
        Weekday.mon: true,
        Weekday.tue: true,
        Weekday.wed: true,
        Weekday.thu: true,
        Weekday.fri: true,
        Weekday.sat: true,
      },
      slots: [
        BreakSlot(
          id: 1,
          label: 'Morning Break',
          time: const BreakTime(10, 0),
          durationMinutes: 20,
          soundName: soundName,
        ),
        BreakSlot(
          id: 2,
          label: 'Lunch Break',
          time: const BreakTime(12, 30),
          durationMinutes: 45,
          soundName: soundName,
        ),
        BreakSlot(
          id: 3,
          label: 'Afternoon Break',
          time: const BreakTime(15, 0),
          durationMinutes: 20,
          soundName: soundName,
        ),
      ],
      vibrate: true,
      flashLed: false,
      testSoundName: soundName,
      endSoundName: kDefaultEndSoundName,
    );
  }

  AppSettings copyWith({
    bool? globalEnabled,
    Map<Weekday, bool>? perDayEnabled,
    List<BreakSlot>? slots,
    bool? vibrate,
    bool? flashLed,
    String? testSoundName,
    Object? testSoundUri = _undefinedSettings,
    String? endSoundName,
    Object? endSoundUri = _undefinedSettings,
  }) {
    return AppSettings(
      globalEnabled: globalEnabled ?? this.globalEnabled,
      perDayEnabled: perDayEnabled ?? this.perDayEnabled,
      slots: slots ?? this.slots,
      vibrate: vibrate ?? this.vibrate,
      flashLed: flashLed ?? this.flashLed,
      testSoundName: testSoundName ?? this.testSoundName,
      testSoundUri: identical(testSoundUri, _undefinedSettings)
          ? this.testSoundUri
          : testSoundUri as String?,
      endSoundName: endSoundName ?? this.endSoundName,
      endSoundUri: identical(endSoundUri, _undefinedSettings)
          ? this.endSoundUri
          : endSoundUri as String?,
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

  /// True when this day is currently enabled. A day absent from the
  /// persisted map defaults to ON, so existing installs upgrading to
  /// a build that added a new day (Fri, Sat) get it on automatically
  /// without a settings reset.
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
        'testSoundName': testSoundName,
        if (testSoundUri != null) 'testSoundUri': testSoundUri,
        'endSoundName': endSoundName,
        if (endSoundUri != null) 'endSoundUri': endSoundUri,
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
      // Fallback for older installs whose JSON predates testSoundName.
      testSoundName: json['testSoundName'] as String? ?? kDefaultSoundName,
      testSoundUri: json['testSoundUri'] as String?,
      // Fallback for older installs whose JSON predates endSoundName.
      endSoundName: json['endSoundName'] as String? ?? kDefaultEndSoundName,
      endSoundUri: json['endSoundUri'] as String?,
    );
  }
}
