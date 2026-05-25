// Unit tests for SettingsNotifier — now async (Step 7).
//
// Each test starts with `SharedPreferences.setMockInitialValues({})`
// which gives the prefs plugin an empty in-memory store. The first
// `read(settingsProvider.future)` triggers load(), which returns
// defaults because the store is empty.
//
// `addTearDown(container.dispose)` releases listeners after each test.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pavlovian/models/weekday.dart';
import 'package:pavlovian/viewmodels/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  ProviderContainer makeContainer() {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    return c;
  }

  group('SettingsNotifier (async)', () {
    test('starts with factory defaults when prefs empty', () async {
      final c = makeContainer();
      final s = await c.read(settingsProvider.future);
      expect(s.globalEnabled, true);
      expect(s.slots.length, 3);
      expect(s.slots[0].label, 'Morning Break');
      expect(s.slots.every((slot) => slot.enabled), true);
    });

    test('toggleGlobal flips globalEnabled and persists', () async {
      final c = makeContainer();
      final n = c.read(settingsProvider.notifier);
      // Wait for initial load
      await c.read(settingsProvider.future);

      await n.toggleGlobal();
      expect(c.read(settingsProvider).value!.globalEnabled, false);

      await n.toggleGlobal();
      expect(c.read(settingsProvider).value!.globalEnabled, true);
    });

    test('toggleDay flips a working-day master', () async {
      final c = makeContainer();
      final n = c.read(settingsProvider.notifier);
      await c.read(settingsProvider.future);

      expect(c.read(settingsProvider).value!.isDayEnabled(Weekday.mon), true);
      await n.toggleDay(Weekday.mon);
      expect(c.read(settingsProvider).value!.isDayEnabled(Weekday.mon), false);
      // Other days unaffected
      expect(c.read(settingsProvider).value!.isDayEnabled(Weekday.tue), true);
    });

    test('toggleDay is a no-op for Fri & Sat', () async {
      final c = makeContainer();
      final n = c.read(settingsProvider.notifier);
      final before = await c.read(settingsProvider.future);

      await n.toggleDay(Weekday.fri);
      await n.toggleDay(Weekday.sat);

      expect(c.read(settingsProvider).value!.perDayEnabled,
          equals(before.perDayEnabled));
      expect(c.read(settingsProvider).value!.isDayEnabled(Weekday.fri), false);
      expect(c.read(settingsProvider).value!.isDayEnabled(Weekday.sat), false);
    });

    test('toggleSlot flips a single slot enable, leaves others', () async {
      final c = makeContainer();
      final n = c.read(settingsProvider.notifier);
      await c.read(settingsProvider.future);

      await n.toggleSlot(2);
      final s = c.read(settingsProvider).value!;
      expect(s.slots[0].enabled, true);
      expect(s.slots[1].enabled, false);
      expect(s.slots[2].enabled, true);

      await n.toggleSlot(2);
      expect(c.read(settingsProvider).value!.slots[1].enabled, true);
    });

    test('changes survive a container rebuild (true persistence)',
        () async {
      // Container 1: turn global off
      final c1 = ProviderContainer();
      final n1 = c1.read(settingsProvider.notifier);
      await c1.read(settingsProvider.future);
      await n1.toggleGlobal();
      expect(c1.read(settingsProvider).value!.globalEnabled, false);
      c1.dispose();

      // Container 2 (fresh — simulates app relaunch): global stays off
      final c2 = ProviderContainer();
      addTearDown(c2.dispose);
      final loaded = await c2.read(settingsProvider.future);
      expect(loaded.globalEnabled, false);
    });

    test('resetToDefaults wipes persisted state', () async {
      final c1 = ProviderContainer();
      final n1 = c1.read(settingsProvider.notifier);
      await c1.read(settingsProvider.future);
      await n1.toggleGlobal(); // dirty state
      await n1.resetToDefaults();
      c1.dispose();

      // Fresh container — should see defaults again
      final c2 = ProviderContainer();
      addTearDown(c2.dispose);
      final loaded = await c2.read(settingsProvider.future);
      expect(loaded.globalEnabled, true);
    });
  });
}
