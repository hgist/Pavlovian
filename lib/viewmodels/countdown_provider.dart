// Tracks active end-of-break countdowns, keyed by (slot, day).
//
// State = Map<String, DateTime> where the key is "slotId_dayIndex"
// (e.g. "1_3" = Morning Break on Wednesday) and the value is the
// countdown's end time. A break's countdown is therefore tied to the
// specific day it was started on — starting Morning Break's countdown
// on Wednesday does NOT show it running on Thursday's view.
//
// Transient runtime state, but persisted so the live MM:SS display
// survives an app restart and stays consistent with the OS-scheduled
// "break over" notification.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/break_slot.dart';
import '../models/weekday.dart';
import '../services/notification_service.dart';
import '../services/settings_repository.dart';
import 'settings_provider.dart';

class CountdownNotifier extends Notifier<Map<String, DateTime>> {
  /// Composite key for a (slot, day) countdown.
  static String keyFor(int slotId, Weekday day) => '${slotId}_${day.index}';

  @override
  Map<String, DateTime> build() {
    // ignore: discarded_futures
    _loadPersisted();
    return {};
  }

  Future<void> _loadPersisted() async {
    final loaded = await ref.read(settingsRepositoryProvider).loadCountdowns();
    // Guard against a race: if the user started/cleared a countdown
    // while this async load was in flight, don't clobber their action.
    if (state.isNotEmpty) return;
    final now = DateTime.now();
    final active = <String, DateTime>{};
    loaded.forEach((key, end) {
      if (end.isAfter(now)) active[key] = end;
    });
    if (active.isNotEmpty) state = active;
  }

  /// Begin a countdown for [slot] on [day]: end = now + duration.
  Future<void> start(BreakSlot slot, Weekday day) async {
    final end = DateTime.now().add(Duration(minutes: slot.durationMinutes));
    state = {...state, keyFor(slot.id, day): end};
    // Honour the user's vibrate / flash-LED preferences for the
    // end-of-break notification.
    final settings = ref.read(settingsProvider).value;
    final vibrate = settings?.vibrate ?? true;
    final flashLed = settings?.flashLed ?? false;
    await ref
        .read(notificationServiceProvider)
        .scheduleBreakEnd(slot, day, end, vibrate, flashLed);
    await _persist();
  }

  /// Cancel the countdown for (slotId, day) and its pending notification.
  Future<void> clear(int slotId, Weekday day) async {
    state = {...state}..remove(keyFor(slotId, day));
    await ref.read(notificationServiceProvider).cancelBreakEnd(slotId, day);
    await _persist();
  }

  /// Drop entries whose end time has passed. Called by the main-screen
  /// ticker. Returns true if anything changed.
  bool pruneExpired() {
    final now = DateTime.now();
    final next = {...state}..removeWhere((_, end) => !end.isAfter(now));
    if (next.length != state.length) {
      state = next;
      // ignore: discarded_futures
      _persist();
      return true;
    }
    return false;
  }

  /// Is a countdown running for (slotId, day)?
  bool isRunning(int slotId, Weekday day) =>
      state.containsKey(keyFor(slotId, day));

  /// End time for (slotId, day), or null if not running.
  DateTime? endTimeFor(int slotId, Weekday day) => state[keyFor(slotId, day)];

  Future<void> _persist() async {
    await ref.read(settingsRepositoryProvider).saveCountdowns(state);
  }
}

final countdownProvider =
    NotifierProvider<CountdownNotifier, Map<String, DateTime>>(
  CountdownNotifier.new,
);
