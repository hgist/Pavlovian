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
import 'package:pavlovian/models/app_settings.dart';
import 'package:pavlovian/models/break_slot.dart';
import 'package:pavlovian/models/break_time.dart';
import 'package:pavlovian/models/weekday.dart';
import 'package:pavlovian/services/notification_service.dart';
import 'package:pavlovian/viewmodels/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Test stub — no-ops everything so tests don't touch the platform
/// notifications plugin. Overrides notificationServiceProvider below.
class _StubNotificationService implements NotificationService {
  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  String channelIdFor(BreakSlot slot, bool vibrate, bool flashLed) => 'stub';

  @override
  Future<void> fireTest(BreakSlot slot, bool vibrate, bool flashLed) async {}

  @override
  Future<void> scheduleAll(AppSettings settings) async {}

  @override
  Future<void> scheduleBreakEnd(BreakSlot slot, Weekday day,
      DateTime endTime, bool vibrate, bool flashLed) async {}

  @override
  Future<void> cancelBreakEnd(int slotId, Weekday day) async {}

  // The interface is exposed via `implements`, so any methods we
  // don't reference here just throw — which is fine, tests don't
  // touch them.
  @override
  noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  ProviderContainer makeContainer() {
    final c = ProviderContainer(
      overrides: [
        notificationServiceProvider.overrideWithValue(_StubNotificationService()),
      ],
    );
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

    test('toggleDay works for every day including Sat', () async {
      final c = makeContainer();
      final n = c.read(settingsProvider.notifier);
      await c.read(settingsProvider.future);

      for (final day in Weekday.values) {
        expect(c.read(settingsProvider).value!.isDayEnabled(day), true);
        await n.toggleDay(day);
        expect(c.read(settingsProvider).value!.isDayEnabled(day), false);
        await n.toggleDay(day); // flip back so the next iteration is clean
      }
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
      final c1 = ProviderContainer(overrides: [
        notificationServiceProvider.overrideWithValue(_StubNotificationService()),
      ]);
      final n1 = c1.read(settingsProvider.notifier);
      await c1.read(settingsProvider.future);
      await n1.toggleGlobal();
      expect(c1.read(settingsProvider).value!.globalEnabled, false);
      c1.dispose();

      // Container 2 (fresh — simulates app relaunch): global stays off
      final c2 = ProviderContainer(overrides: [
        notificationServiceProvider.overrideWithValue(_StubNotificationService()),
      ]);
      addTearDown(c2.dispose);
      final loaded = await c2.read(settingsProvider.future);
      expect(loaded.globalEnabled, false);
    });

    test('resetToDefaults wipes persisted state', () async {
      final c1 = ProviderContainer(overrides: [
        notificationServiceProvider.overrideWithValue(_StubNotificationService()),
      ]);
      final n1 = c1.read(settingsProvider.notifier);
      await c1.read(settingsProvider.future);
      await n1.toggleGlobal(); // dirty state
      await n1.resetToDefaults();
      c1.dispose();

      // Fresh container — should see defaults again
      final c2 = ProviderContainer(overrides: [
        notificationServiceProvider.overrideWithValue(_StubNotificationService()),
      ]);
      addTearDown(c2.dispose);
      final loaded = await c2.read(settingsProvider.future);
      expect(loaded.globalEnabled, true);
    });
  });

  // ── Step 9: per-slot field updaters ──────────────────────────────
  group('SettingsNotifier setSlot*', () {
    test('setSlotTime updates time and snaps to nearest 5 min', () async {
      final c = makeContainer();
      final n = c.read(settingsProvider.notifier);
      await c.read(settingsProvider.future);

      // 11:23 → snapped to 11:25
      await n.setSlotTime(1, const BreakTime(11, 23));
      expect(c.read(settingsProvider).value!.slots[0].time,
          const BreakTime(11, 25));

      // 09:02 → 09:00 (round down)
      await n.setSlotTime(1, const BreakTime(9, 2));
      expect(c.read(settingsProvider).value!.slots[0].time,
          const BreakTime(9, 0));
    });

    test('setSlotDuration clamps and rounds to 5-min steps', () async {
      final c = makeContainer();
      final n = c.read(settingsProvider.notifier);
      await c.read(settingsProvider.future);

      // 27 -> 25
      await n.setSlotDuration(1, 27);
      expect(c.read(settingsProvider).value!.slots[0].durationMinutes, 25);

      // 0 -> 5 (clamped)
      await n.setSlotDuration(1, 0);
      expect(c.read(settingsProvider).value!.slots[0].durationMinutes, 5);

      // 1000 -> 240 (clamped)
      await n.setSlotDuration(1, 1000);
      expect(c.read(settingsProvider).value!.slots[0].durationMinutes, 240);
    });

    test('setSlotLabel renames; empty/whitespace ignored', () async {
      final c = makeContainer();
      final n = c.read(settingsProvider.notifier);
      await c.read(settingsProvider.future);

      await n.setSlotLabel(2, 'Lunch & Coffee');
      expect(c.read(settingsProvider).value!.slots[1].label,
          'Lunch & Coffee');

      // Whitespace-only — should be a no-op
      await n.setSlotLabel(2, '   ');
      expect(c.read(settingsProvider).value!.slots[1].label,
          'Lunch & Coffee');
    });

    test('setSlotLabel trims surrounding whitespace', () async {
      final c = makeContainer();
      final n = c.read(settingsProvider.notifier);
      await c.read(settingsProvider.future);

      await n.setSlotLabel(1, '  Morning Coffee  ');
      expect(c.read(settingsProvider).value!.slots[0].label,
          'Morning Coffee');
    });

    test('setSlotSound changes the sound name', () async {
      final c = makeContainer();
      final n = c.read(settingsProvider.notifier);
      await c.read(settingsProvider.future);

      await n.setSlotSound(1, 'Bell');
      expect(c.read(settingsProvider).value!.slots[0].soundName, 'Bell');
      // Other slots untouched
      expect(c.read(settingsProvider).value!.slots[1].soundName, 'Chime');
    });

    test('toggleVibrate flips and persists', () async {
      final c = makeContainer();
      final n = c.read(settingsProvider.notifier);
      await c.read(settingsProvider.future);
      expect(c.read(settingsProvider).value!.vibrate, true);
      await n.toggleVibrate();
      expect(c.read(settingsProvider).value!.vibrate, false);
    });

    test('toggleFlashLed flips and persists', () async {
      final c = makeContainer();
      final n = c.read(settingsProvider.notifier);
      await c.read(settingsProvider.future);
      expect(c.read(settingsProvider).value!.flashLed, false);
      await n.toggleFlashLed();
      expect(c.read(settingsProvider).value!.flashLed, true);
    });

    test('per-slot updates survive container rebuild (persisted)',
        () async {
      // Container 1: rename Morning Break + change Lunch duration
      final c1 = ProviderContainer(overrides: [
        notificationServiceProvider.overrideWithValue(_StubNotificationService()),
      ]);
      final n1 = c1.read(settingsProvider.notifier);
      await c1.read(settingsProvider.future);
      await n1.setSlotLabel(1, 'Stretch break');
      await n1.setSlotDuration(2, 60);
      c1.dispose();

      // Container 2: fresh load — changes still there
      final c2 = ProviderContainer(overrides: [
        notificationServiceProvider.overrideWithValue(_StubNotificationService()),
      ]);
      addTearDown(c2.dispose);
      final loaded = await c2.read(settingsProvider.future);
      expect(loaded.slots[0].label, 'Stretch break');
      expect(loaded.slots[1].durationMinutes, 60);
    });
  });
}
