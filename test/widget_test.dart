// Smoke test: the app boots wrapped in ProviderScope (Step 6 onward)
// and the main screen shows expected elements.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pavlovian/main.dart';

void main() {
  testWidgets(
    'app boots and main screen shows title, ALL switch label, and all 3 slots',
    (tester) async {
      await tester.pumpWidget(const ProviderScope(child: PavlovianApp()));
      // Header
      expect(find.text('Timers'), findsOneWidget);
      expect(find.text('ALL ON'), findsOneWidget);
      // Day master
      expect(find.text('Monday timers'), findsOneWidget);
      // All three slot labels
      expect(find.text('Morning Break'),   findsOneWidget);
      expect(find.text('Lunch Break'),     findsOneWidget);
      expect(find.text('Afternoon Break'), findsOneWidget);
    },
  );
}
