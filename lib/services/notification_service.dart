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

import '../main.dart' show rootNavigatorKey;
import '../models/app_settings.dart';
import '../models/break_slot.dart';
import '../models/break_time.dart';
import '../models/weekday.dart';
import 'log_service.dart';
import 'settings_repository.dart';

/// Action id for the "▶ Start countdown" button on break notifications.
/// Centralised here so the handler and the scheduler agree.
const String kStartCountdownActionId = 'start_countdown';

/// Background isolate entry point for tapped notification actions when
/// the app is killed or backgrounded. Annotated with `@pragma` so the
/// AOT compiler keeps it — without that, it would be tree-shaken in
/// release builds and Android would have no callback to invoke.
@pragma('vm:entry-point')
void onBackgroundNotificationResponse(NotificationResponse r) {
  // ignore: discarded_futures
  _handleNotificationResponse(r);
}

/// Foreground tap handler — runs in the app's main isolate. We share
/// the action-button logic with the background handler, and ALSO pop
/// the navigator stack back to root when the user taps the notification
/// body, so they always land on the Main screen (which has the per-slot
/// ▶ Start buttons) regardless of which screen was last visible.
@pragma('vm:entry-point')
void onForegroundNotificationResponse(NotificationResponse r) {
  // ignore: discarded_futures
  _handleNotificationResponse(r);
  // Body tap (no actionId) → pop everything above MainScreen so the
  // user doesn't land on Settings / Diagnostics by accident.
  if (r.actionId == null) {
    final nav = rootNavigatorKey.currentState;
    if (nav != null && nav.canPop()) {
      nav.popUntil((route) => route.isFirst);
    }
  }
}

/// Heart of the "Start countdown from notification" flow.
///
/// Runs in either the main isolate (foreground tap) or a fresh
/// background isolate (locked-screen tap with app killed), so it CAN'T
/// rely on Riverpod / app-wide singletons. Everything it needs is
/// read fresh from SharedPreferences.
///
/// Steps:
///   1. Parse the payload `start:slotId:dayIndex`.
///   2. Load AppSettings to find the slot + read user prefs.
///   3. Persist the new countdown (end = now + slot.durationMinutes).
///   4. Schedule the matching end-of-break notification via a freshly-
///      initialised plugin instance — channels persist across isolates,
///      but the FlutterLocalNotificationsPlugin object does not.
Future<void> _handleNotificationResponse(NotificationResponse r) async {
  if (r.actionId != kStartCountdownActionId) return;
  final payload = r.payload;
  if (payload == null) return;
  final parts = payload.split(':');
  if (parts.length != 3 || parts[0] != 'start') return;
  final slotId = int.tryParse(parts[1]);
  final dayIdx = int.tryParse(parts[2]);
  if (slotId == null || dayIdx == null) return;
  if (dayIdx < 0 || dayIdx >= Weekday.values.length) return;

  final repo = SettingsRepository();
  final settings = await repo.load();
  final slot = settings.slots.where((s) => s.id == slotId).firstOrNull;
  if (slot == null) return;
  final day = Weekday.values[dayIdx];

  // Persist the new countdown so the main screen shows it when re-opened.
  final end = DateTime.now().add(Duration(minutes: slot.durationMinutes));
  final countdowns = await repo.loadCountdowns();
  countdowns['${slotId}_$dayIdx'] = end;
  await repo.saveCountdowns(countdowns);

  // Schedule the end-of-break notification. Re-initialise the plugin
  // because we may be in a fresh isolate where the singleton state is
  // empty.
  final svc = NotificationService();
  await svc.initialize();
  await svc.scheduleBreakEnd(
    slot,
    day,
    end,
    settings.vibrate,
    settings.flashLed,
    endSoundName: settings.endSoundName,
    endSoundUri: settings.endSoundUri,
    soundEnabled: settings.soundEnabled,
    notificationsEnabled: settings.notificationsEnabled,
  );
}

class NotificationService {
  /// Optional logger. Wired up by the Riverpod provider so we don't
  /// create a Riverpod ref dependency inside this plain class.
  LogService? log;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  void _l(String s) {
    log?.log(s);
    debugPrint(s);
  }

