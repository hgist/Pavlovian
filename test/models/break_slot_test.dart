// Unit tests for the data model.
//
// Pure Dart tests — they don't need a Flutter engine or an emulator.
// Run with:  flutter test
//
// For C/Java programmers: this is JUnit-style. `group()` is like
// @Nested, `test()` is @Test, `expect()` is assertThat().

import 'package:flutter_test/flutter_test.dart';
import 'package:pavlovian/models/app_settings.dart';
import 'package:pavlovian/models/break_time.dart';
import 'package:pavlovian/models/weekday.dart';

void main() {

  // ── BreakTime ────────────────────────────────────────────────────
  group('BreakTime', () {
    test('formats HH:MM with zero-padding', () {
      expect(const BreakTime(9, 5).toDisplay(), '09:05');
      expect(const BreakTime(10, 0).toDisplay(), '10:00');
      expect(const BreakTime(15, 30).toDisplay(), '15:30');
    });

    test('parses HH:MM strings', () {
      expect(BreakTime.parse('10:00'), const BreakTime(10, 0));
      expect(BreakTime.parse('12:30'), const BreakTime(12, 30));
    });

    test('rejects malformed strings', () {
      expect(() => BreakTime.parse('not-a-time'), throwsFormatException);
    });

    test('compares by chronological order', () {
      expect(const BreakTime(10, 0).compareTo(const BreakTime(12, 30)),
          lessThan(0));
      expect(const BreakTime(15, 0).compareTo(const BreakTime(10, 0)),
          greaterThan(0));
    });

    test('value equality (not reference)', () {
      expect(const BreakTime(10, 0) == const BreakTime(10, 0), true);
      expect(const BreakTime(10, 0) == const BreakTime(10, 1), false);
    });

    test('roundedToNearest5 snaps to 5-min steps', () {
      expect(const BreakTime(10, 0).roundedToNearest5(),
          const BreakTime(10, 0));
      expect(const BreakTime(10, 2).roundedToNearest5(),
          const BreakTime(10, 0));   // down
      expect(const BreakTime(10, 3).roundedToNearest5(),
          const BreakTime(10, 5));   // up
      expect(const BreakTime(10, 27).roundedToNearest5(),
          const BreakTime(10, 25));
      expect(const BreakTime(10, 28).roundedToNearest5(),
          const BreakTime(10, 30));
    });

    test('roundedToNearest5 wraps past 60', () {
      expect(const BreakTime(10, 58).roundedToNearest5(),
          const BreakTime(11, 0));
      expect(const BreakTime(23, 58).roundedToNearest5(),
          const BreakTime(0, 0));    // midnight wrap
    });
  });

  // ── Weekday ──────────────────────────────────────────────────────
  group('Weekday', () {
    test('all 7 days are working (Sat now configurable too)', () {
      for (final d in Weekday.values) {
        expect(d.isWorking, true, reason: '$d should be working');
      }
    });

    test('fromDateTime maps every weekday correctly', () {
      // Pick known dates that we know the weekday for.
      // 2026-01-04 is a Sunday.
      expect(Weekday.fromDateTime(DateTime(2026, 1, 4)), Weekday.sun);
      expect(Weekday.fromDateTime(DateTime(2026, 1, 5)), Weekday.mon);
      expect(Weekday.fromDateTime(DateTime(2026, 1, 9)), Weekday.fri);
    });
  });

  // ── AppSettings.defaults() — matches CLAUDE.md spec ──────────────
  group('AppSettings.defaults', () {
    final defaults = AppSettings.defaults();

    test('has exactly three break slots', () {
      expect(defaults.slots.length, 3);
    });

    test('slot labels in correct order', () {
      expect(defaults.slots[0].label, 'Morning Break');
      expect(defaults.slots[1].label, 'Lunch Break');
      expect(defaults.slots[2].label, 'Afternoon Break');
    });

    test('default times match spec (10:00 / 12:30 / 15:00)', () {
      expect(defaults.slots[0].time.toDisplay(), '10:00');
      expect(defaults.slots[1].time.toDisplay(), '12:30');
      expect(defaults.slots[2].time.toDisplay(), '15:00');
    });

    test('default durations match spec (20 / 45 / 20)', () {
      expect(defaults.slots[0].durationMinutes, 20);
      expect(defaults.slots[1].durationMinutes, 45);
      expect(defaults.slots[2].durationMinutes, 20);
    });

    test('all slots default to the factory default sound', () {
      expect(
        defaults.slots.every((s) => s.soundName == kDefaultSoundName),
        true,
      );
    });

    test('all slots enabled by default', () {
      expect(defaults.slots.every((s) => s.enabled), true);
    });

    test('Sun-Thu default ON, Fri / Sat default OFF', () {
      const onByDefault = {
        Weekday.sun,
        Weekday.mon,
        Weekday.tue,
        Weekday.wed,
        Weekday.thu,
      };
      for (final d in Weekday.values) {
        expect(defaults.isDayEnabled(d), onByDefault.contains(d),
            reason: '$d should default to ${onByDefault.contains(d)}');
      }
    });

    test('globalEnabled on, vibrate on, flashLed off', () {
      expect(defaults.globalEnabled, true);
      expect(defaults.vibrate, true);
      expect(defaults.flashLed, false);
    });
  });

  // ── willFire() — the three-level enable hierarchy ────────────────
  group('AppSettings.willFire (enable hierarchy)', () {
    final settings = AppSettings.defaults();
    final slot = settings.slots[0]; // Morning Break

    test('all three layers ON → fires', () {
      expect(settings.willFire(Weekday.mon, slot), true);
    });

    test('global OFF → does not fire', () {
      final off = settings.copyWith(globalEnabled: false);
      expect(off.willFire(Weekday.mon, slot), false);
    });

    test('day OFF → does not fire that day', () {
      final monOff = settings.copyWith(
        perDayEnabled: {...settings.perDayEnabled, Weekday.mon: false},
      );
      expect(monOff.willFire(Weekday.mon, slot), false);
      // ... but still fires on other days
      expect(monOff.willFire(Weekday.tue, slot), true);
    });

    test('per-slot OFF → does not fire any day', () {
      final disabledSlot = slot.copyWith(enabled: false);
      final s = settings.withUpdatedSlot(disabledSlot);
      for (final day in [Weekday.sun, Weekday.mon, Weekday.thu]) {
        expect(s.willFire(day, disabledSlot), false);
      }
    });

    test('Sun-Thu fire when all three layers ON; Fri/Sat stay off', () {
      // Per the v1.5.20 defaults, Fri/Sat are OFF out of the box so
      // willFire returns false for them even when global + slot are ON.
      const offByDefault = {Weekday.fri, Weekday.sat};
      for (final d in Weekday.values) {
        expect(settings.willFire(d, slot), !offByDefault.contains(d),
            reason:
                offByDefault.contains(d) ? '$d off by default' : '$d should fire');
      }
    });
  });

  // ── copyWith / withUpdatedSlot — immutability ────────────────────
  group('copyWith / immutability', () {
    test('BreakSlot.copyWith updates only what was passed', () {
      final original = AppSettings.defaults().slots[0];
      final updated = original.copyWith(enabled: false);
      // original unchanged
      expect(original.enabled, true);
      // updated has the change
      expect(updated.enabled, false);
      // other fields preserved
      expect(updated.label, original.label);
      expect(updated.time, original.time);
      expect(updated.durationMinutes, original.durationMinutes);
      expect(updated.id, original.id);
    });

    test('AppSettings.withUpdatedSlot replaces only the matching id', () {
      final settings = AppSettings.defaults();
      final disabledLunch = settings.slots[1].copyWith(enabled: false);
      final updated = settings.withUpdatedSlot(disabledLunch);
      expect(updated.slots[0].enabled, true);  // morning untouched
      expect(updated.slots[1].enabled, false); // lunch flipped
      expect(updated.slots[2].enabled, true);  // afternoon untouched
      // original settings unchanged
      expect(settings.slots[1].enabled, true);
    });

    test('enabledSlotCount reflects current state', () {
      final settings = AppSettings.defaults();
      expect(settings.enabledSlotCount, 3);
      final oneOff = settings.withUpdatedSlot(
        settings.slots[1].copyWith(enabled: false),
      );
      expect(oneOff.enabledSlotCount, 2);
    });
  });
}
