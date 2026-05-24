// Which day the user is currently viewing on the main screen.
//
// This is UI selection state, NOT configuration state — it doesn't
// belong in AppSettings (it's not persisted, doesn't affect scheduling).
// Tapping a day chip updates this; the day master card reads it to
// know which day's enabled flag to display.
//
// In Step 12 the initial value will come from `DateTime.now().weekday`.
// For now we default to Monday so the screen matches the wireframe.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weekday.dart';

/// StateProvider is the simplest Riverpod provider — holds a single
/// value, exposed for both reading and writing. Perfect for trivial
/// UI state like this.
final selectedDayProvider = StateProvider<Weekday>((ref) => Weekday.mon);
