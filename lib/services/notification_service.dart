// Notification service — wraps `flutter_local_notifications` so the
// UI can fire alerts without touching the platform plugin directly.
//
// In Step 11 only `fireTest(slot)` is used (manual "▶ test" button).
// In Step 12 we add scheduled firing at slot times.
//
// Channel-per-(slot, sound)
//   Android channels CANNOT change their sound after creation. So
//   when a slot's sound changes, we create a new channel with a
//   different ID (`pavlovian_slot_{id}_{sound}`). Old channels are
//   harmless — they just sit unused in Android's settings until the
//   app is uninstalled.

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/break_slot.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize the plugin. Safe to call multiple times — first call
  /// does the work, subsequent calls are no-ops.
  Future<void> initialize() async {
    if (_initialized) return;

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(initSettings);
    _initialized = true;
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

  /// Build the channel ID for a (slot, sound) pair. Stable for a
  /// given combination — re-creating with the same ID is a no-op.
  String channelIdFor(BreakSlot slot) =>
      'pavlovian_slot_${slot.id}_${slot.soundName.toLowerCase()}';

  /// Create or update the Android notification channel for this slot.
  /// Idempotent: same ID + same params = no-op. Different sound name
  /// = different ID (so a new channel — sound takes effect).
  Future<void> _ensureChannel(BreakSlot slot) async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;

    final channel = AndroidNotificationChannel(
      channelIdFor(slot),
      'Pavlovian — slot ${slot.id}',
      description: 'Break reminder for "${slot.label}"',
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound(
        slot.soundName.toLowerCase(), // chime / bell / ping / soft
      ),
    );
    await androidPlugin.createNotificationChannel(channel);
  }

  /// Fire a notification right now (used by the "▶ test" button in
  /// Settings → Notifications). The notification ID is the slot id
  /// so repeated test taps replace, not stack.
  Future<void> fireTest(BreakSlot slot) async {
    await initialize();
    final granted = await requestPermission();
    if (!granted) return;
    await _ensureChannel(slot);

    final channelId = channelIdFor(slot);
    await _plugin.show(
      slot.id,
      'Test: ${slot.label}',
      'Time for your break — ${slot.time.toDisplay()}',
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          'Pavlovian — slot ${slot.id}',
          channelDescription: 'Break reminder',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}

/// Shared NotificationService instance via Riverpod.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
