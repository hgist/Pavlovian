// Integration tests for NotificationService — verify notification and sound behavior.

import 'package:flutter_test/flutter_test.dart';
import 'package:pavlovian/models/app_settings.dart';
import 'package:pavlovian/models/break_slot.dart';
import 'package:pavlovian/models/weekday.dart';
import 'package:pavlovian/services/log_service.dart';
import 'package:pavlovian/services/notification_service.dart';

/// Mock notification service that tracks method calls for testing.
class _MockNotificationService implements NotificationService {
  final List<String> callLog = [];
  final Map<String, dynamic> channelDetailsCache = {};

  @override
  Future<void> initialize() async {
    callLog.add('initialize()');
  }

  @override
  Future<bool> requestPermission() async {
    callLog.add('requestPermission()');
    return true;
  }

  @override
  String channelIdFor(BreakSlot slot, bool vibrate, bool flashLed,
      {bool soundEnabled = true}) {
    final id = 'pavlovian_s${slot.id}'
        '_${slot.soundName.toLowerCase()}'
        '_s${soundEnabled ? 1 : 0}_v${vibrate ? 1 : 0}_l${flashLed ? 1 : 0}_r3';
    callLog.add('channelIdFor(slot=${slot.id}, sound=${soundEnabled ? "on" : "off"}) → $id');
    return id;
  }

  @override
  Future<void> fireTest(String soundName, bool vibrate, bool flashLed,
      {String? soundUri}) async {
    callLog.add('fireTest(sound=$soundName, vibrate=$vibrate, led=$flashLed)');
  }

  @override
  Future<void> scheduleAll(AppSettings settings) async {
    callLog.add(
        'scheduleAll(notificationsEnabled=${settings.notificationsEnabled}, soundEnabled=${settings.soundEnabled})');
    if (!settings.notificationsEnabled) {
      callLog.add('  → notifications disabled, exiting early');
      return;
    }
    callLog.add('  → scheduling ${settings.slots.length} slots');
  }

  @override
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
    callLog.add(
        'scheduleBreakEnd(slot=${slot.id}, text=${notificationsEnabled ? "on" : "off"}, sound=${soundEnabled ? "on" : "off"})');
  }

  @override
  Future<bool> canScheduleExactAlarms() async {
    callLog.add('canScheduleExactAlarms()');
    return true;
  }

  @override
  Future<void> cancelBreakEnd(int slotId, Weekday day) async {
    callLog.add('cancelBreakEnd(slot=$slotId)');
  }

  @override
  Future<void> ensurePermissions() async {
    callLog.add('ensurePermissions()');
  }

  @override
  Future<int> pendingCount() async {
    callLog.add('pendingCount()');
    return 0;
  }

  @override
  Future<bool> requestExactAlarmPermission() async {
    callLog.add('requestExactAlarmPermission()');
    return true;
  }

  @override
  LogService? log;

  void clearLog() => callLog.clear();
}

void main() {
  group('NotificationService flag combinations', () {
    late _MockNotificationService service;

    setUp(() {
      service = _MockNotificationService();
    });

    test(
        'Scenario 1: notificationsEnabled=true, soundEnabled=true → schedules with sound',
        () async {
      final settings = AppSettings.defaults().copyWith(
        notificationsEnabled: true,
        soundEnabled: true,
      );

      await service.scheduleAll(settings);

      expect(service.callLog, contains('scheduleAll(notificationsEnabled=true, soundEnabled=true)'));
      expect(
          service.callLog.any((line) => line.contains('scheduling 3 slots')),
          true,
          reason: 'Should contain "scheduling 3 slots"');
      expect(
          service.callLog.every((line) => !line.contains('notifications disabled')),
          true,
          reason: 'Should NOT skip notifications');
    });

    test(
        'Scenario 2: notificationsEnabled=false, soundEnabled=true → skips scheduling',
        () async {
      final settings = AppSettings.defaults().copyWith(
        notificationsEnabled: false,
        soundEnabled: true,
      );

      await service.scheduleAll(settings);

      expect(service.callLog, contains('scheduleAll(notificationsEnabled=false, soundEnabled=true)'));
      expect(
          service.callLog.any((line) => line.contains('notifications disabled')),
          true,
          reason: 'Should skip notifications when disabled');
      expect(
          service.callLog.every((line) => !line.contains('scheduling 3')),
          true,
          reason: 'Should NOT schedule when notifications disabled');
    });

    test(
        'Scenario 3: notificationsEnabled=true, soundEnabled=false → schedules without sound',
        () async {
      final settings = AppSettings.defaults().copyWith(
        notificationsEnabled: true,
        soundEnabled: false,
      );

      await service.scheduleAll(settings);

      expect(service.callLog, contains('scheduleAll(notificationsEnabled=true, soundEnabled=false)'));
      expect(
          service.callLog.any((line) => line.contains('scheduling 3 slots')),
          true,
          reason: 'Should contain "scheduling 3 slots"');
      expect(
          service.callLog.every((line) => !line.contains('notifications disabled')),
          true,
          reason: 'Should NOT skip notifications');
    });

    test(
        'Scenario 4: notificationsEnabled=false, soundEnabled=false → skips scheduling',
        () async {
      final settings = AppSettings.defaults().copyWith(
        notificationsEnabled: false,
        soundEnabled: false,
      );

      await service.scheduleAll(settings);

      expect(service.callLog, contains('scheduleAll(notificationsEnabled=false, soundEnabled=false)'));
      expect(
          service.callLog.any((line) => line.contains('notifications disabled')),
          true,
          reason: 'Should skip notifications when disabled');
      expect(
          service.callLog.every((line) => !line.contains('scheduling 3')),
          true,
          reason: 'Should NOT schedule when notifications disabled');
    });

    test('channelIdFor includes soundEnabled flag (r3 revision)', () async {
      final slot = AppSettings.defaults().slots[0];

      final idWithSound = service.channelIdFor(slot, false, false, soundEnabled: true);
      final idWithoutSound = service.channelIdFor(slot, false, false, soundEnabled: false);

      expect(idWithSound, contains('_s1_'));
      expect(idWithoutSound, contains('_s0_'));
      expect(idWithSound, contains('_r3'));
      expect(idWithoutSound, contains('_r3'));
      expect(idWithSound, isNot(idWithoutSound));
    });

    test('scheduleBreakEnd respects soundEnabled flag', () async {
      final slot = AppSettings.defaults().slots[0];
      final endTime = DateTime.now().add(const Duration(minutes: 20));

      service.clearLog();
      await service.scheduleBreakEnd(
        slot,
        Weekday.mon,
        endTime,
        true,
        false,
        endSoundName: 'Cuckoo',
        soundEnabled: false,
      );

      expect(service.callLog, contains('scheduleBreakEnd(slot=1, text=on, sound=off)'));
    });

    test('soundEnabled affects channel creation for each slot', () async {
      final settings = AppSettings.defaults();

      service.clearLog();

      // Simulate channel creation for slot 1 with sound enabled
      final id1 = service.channelIdFor(settings.slots[0], true, false, soundEnabled: true);

      // Simulate channel creation for same slot with sound disabled
      final id2 = service.channelIdFor(settings.slots[0], true, false, soundEnabled: false);

      // IDs must be different so Android creates separate channels
      expect(id1, isNot(id2));
      expect(id1, contains('_s1_'));
      expect(id2, contains('_s0_'));
    });
  });
}
