// Smoke test: the app boots, async-loads settings, and the main screen
// shows the expected elements after the load completes.
//
// `pumpAndSettle()` advances all pending Futures + animations so the
// AsyncValue switches from loading → data before we assert.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pavlovian/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'app boots, loads settings, shows main screen title + slots',
    (tester) async {
      await tester.pumpWidget(const ProviderScope(child: PavlovianApp()));
      // First frame is the loading screen.
      await tester.pumpAndSettle();
      // Now the async load is done, main screen is rendered.

      expect(find.text('Timers'), findsOneWidget);
      expect(find.text('ALL ON'), findsOneWidget);
      expect(find.text('Monday timers'), findsOneWidget);
      expect(find.text('Morning Break'),   findsOneWidget);
      expect(find.text('Lunch Break'),     findsOneWidget);
      expect(find.text('Afternoon Break'), findsOneWidget);
    },
  );
}
