// The single source of truth for all user-configurable app state.
//
// Step 7: now an AsyncNotifier — settings live on disk and are loaded
// asynchronously on first access via SettingsRepository.
//
// State flow:
//   App start → build() runs → reads from SharedPreferences → state
//   becomes AsyncData(AppSettings) → UI rebuilds.
//
//   User toggles something → notifier mutates state in memory AND
//   awaits repository.save() → state on disk now matches UI.
//
// For C/Java programmers:
//   AsyncNotifier ≈ a class whose state is a Future-like wrapper
//   (AsyncValue<T> = loading | data(T) | error). Widgets read
//   `state.value` (the AppSettings, or null while loading).

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_settings.dart';
import '../models/break_time.dart';
import '../models/weekday.dart';
import '../services/notification_service.dart';
import '../services/settings_repository.dart';

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  /// Runs once on first read. Returning a Future puts us in the
  /// "loading" state until it completes; result becomes the data.
  /// Disk read is fast (5–20 ms); the visible "branded" moment on
  /// startup is now handled by SplashGate (lib/views/splash_screen.dart).
  @override
  Future<AppSettings> build() async {
    final repo = ref.read(settingsRepositoryProvider);
    final loaded = await repo.load();
    // Schedule everything based on the just-loaded settings. Fire-and-
    // forget so SplashGate doesn't wait on scheduling I/O.
    // ignore: discarded_futures
    ref.read(notificationServiceProvider).scheduleAll(loaded);
    return loaded;
  }

  /// Helper: return the current AppSettings or null if not yet loaded.
  /// In practice the UI only calls toggle methods after data is shown,
  /// so this never returns null in normal flow.
  AppSettings? get _current => state.value;

  /// Helper: update state in memory + persist to disk + re-schedule
  /// the OS-level notifications so they match the new settings.
  Future<void> _update(AppSettings next) async {
    state = AsyncData(next);
    await ref.read(settingsRepositoryProvider).save(next);
    await ref.read(notificationServiceProvider).scheduleAll(next);
  }

  /// Flip the global ALL master switch (Layer 1).
  Future<void> toggleGlobal() async {
    final current = _current;
    if (current == null) return;
    await _update(current.copyWith(globalEnabled: !current.globalEnabled));
  }

  /// Flip a working day's master switch (Layer 2). No-op for Saturday.
  Future<void> toggleDay(Weekday day) async {
    if (!day.isWorking) return;
    final current = _current;
    if (current == null) return;
    // Use isDayEnabled so the "absent working day defaults to on"
    // rule stays consistent with what the UI shows.
    final isOn = current.isDayEnabled(day);
    await _update(current.copyWith(
      perDayEnabled: {...current.perDayEnabled, day: !isOn},
    ));
  }

  /// Flip a single slot's per-timer enable (Layer 3).
  Future<void> toggleSlot(int slotId) async {
    final current = _current;
    if (current == null) return;
    final slot = current.slots.firstWhere((s) => s.id == slotId);
    await _update(
      current.withUpdatedSlot(slot.copyWith(enabled: !slot.enabled)),
    );
  }

  // ── Per-slot field updaters (Step 9) ───────────────────────────────
  // Each method finds the slot by id, applies copyWith for the one
  // field, and persists via _update(). Rounding/clamping is done HERE
  // so the UI picker doesn't have to enforce the spec's 5-min rule.

  /// Set a slot's time of day. The minute is snapped to the nearest
  /// multiple of 5 — enforcing the spec's 5-min granularity even if
  /// the UI picker allowed any value.
  Future<void> setSlotTime(int slotId, BreakTime newTime) async {
    final current = _current;
    if (current == null) return;
    final slot = current.slots.firstWhere((s) => s.id == slotId);
    await _update(current.withUpdatedSlot(
      slot.copyWith(time: newTime.roundedToNearest5()),
    ));
  }

  /// Set a slot's duration. Clamped to [5, 240] minutes and rounded
  /// to the nearest multiple of 5.
  Future<void> setSlotDuration(int slotId, int newMinutes) async {
    final current = _current;
    if (current == null) return;
    final clamped = newMinutes.clamp(5, 240);
    final rounded = ((clamped + 2) ~/ 5) * 5;
    final slot = current.slots.firstWhere((s) => s.id == slotId);
    await _update(current.withUpdatedSlot(
      slot.copyWith(durationMinutes: rounded),
    ));
  }

  /// Set a slot's human-readable label. Empty or all-whitespace
  /// strings are ignored (no-op) to avoid blanking the UI.
  Future<void> setSlotLabel(int slotId, String newLabel) async {
    final trimmed = newLabel.trim();
    if (trimmed.isEmpty) return;
    final current = _current;
    if (current == null) return;
    final slot = current.slots.firstWhere((s) => s.id == slotId);
    await _update(current.withUpdatedSlot(slot.copyWith(label: trimmed)));
  }

  /// Set a slot's alert sound (Chime, Bell, …). Names are not
  /// validated here — caller (the sound picker, Step 10) only
  /// passes the bundled-asset names.
  Future<void> setSlotSound(int slotId, String newSoundName) async {
    final current = _current;
    if (current == null) return;
    final slot = current.slots.firstWhere((s) => s.id == slotId);
    await _update(current.withUpdatedSlot(slot.copyWith(soundName: newSoundName)));
  }

  /// Toggle the global "vibrate on alert" preference.
  Future<void> toggleVibrate() async {
    final current = _current;
    if (current == null) return;
    await _update(current.copyWith(vibrate: !current.vibrate));
  }

  /// Toggle the global "flash LED on alert" preference.
  Future<void> toggleFlashLed() async {
    final current = _current;
    if (current == null) return;
    await _update(current.copyWith(flashLed: !current.flashLed));
  }

  /// Reset all settings to factory defaults AND clear persisted data.
  /// Used by "Reset All to Defaults" in Step 9+ and by tests.
  Future<void> resetToDefaults() async {
    state = AsyncData(AppSettings.defaults());
    await ref.read(settingsRepositoryProvider).reset();
  }
}

/// AsyncNotifierProvider — the async-aware counterpart of
/// NotifierProvider. Widgets receive an `AsyncValue<AppSettings>`
/// (loading / data / error) which they dispatch on with `.when(...)`.
final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
