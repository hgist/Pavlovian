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
import '../models/weekday.dart';
import '../services/settings_repository.dart';

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  /// Runs once on first read. Returning a Future puts us in the
  /// "loading" state until it completes; result becomes the data.
  @override
  Future<AppSettings> build() async {
    final repo = ref.read(settingsRepositoryProvider);
    return await repo.load();
  }

  /// Helper: return the current AppSettings or null if not yet loaded.
  /// In practice the UI only calls toggle methods after data is shown,
  /// so this never returns null in normal flow.
  AppSettings? get _current => state.value;

  /// Helper: update state in memory + persist to disk.
  Future<void> _update(AppSettings next) async {
    state = AsyncData(next);
    await ref.read(settingsRepositoryProvider).save(next);
  }

  /// Flip the global ALL master switch (Layer 1).
  Future<void> toggleGlobal() async {
    final current = _current;
    if (current == null) return;
    await _update(current.copyWith(globalEnabled: !current.globalEnabled));
  }

  /// Flip a working day's master switch (Layer 2). No-op for Fri/Sat.
  Future<void> toggleDay(Weekday day) async {
    if (!day.isWorking) return;
    final current = _current;
    if (current == null) return;
    final isOn = current.perDayEnabled[day] ?? false;
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
