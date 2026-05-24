// The single source of truth for all user-configurable app state.
//
// This is the "ViewModel" layer in our MVVM architecture:
//   - It holds an AppSettings (from lib/models/) — purely data.
//   - It exposes methods to mutate that state immutably (always via
//     copyWith — never modify fields in place).
//   - Widgets subscribe with `ref.watch(settingsProvider)` and rebuild
//     when state changes.
//
// For C/Java programmers:
//   Notifier ≈ a Java class with private state + public setter methods.
//   NotifierProvider ≈ a singleton-like accessor for that object.
//   `state` is a field of type AppSettings; assigning to it triggers
//   reactive rebuilds of any UI watching this provider.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import '../models/weekday.dart';

class SettingsNotifier extends Notifier<AppSettings> {
  /// Called once when this provider is first read. Returns the
  /// initial state. In Step 7 we'll load from shared_preferences here.
  @override
  AppSettings build() => AppSettings.defaults();

  /// Flip the global ALL master switch (Layer 1 of the enable hierarchy).
  void toggleGlobal() {
    state = state.copyWith(globalEnabled: !state.globalEnabled);
  }

  /// Flip a working day's master switch (Layer 2). No-op for Fri/Sat
  /// — those days never fire regardless.
  void toggleDay(Weekday day) {
    if (!day.isWorking) return;
    final current = state.perDayEnabled[day] ?? false;
    state = state.copyWith(
      perDayEnabled: {...state.perDayEnabled, day: !current},
    );
  }

  /// Flip a single slot's per-timer enable (Layer 3).
  /// Identified by slot.id (1, 2, or 3).
  void toggleSlot(int slotId) {
    final slot = state.slots.firstWhere((s) => s.id == slotId);
    state = state.withUpdatedSlot(slot.copyWith(enabled: !slot.enabled));
  }
}

/// The provider widgets read from / listen to.
/// Idiomatic Riverpod naming: lowercase + "Provider" suffix.
final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