  /// Initialize the plugin AND the timezone database. Safe to call
  /// multiple times — first call does the work, the rest are no-ops.
  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      final tzName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzName));
      _l('init: tz=$tzName');
    } catch (e) {
      _l('init: tz LOOKUP FAILED → UTC ($e)');
    }

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: onForegroundNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          onBackgroundNotificationResponse,
    );
    _initialized = true;
    _l('init: plugin OK');
  }

  /// Diagnostic: does the OS currently allow exact alarms? Returns
  /// true on older Android (pre-API 31) where this is always allowed.
  Future<bool> canScheduleExactAlarms() async {
    try {
      final p = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (p == null) return true;
      final ok = await p.canScheduleExactNotifications();
      return ok ?? true;
    } catch (e) {
      _l('canScheduleExactAlarms ERROR: $e');
      return true;
    }
  }

  /// Diagnostic: ask the OS to grant exact-alarm permission. Opens the
  /// system Settings page when not yet granted (Android 12+).
  Future<bool> requestExactAlarmPermission() async {
    try {
      final p = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (p == null) return true;
      final ok = await p.requestExactAlarmsPermission();
      _l('requestExactAlarmPermission → $ok');
      return ok ?? true;
    } catch (e) {
      _l('requestExactAlarmPermission ERROR: $e');
      return true;
    }
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

  /// Request both permissions needed for notifications to work.
  /// Safe to call on every startup — each call is a no-op when the
  /// permission is already granted:
  ///   1. POST_NOTIFICATIONS (Android 13+) — shows an OS dialog.
  ///   2. SCHEDULE_EXACT_ALARM (Android 12+) — opens the system
  ///      Settings page only when not yet granted; no-op otherwise.
  /// Without both, scheduled break notifications are silently dropped.
  Future<void> ensurePermissions() async {
    await initialize();
    await requestPermission();
    await requestExactAlarmPermission();
  }

  // ── Channels ────────────────────────────────────────────────────

  /// Build the channel ID for a (slot, sound, vibrate, led) combo.
  /// Every behavior that Android freezes at channel-creation time is
  /// encoded here, so changing any of them produces a NEW channel.
  /// For system-sound URIs we include a hash so different URIs land
  /// on different channels.
  String channelIdFor(BreakSlot slot, bool vibrate, bool flashLed,
      {bool soundEnabled = true}) {
    final soundKey = slot.soundUri != null
        ? 'u${slot.soundUri!.hashCode.toUnsigned(32).toRadixString(16)}'
        : slot.soundName.toLowerCase();
    // `r3` suffix forces NEW channels in v1.6.5+ when soundEnabled changes.
    // Android refuses to change a channel's sound after creation, so toggling
    // soundEnabled needs a new channel ID to take effect.
    return 'pavlovian_s${slot.id}_$soundKey'
        '_s${soundEnabled ? 1 : 0}_v${vibrate ? 1 : 0}_l${flashLed ? 1 : 0}_r3';
  }

  /// Create the channel for this (slot, sound, vibrate, led) combo.
  /// Picks UriAndroidNotificationSound when the user chose a system
  /// ringtone, else RawResourceAndroidNotificationSound for bundled.
  Future<void> _ensureChannel(
    BreakSlot slot,
    bool vibrate,
    bool flashLed, {
    bool soundEnabled = true,
  }) async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;

    final AndroidNotificationSound? soundSource = soundEnabled
        ? (slot.soundUri != null
            ? UriAndroidNotificationSound(slot.soundUri!)
            : RawResourceAndroidNotificationSound(
                slot.soundName.toLowerCase(),
              ))
        : null;

    final channel = AndroidNotificationChannel(
      channelIdFor(slot, vibrate, flashLed, soundEnabled: soundEnabled),
      'Pavlovian — slot ${slot.id}',
      description: 'Break reminder for "${slot.label}"',
      importance: Importance.max,
      sound: soundSource,
      playSound: soundEnabled,
      enableVibration: vibrate,
      enableLights: flashLed,
      ledColor: flashLed ? const Color(0xFFE8A07A) : null,
    );
    await androidPlugin.createNotificationChannel(channel);
  }

  // ── One-off "test" notification (Step 11) ──────────────────────

  /// Fire a notification right now using the user-chosen test sound.
  /// [soundUri] is `null` for bundled sounds, a content:// URI when
  /// the user picked a system ringtone. Notification id 0 is reserved
  /// for the test so it never collides with real slots.
  Future<void> fireTest(
    String soundName,
    bool vibrate,
    bool flashLed, {
    String? soundUri,
  }) async {
    try {
      await initialize();
      final granted = await requestPermission();
      if (!granted) return;
      // Synthetic slot used only to drive channel + notification
      // creation with the chosen sound. id 0 is exclusive to the test.
      final testSlot = BreakSlot(
        id: 0,
        label: 'Test',
        time: const BreakTime(0, 0),
        durationMinutes: 0,
        soundName: soundName,
        soundUri: soundUri,
      );
      await _ensureChannel(testSlot, vibrate, flashLed);
      await _plugin.show(
        0,
        'Timers Test Alert',
        'Testing alert — $soundName sound'
            '${vibrate ? ", vibration on" : ""}'
            '${flashLed ? ", LED on" : ""}.',
        _detailsFor(testSlot, vibrate, flashLed),
      );
      _l('fireTest OK · sound=$soundName uri=${soundUri ?? "(none)"}');
    } catch (e, st) {
      _l('fireTest FAILED: $e');
      debugPrint('$st');
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
      _l('scheduleAll START · globalEnabled=${settings.globalEnabled} '
          '· slots=${settings.slots.length}');

      await _cancelAllScheduled();
      _l('scheduleAll: cancelled previous batch');

      if (!settings.globalEnabled) {
        _l('scheduleAll: GLOBAL OFF → 0 schedules');
        return;
      }

      if (!settings.notificationsEnabled && !settings.soundEnabled) {
        _l('scheduleAll: NOTIFICATIONS AND SOUND BOTH OFF → 0 schedules');
        return;
      }

      if (!settings.notificationsEnabled && settings.soundEnabled) {
        _l('scheduleAll: SOUND ONLY MODE (notifications off, sound on)');
      }
      if (settings.notificationsEnabled && !settings.soundEnabled) {
        _l('scheduleAll: VISUAL ONLY MODE (notifications on, sound off)');
      }

      var count = 0;
      var failed = 0;
      for (final slot in settings.slots) {
        if (!slot.enabled) {
          _l('  slot ${slot.id} "${slot.label}" DISABLED — skip');
          continue;
        }
        try {
          await _ensureChannel(slot, settings.vibrate, settings.flashLed,
              soundEnabled: settings.soundEnabled);
        } catch (e) {
          _l('  slot ${slot.id} channel FAILED: $e');
          failed++;
          continue;
        }
        for (final day in Weekday.values) {
          if (!settings.isDayEnabled(day)) continue;
          try {
            await _scheduleSlotOnDay(slot, day, settings.vibrate,
                settings.flashLed,
                soundEnabled: settings.soundEnabled,
                notificationsEnabled: settings.notificationsEnabled);
            count++;
          } catch (e) {
            _l('  slot ${slot.id}/${day.label} schedule FAILED: $e');
            failed++;
          }
        }
      }
      _l('scheduleAll END · created=$count · failed=$failed');
    } catch (e, st) {
      _l('scheduleAll FATAL: $e');
      debugPrint('$st');
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
  ///
  /// [endSoundName] / [endSoundUri] override the sound. We build a
  /// SYNTHETIC slot with these so the channel id picks up the end-
  /// sound — channels are immutable once created, so different sounds
  /// must live on different channel IDs.
  Future<void> scheduleBreakEnd(
    BreakSlot slot,
    Weekday day,
    DateTime endTime,
    bool vibrate,
    bool flashLed, {
    required String endSoundName,
    String? endSoundUri,
    bool soundEnabled = true,
    bool notificationsEnabled = true,
  }) async {
    try {
      await initialize();
      // Synthetic "end-of-break" slot — same id/label so notification
      // metadata still reads like the original break, but with the
      // end-sound substituted. Negative slot id keeps end-of-break
      // channels in their own namespace (no collision with start-of-
      // break channels for slots 1..20).
      final endSlot = BreakSlot(
        id: -slot.id, // negative → end-of-break channel namespace
        label: slot.label,
        time: slot.time,
        durationMinutes: slot.durationMinutes,
        soundName: endSoundName,
        soundUri: endSoundUri,
      );
      await _ensureChannel(endSlot, vibrate, flashLed,
          soundEnabled: soundEnabled);
      final when = tz.TZDateTime.from(endTime, tz.local);
      await _plugin.zonedSchedule(
        _breakEndId(slot.id, day),
        notificationsEnabled ? slot.label : '⏰', // title (minimal if notifications OFF)
        notificationsEnabled
            ? 'Break over — your ${slot.durationMinutes}-minute break has '
                'ended. Time to head back.'
            : '', // body (empty if notifications OFF)
        when,
        _detailsFor(endSlot, vibrate, flashLed,
            soundEnabled: soundEnabled,
            showNotificationText: notificationsEnabled),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        // No matchDateTimeComponents → fires once, not recurring.
      );
      _l('scheduleBreakEnd: slot ${slot.id}/${day.label} '
          '@ $when · sound=$endSoundName');
    } catch (e, st) {
      _l('scheduleBreakEnd FAILED: $e');
      debugPrint('$st');
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

  /// Cancel all schedule-range IDs for slots 1..20 across all days.
  /// The upper bound is generous so dynamically-added slots up to id
  /// 20 are covered (we allow a lot of headroom for slot growth).
  /// Idempotent — cancelling a non-existent ID is a no-op.
  Future<void> _cancelAllScheduled() async {
    for (var slotId = 1; slotId <= 20; slotId++) {
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
    bool flashLed, {
    bool soundEnabled = true,
    bool notificationsEnabled = true,
  }) async {
    final id = _idFor(slot.id, day.index);
    final firstFire = _nextInstanceOf(
      _dartWeekday(day),
      slot.time.hour,
      slot.time.minute,
    );

    // Tappable "▶ Start countdown" button on the notification.
    // The payload encodes (slot, day) so the action handler can
    // start the right countdown even when the app has been killed.
    final actions = <AndroidNotificationAction>[
      const AndroidNotificationAction(
        kStartCountdownActionId,
        '▶ Start countdown',
        // Dismiss the notification when tapped — there's no point
        // keeping it around once the duration timer is running.
        cancelNotification: true,
        // We don't pop a UI from the action — the countdown runs
        // headlessly. `showsUserInterface = false` keeps Android
        // from briefly bringing our activity to the foreground.
        showsUserInterface: false,
      ),
    ];

    await _plugin.zonedSchedule(
      id,
      notificationsEnabled ? slot.label : '⏰', // title (minimal if notifications OFF)
      notificationsEnabled
          ? "Break time — it's ${slot.time.toDisplay()}. "
              'Enjoy your ${slot.durationMinutes} minutes.'
          : '', // body (empty if notifications OFF)
      firstFire,
      _detailsFor(slot, vibrate, flashLed,
          soundEnabled: soundEnabled,
          showNotificationText: notificationsEnabled,
          actions: actions),
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
      // Payload format: `start:<slotId>:<dayIndex>` — parsed by the
      // top-level `_handleNotificationResponse` handler.
      payload: 'start:${slot.id}:${day.index}',
    );
    _l('  scheduled id=$id "${slot.label}" @ $firstFire');
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
    bool flashLed, {
    bool soundEnabled = true,
    bool showNotificationText = true,
    List<AndroidNotificationAction>? actions,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelIdFor(slot, vibrate, flashLed, soundEnabled: soundEnabled),
        'Pavlovian — slot ${slot.id}',
        channelDescription: 'Break reminder',
        importance: Importance.max,
        priority: Priority.max,
        icon: '@mipmap/ic_launcher',
        // `reminder` is more LED-friendly than `alarm` on Samsung:
        // alarm-class often triggers heads-up popup instead of LED
        // flash. Reminder still survives Doze and gets delivered,
        // but is more likely to drive the notification LED.
        category: AndroidNotificationCategory.reminder,
        playSound: soundEnabled,
        // Channel governs these on Android 8+, but set them here too
        // for pre-O devices. ledOnMs/ledOffMs are REQUIRED whenever
        // lights are enabled (blink cycle) or the plugin throws.
        enableVibration: vibrate,
        enableLights: flashLed,
        ledColor: flashLed ? const Color(0xFFE8A07A) : null,
        ledOnMs: flashLed ? 1000 : null,
        ledOffMs: flashLed ? 500 : null,
        // When showNotificationText=false, show minimal alert (sound only, no text)
        showWhen: showNotificationText,
        actions: actions,
      ),
    );
  }
}

/// Shared NotificationService instance via Riverpod. Wires in the
/// LogService so scheduling / fire events show up on the Diagnostics
/// screen even in release builds (where debugPrint is invisible).
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final svc = NotificationService();
  svc.log = ref.read(logServiceProvider);
  return svc;
});
