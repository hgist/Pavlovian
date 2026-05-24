// Unit tests for SettingsNotifier — the Riverpod ViewModel that holds
// AppSettings and exposes the three toggle methods.
//
// ProviderContainer is the test-time equivalent of ProviderScope.
// Always `addTearDown(container.dispose)` to release listeners.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pavlovian/models/weekday.dart';
import 'package:pavlovian/viewmodels/settings_provider.dart';

void main() {
  // Helper: build a fresh container per test.
  ProviderContainer makeContainer() {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    return c;
  }

  group('SettingsNotifier', () {
    test('starts with factory defaults', () {
      final c = makeContainer();
      final s = c.read(settingsProvider);
      expect(s.globalEnabled, true);
      expect(s.slots.length, 3);
      expect(s.slots[0].label, 'Morning Break');
      expect(s.slots.every((slot) => slot.enabled), true);
    });

    test('toggleGlobal flips globalEnabled', () {
      final c = makeContainer();
      final n = c.read(settingsProvider.notifier);
      expect(c.read(settingsProvider).globalEnabled, true);
      n.toggleGlobal();
      expect(c.read(settingsProvider).globalEnabled, false);
      n.toggleGlobal();
      expect(c.read(settingsProvider).globalEnabled, true);
    });

    test('toggleDay flips a working-day master', () {
      final c = makeContainer();
      final n = c.read(settingsProvider.notifier);
      expect(c.read(settingsProvider).isDayEnabled(Weekday.mon), true);
      n.toggleDay(Weekday.mon);
      expect(c.read(settingsProvider).isDayEnabled(Weekday.mon), false);
      // Other days unaffected
      expect(c.read(settingsProvider).isDayEnabled(Weekday.tue), true);
    });

    test('toggleDay is a no-op for Fri & Sat', () {
      final c = makeContainer();
      final n = c.read(settingsProvider.notifier);
      final before = c.read(settingsProvider);
      n.toggleDay(Weekday.fri);
      n.toggleDay(Weekday.sat);
      // Settings unchanged — perDayEnabled map identical
      expect(c.read(settingsProvider).perDayEnabled,
          equals(before.perDayEnabled));
      // Fri/Sat still report off
      expect(c.read(settingsProvider).isDayEnabled(Weekday.fri), false);
      expect(c.read(settingsProvider).isDayEnabled(Weekday.sat), false);
    });

    test('toggleSlot flips a single slot enable, leaves others', () {
      final c = makeContainer();
      final n = c.read(settingsProvider.notifier);
      // Initially all on
      expect(c.read(settingsProvider).slots[0].enabled, true);
      expect(c.read(settingsProvider).slots[1].enabled, true);
      expect(c.read(settingsProvider).slots[2].enabled, true);

      n.toggleSlot(2); // disable Lunch Break
      expect(c.read(settingsProvider).slots[0].enabled, true);
      expect(c.read(settingsProvider).slots[1].enabled, false);
      expect(c.read(settingsProvider).slots[2].enabled, true);

      n.toggleSlot(2); // back on
      expect(c.read(settingsProvider).slots[1].enabled, true);
    });

    test('enabledSlotCount reflects toggleSlot calls', () {
      final c = makeContainer();
      final n = c.read(settingsProvider.notifier);
      expect(c.read(settingsProvider).enabledSlotCount, 3);
      n.toggleSlot(1);
      expect(c.read(settingsProvider).enabledSlotCount, 2);
      n.toggleSlot(3);
      expect(c.read(settingsProvider).enabledSlotCount, 1);
    });

    test('willFire reflects all three toggles', () {
      final c = makeContainer();
      final n = c.read(settingsProvider.notifier);
      final slot = c.read(settingsProvider).slots[0];
      // Initially fires on Mon
      expect(c.read(settingsProvider).willFire(Weekday.mon, slot), true);
      // Toggle global → off
      n.toggleGlobal();
      expect(c.read(settingsProvider).willFire(Weekday.mon, slot), false);
      n.toggleGlobal(); // back on
      // Toggle Mon → off for Mon only
      n.toggleDay(Weekday.mon);
      expect(c.read(settingsProvider).willFire(Weekday.mon, slot), false);
      expect(c.read(settingsProvider).willFire(Weekday.tue, slot), true);
    });
  });
}
