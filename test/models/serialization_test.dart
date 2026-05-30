// JSON serialization round-trip tests.
//
// Verifies that toJson() → jsonEncode → jsonDecode → fromJson()
// produces an equivalent AppSettings (and the nested objects within).
// Critical for SharedPreferences persistence in Step 7.

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:pavlovian/models/app_settings.dart';
import 'package:pavlovian/models/break_slot.dart';
import 'package:pavlovian/models/break_time.dart';
import 'package:pavlovian/models/weekday.dart';

void main() {
  group('BreakTime JSON', () {
    test('round-trips through JSON', () {
      const original = BreakTime(12, 30);
      final json = jsonEncode(original.toJson());
      final restored = BreakTime.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );
      expect(restored, original);
    });
  });

  group('BreakSlot JSON', () {
    test('round-trips through JSON', () {
      const original = BreakSlot(
        id: 2,
        label: 'Lunch Break',
        time: BreakTime(12, 30),
        durationMinutes: 45,
        soundName: 'Chime',
        enabled: false,
      );
      final json = jsonEncode(original.toJson());
      final restored = BreakSlot.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );
      expect(restored, original);
    });
  });

  group('AppSettings JSON', () {
    test('defaults round-trip through JSON', () {
      final original = AppSettings.defaults();
      final json = jsonEncode(original.toJson());
      final restored = AppSettings.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );

      expect(restored.globalEnabled, original.globalEnabled);
      expect(restored.vibrate, original.vibrate);
      expect(restored.flashLed, original.flashLed);
      expect(restored.slots.length, original.slots.length);
      for (var i = 0; i < original.slots.length; i++) {
        expect(restored.slots[i], original.slots[i]);
      }
      expect(restored.perDayEnabled, original.perDayEnabled);
    });

    test('preserves mutated state through round-trip', () {
      final base = AppSettings.defaults();
      final mutated = base
          .copyWith(globalEnabled: false, flashLed: true)
          .withUpdatedSlot(base.slots[1].copyWith(enabled: false));

      final json = jsonEncode(mutated.toJson());
      final restored = AppSettings.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );

      expect(restored.globalEnabled, false);
      expect(restored.flashLed, true);
      expect(restored.slots[1].enabled, false);
      expect(restored.slots[0].enabled, true);
      expect(restored.slots[2].enabled, true);
    });

    test('encodes Weekday keys as their enum name', () {
      final json = AppSettings.defaults().toJson();
      final dayMap = json['perDayEnabled'] as Map<String, dynamic>;
      expect(dayMap.containsKey('sun'), true);
      expect(dayMap.containsKey('mon'), true);
      expect(dayMap.containsKey('thu'), true);
      expect(dayMap['mon'], true);
    });

    test('includes version field', () {
      final json = AppSettings.defaults().toJson();
      expect(json['version'], AppSettings.storageVersion);
    });

    test('decodes per-day map back to Weekday keys', () {
      final json = AppSettings.defaults().toJson();
      final restored = AppSettings.fromJson(json);
      for (final d in Weekday.values) {
        expect(restored.perDayEnabled[d], true, reason: '$d in map');
      }
    });
  });
}
