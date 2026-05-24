// Smoke test: the app boots and the main screen shows expected elements.
//
// Widget tests render the widget tree in a headless test environment —
// no emulator needed. Run with:  flutter test
//
// Note: GoogleFonts may try to fetch fonts over the network. In tests
// it falls back to system fonts and we just check for the text strings.

import 'package:flutter_test/flutter_test.dart';
import 'package:pavlovian/main.dart';

void main() {
  testWidgets(
    'app boots and main screen shows title, ALL switch label, and all 3 slots',
    (tester) async {
      await tester.pumpWidget(const PavlovianApp());
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
