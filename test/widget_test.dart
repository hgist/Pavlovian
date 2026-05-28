// Widget tests: app boot → main screen → drawer → settings → back.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pavlovian/main.dart';
import 'package:pavlovian/models/app_settings.dart';
import 'package:pavlovian/models/break_slot.dart';
import 'package:pavlovian/models/weekday.dart';
import 'package:pavlovian/services/app_version.dart';
import 'package:pavlovian/services/notification_service.dart';
import 'package:pavlovian/viewmodels/selected_day_provider.dart';
import 'package:pavlovian/views/components/menu_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// No-op notification service so widget tests don't hit the
/// platform plugin (which has no implementation in test env).
class _StubNotificationService implements NotificationService {
  @override
  Future<void> initialize() async {}
  @override
  Future<bool> requestPermission() async => true;
  @override
  String channelIdFor(BreakSlot slot) => 'stub';
  @override
  Future<void> fireTest(BreakSlot slot) async {}
  @override
  Future<void> scheduleAll(AppSettings settings) async {}
  @override
  noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // Boots the app with: splash skipped, known version, selected day
  // pinned to Monday so assertions don't depend on what day the tests
  // happen to run on.
  Future<void> bootApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appVersionProvider.overrideWithValue(
            const AppVersion(version: '1.0.0', buildNumber: '1'),
          ),
          selectedDayProvider.overrideWith((ref) => Weekday.mon),
          notificationServiceProvider
              .overrideWithValue(_StubNotificationService()),
        ],
        child: const PavlovianApp(splashDuration: Duration.zero),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('main screen shows title + ALL switch + all 3 slots',
      (tester) async {
    await bootApp(tester);
    expect(find.text('Timers'), findsOneWidget);
    expect(find.text('ALL ON'), findsOneWidget);
    expect(find.text('Monday timers'), findsOneWidget);
    expect(find.text('Morning Break'),   findsOneWidget);
    expect(find.text('Lunch Break'),     findsOneWidget);
    expect(find.text('Afternoon Break'), findsOneWidget);
  });

  testWidgets('drawer opens via hamburger, Settings navigates to screen',
      (tester) async {
    await bootApp(tester);

    // Tap the hand-drawn hamburger icon to open the drawer
    await tester.tap(find.byType(HamburgerIcon));
    await tester.pumpAndSettle();
    expect(find.text('break time reminders'), findsOneWidget); // drawer header

    // Tap Settings — drawer closes, settings screen pushes
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    // We're now on the settings screen — assert on the header
    // and the first section (the rest is below the test viewport's
    // fold and is lazily-built by ListView).
    expect(find.text('Pavlovian v1.0.0'), findsOneWidget);
    expect(find.text('① Break Slots'),    findsOneWidget);
    expect(find.text('Morning Break'),    findsOneWidget);
    expect(find.text('Lunch Break'),      findsOneWidget);
    expect(find.text('Afternoon Break'),  findsOneWidget);

    // Back arrow returns to main
    await tester.tap(find.text('←'));
    await tester.pumpAndSettle();
    expect(find.text('Timers'), findsOneWidget);
  });
}
