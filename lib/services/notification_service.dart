// Notification service — wraps `flutter_local_notifications` so the
// UI can fire alerts without touching the platform plugin directly.
//
// Two responsibilities:
//   1. fireTest(slot)             — one-off "▶ test" button (Step 11)
//   2. scheduleAll(AppSettings)   — recurring weekly alarms (Step 12)
//
// Channel-per-(slot, sound)
//   Android channels CANNOT change their sound after creation. So
//   when a slot's sound changes, we create a new channel with a
//   different ID (`pavlovian_slot_{id}_{sound}`). Old channels are
//   harmless — they just sit unused in Android's settings until the
//   app is uninstalled.
//
// Schedule IDs
//   Each (slot, weekday) pair gets a unique notification ID:
//     id = slot.id * 100 + weekday.index
//   slot 1/Sun = 100 … slot 3/Thu = 304. Test-fire IDs (1..3) live
//   well below this range so they never collide.

import 'dart:async';
import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/app_settings.dart';
import '../models/break_slot.dart';
import '../models/weekday.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize the plugin AND the timezone database. Safe to call
  /// multiple times — first call does the work, the rest are no-ops.
  Future<void> initialize() async {
    if (_initialized) return;

    // Load tzdata so tz.local resolves to a real Location.
    tz_data.initializeTimeZones();
    try {
      final tzName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzName));
      debugPrint('NotificationService: tz = $tzName');
    } catch (e) {
      // No platform timezone available (e.g., tests) — fall back
      // to UTC. Scheduling will still work, just in UTC offsets.
      debugPrint('NotificationService: tz lookup FAILED → UTC fallback ($e)');
    }

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(initSettings);
    _initialized = true;
    debugPrint('NotificationService: initialized');
  }

  /// Ask the OS for POST_NOTIFICATIONS permission (Android 13+).
  /// On older Android versions this returns true immediately because
  /// the install-time grant is sufficient.
  Future<bool> requestPermission() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return true;
    final granted = await androidPlugin.requestNotificationsPermission();
    return granted ?? true;
  }

  // ── Channels ────────────────────────────────────────────────────

  /// Build the channel ID for a (slot, sound, vibrate, led) combo.
  /// Every behavior that Android freezes at channel-creation time is
  /// encoded here, so changing any of them produces a NEW channel
  /// with the new behavior (Android won't mutate an existing channel,
  /// and even restores deleted-then-recreated channels' old settings).
  String channelIdFor(BreakSlot slot, bool vibrate, bool flashLed) =>
      'pavlovian_s${slot.id}_${slot.soundName.toLowerCase()}'
      '_v${vibrate ? 1 : 0}_l${flashLed ? 1 : 0}';

  /// Create the Android notification channel for this (slot, vibrate,
  /// led) combo if it doesn't already exist. No delete needed — a
  /// changed setting yields a different ID.
  Future<void> _ensureChannel(
    BreakSlot slot,
    bool vibrate,
    bool flashLed,
  ) async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;

    final channel = AndroidNotificationChannel(
      channelIdFor(slot, vibrate, flashLed),
      'Pavlovian — slot ${slot.id}',
      description: 'Break reminder for "${slot.label}"',
      importance: Importance.max,
      // Default notification audio stream (not alarm stream — that one
      // is often muted on user devices). category:alarm on the details
      // still gives the OS the "time-critical" hint.
      sound: RawResourceAndroidNotificationSound(
        slot.soundName.toLowerCase(),
      ),
      playSound: true,
      enableVibration: vibrate,
      enableLights: flashLed,
      ledColor: flashLed ? const Color(0xFFE8A07A) : null,
    );
    await androidPlugin.createNotificationChannel(channel);
  }

  // ── One-off "test" notification (Step 11) ──────────────────────

  /// Fire a notification right now. Notification ID = slot.id so
  /// repeated taps replace rather than stack.
  Future<void> fireTest(BreakSlot slot, bool vibrate, bool flashLed) async {
    try {
      await initialize();
      final granted = await requestPermission();
      if (!granted) return;
      await _ensureChannel(slot, vibrate, flashLed);
      await _plugin.show(
        slot.id,
        slot.label, // title = the alert label (user-defined)
        'Test alert — ${slot.time.toDisplay()}, ${slot.soundName} sound.',
        _detailsFor(slot, vibrate, flashLed),
      );
    } catch (e, st) {
      debugPrint('fireTest failed: $e\n$st');
    }
  }

  // ── Scheduled recurring alarms (Step 12) ───────────────────────

  /// Re-build the entire schedule from `settings`:
  ///   1. Cancel every previously-scheduled slot/day notification
  ///   2. For each enabled slot × each enabled working day, schedule
  ///      a weekly-recurring notification at the slot's time.
  ///
  /// Fri/Sat are hard-excluded (Weekday.isWorking == false).
  ///
  /// Called from SettingsNotifier after every state change.
  Future<void> scheduleAll(AppSettings settings) async {
    try {
      await initialize();

      // Cancel any previously-scheduled break notifications. We
      // touch only the schedule ID range (100..399), leaving any
      // tray-resident test notifications (IDs 1..3) untouched.
      await _cancelAllScheduled();

      // If the global switch is off, we're done — no schedules.
      if (!settings.globalEnabled) {
        debugPrint('scheduleAll: global OFF → 0 schedules');
        return;
      }

      var count = 0;
      for (final slot in settings.slots) {
        if (!slot.enabled) continue;
        await _ensureChannel(slot, settings.vibrate, settings.flashLed);

        for (final day in Weekday.values) {
          if (!settings.isDayEnabled(day)) continue;
          await _scheduleSlotOnDay(
              slot, day, settings.vibrate, settings.flashLed);
          count++;
        }
      }
      debugPrint('scheduleAll: $count schedules created');
    } catch (e, st) {
      debugPrint('scheduleAll FAILED: $e\n$st');
    }
  }

  /// Returns the number of currently-pending scheduled notifications.
  /// Useful as a diagnostic — the test snackbar shows this.
  Future<int> pendingCount() async {
    try {
      await initialize();
      final pending = await _plugin.pendingNotificationRequests();
      return pending.length;
    } catch (_) {
      return -1;
    }
  }

  // ── End-of-break countdown (Step 13) ───────────────────────────

  /// Notification ID for an end-of-break countdown. Encodes both the
  /// slot and the day so per-(slot, day) countdowns don't collide:
  ///   id = 500 + slotId*10 + day.index
  /// Range 510..536 — clear of recurring (100..306) and test (1..3).
  int _breakEndId(int slotId, Weekday day) => 500 + slotId * 10 + day.index;

  /// Schedule a one-shot "break over" notification at [endTime] for a
  /// specific (slot, day).
  Future<void> scheduleBreakEnd(
    BreakSlot slot,
    Weekday day,
    DateTime endTime,
    bool vibrate,
    bool flashLed,
  ) async {
    try {
      await initialize();
      await _ensureChannel(slot, vibrate, flashLed);
      final when = tz.TZDateTime.from(endTime, tz.local);
      await _plugin.zonedSchedule(
        _breakEndId(slot.id, day),
        slot.label, // title = the alert label (user-defined)
        'Break over — your ${slot.durationMinutes}-minute break has '
            'ended. Time to head back.',
        when,
        _detailsFor(slot, vibrate, flashLed),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        // No matchDateTimeComponents → fires once, not recurring.
      );
      debugPrint('scheduleBreakEnd: slot ${slot.id}/${day.label} ends $when');
    } catch (e, st) {
      debugPrint('scheduleBreakEnd FAILED: $e\n$st');
    }
  }

  /// Cancel a pending end-of-break notification for (slotId, day).
  Future<void> cancelBreakEnd(int slotId, Weekday day) async {
    try {
      await initialize();
      await _plugin.cancel(_breakEndId(slotId, day));
    } catch (e) {
      debugPrint('cancelBreakEnd failed: $e');
    }
  }

  /// Cancel all schedule-range IDs (100..399). Idempotent.
  Future<void> _cancelAllScheduled() async {
    for (var slotId = 1; slotId <= 3; slotId++) {
      for (var dayIdx = 0; dayIdx < Weekday.values.length; dayIdx++) {
        await _plugin.cancel(_idFor(slotId, dayIdx));
      }
    }
  }

  /// Schedule a single weekly-recurring notification for this slot on
  /// this weekday. Idempotent because Android replaces by ID.
  Future<void> _scheduleSlotOnDay(
    BreakSlot slot,
    Weekday day,
    bool vibrate,
    bool flashLed,
  ) async {
    final id = _idFor(slot.id, day.index);
    final firstFire = _nextInstanceOf(
      _dartWeekday(day),
      slot.time.hour,
      slot.time.minute,
    );

    await _plugin.zonedSchedule(
      id,
      slot.label, // title = the alert label (user-defined)
      "Break time — it's ${slot.time.toDisplay()}. "
          'Enjoy your ${slot.durationMinutes} minutes.',
      firstFire,
      _detailsFor(slot, vibrate, flashLed),
      // alarmClock = setAlarmClock() under the hood. Same priority
      // as the built-in clock app's alarms — bypasses Doze, battery
      // optimization, Samsung's "sleeping apps" list, and the
      // swipe-from-recents kill. Trade-off: a small alarm icon
      // sits in the status bar showing "next alarm" (acceptable
      // for a reminder app).
      // History: exactAllowWhileIdle + inexactAllowWhileIdle both
      // tested and silently dropped on Galaxy S10 / One UI.
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // Repeat weekly at the same weekday + hh:mm.
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
    debugPrint('  scheduled id=$id ${slot.label} @ $firstFire');
  }

  /// First TZDateTime in the future that lands on `dartWeekday` at the
  /// given hour:minute. dartWeekday uses Dart's convention (Mon=1..Sun=7).
  tz.TZDateTime _nextInstanceOf(int dartWeekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    // Walk forward until we hit the right weekday AND it's in the future.
    while (scheduled.weekday != dartWeekday || !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Convert our enum (sun=0..sat=6) to Dart's weekday (mon=1..sun=7).
  int _dartWeekday(Weekday d) {
    switch (d) {
      case Weekday.mon: return DateTime.monday;
      case Weekday.tue: return DateTime.tuesday;
      case Weekday.wed: return DateTime.wednesday;
      case Weekday.thu: return DateTime.thursday;
      case Weekday.fri: return DateTime.friday;
      case Weekday.sat: return DateTime.saturday;
      case Weekday.sun: return DateTime.sunday;
    }
  }

  int _idFor(int slotId, int dayIdx) => slotId * 100 + dayIdx;

  NotificationDetails _detailsFor(
    BreakSlot slot,
    bool vibrate,
    bool flashLed,
  ) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelIdFor(slot, vibrate, flashLed),
        'Pavlovian — slot ${slot.id}',
        channelDescription: 'Break reminder',
        importance: Importance.max,
        priority: Priority.max,
        icon: '@mipmap/ic_launcher',
        // Tells Android this is alarm-class — survives DND, less
        // likely to be suppressed.
        category: AndroidNotificationCategory.alarm,
        playSound: true,
        // Channel governs these on Android 8+, but set them here too
        // for pre-O devices. ledOnMs/ledOffMs are REQUIRED whenever
        // lights are enabled (blink cycle) or the plugin throws.
        enableVibration: vibrate,
        enableLights: flashLed,
        ledColor: flashLed ? const Color(0xFFE8A07A) : null,
        ledOnMs: flashLed ? 1000 : null,
        ledOffMs: flashLed ? 500 : null,
      ),
    );
  }
}

/// Shared NotificationService instance via Riverpod.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
