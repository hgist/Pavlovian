// Unit tests for CountdownNotifier (Step 13) — keyed by (slot, day).

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pavlovian/models/break_slot.dart';
import 'package:pavlovian/models/break_time.dart';
import 'package:pavlovian/models/weekday.dart';
import 'package:pavlovian/services/notification_service.dart';
import 'package:pavlovian/viewmodels/countdown_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _StubNotificationService implements NotificationService {
  int scheduleCount = 0;
  int cancelCount = 0;

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
    scheduleCount++;
  }

  @override
  Future<void> cancelBreakEnd(int slotId, Weekday day) async {
    cancelCount++;
  }

  // start() reads settingsProvider, whose build() calls scheduleAll —
  // no-op it (and initialize) so the stub doesn't throw.
  @override
  Future<void> initialize() async {}
  @override
  Future<void> scheduleAll(settings) async {}

  @override
  noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

void main() {
  late _StubNotificationService stub;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    stub = _StubNotificationService();
  });

  ProviderContainer makeContainer() {
    final c = ProviderContainer(
      overrides: [notificationServiceProvider.overrideWithValue(stub)],
    );
    addTearDown(c.dispose);
    return c;
  }

  const slot = BreakSlot(
    id: 1,
    label: 'Morning Break',
    time: BreakTime(10, 0),
    durationMinutes: 20,
    soundName: 'Chime',
  );

  test('starts empty', () {
    final c = makeContainer();
    expect(c.read(countdownProvider), isEmpty);
  });

  test('start adds a (slot, day) entry ~duration out + schedules', () async {
    final c = makeContainer();
    final n = c.read(countdownProvider.notifier);

    final before = DateTime.now();
    await n.start(slot, Weekday.wed);

    expect(n.isRunning(1, Weekday.wed), true);
    final end = n.endTimeFor(1, Weekday.wed)!;
    final expected = before.add(const Duration(minutes: 20));
    expect(end.difference(expected).inSeconds.abs() < 5, true);
    expect(stub.scheduleCount, 1);
  });

  test('countdown is day-specific — Wed start not running on Thu', () async {
    final c = makeContainer();
    final n = c.read(countdownProvider.notifier);

    await n.start(slot, Weekday.wed);
    expect(n.isRunning(1, Weekday.wed), true);
    expect(n.isRunning(1, Weekday.thu), false); // <-- the key fix
    expect(n.isRunning(2, Weekday.wed), false); // different slot too
  });

  test('clear removes only that (slot, day) + cancels', () async {
    final c = makeContainer();
    final n = c.read(countdownProvider.notifier);

    await n.start(slot, Weekday.wed);
    await n.start(slot, Weekday.thu); // same slot, different day
    expect(n.isRunning(1, Weekday.wed), true);
    expect(n.isRunning(1, Weekday.thu), true);

    await n.clear(1, Weekday.wed);
    expect(n.isRunning(1, Weekday.wed), false);
    expect(n.isRunning(1, Weekday.thu), true); // untouched
    expect(stub.cancelCount, 1);
  });

  test('pruneExpired keeps still-active entries', () async {
    final c = makeContainer();
    final n = c.read(countdownProvider.notifier);
    await n.start(slot, Weekday.wed);
    expect(n.pruneExpired(), false);
    expect(n.isRunning(1, Weekday.wed), true);
  });

  test('countdowns persist across container rebuild', () async {
    final c1 = ProviderContainer(
      overrides: [notificationServiceProvider.overrideWithValue(stub)],
    );
    await c1.read(countdownProvider.notifier).start(slot, Weekday.wed);
    c1.dispose();

    final c2 = ProviderContainer(
      overrides: [notificationServiceProvider.overrideWithValue(stub)],
    );
    addTearDown(c2.dispose);
    c2.read(countdownProvider); // trigger build + load
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(
      c2.read(countdownProvider).containsKey(
            CountdownNotifier.keyFor(1, Weekday.wed),
          ),
      true,
    );
  });
}
