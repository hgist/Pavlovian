// Which day the user is currently viewing on the main screen.
//
// This is UI selection state, NOT configuration state — it doesn't
// belong in AppSettings (it's not persisted, doesn't affect scheduling).
// Tapping a day chip updates this; the day master card reads it to
// know which day's enabled flag to display.
//
// Initialised to today's actual weekday from `DateTime.now()`.
// On Fri/Sat the screen self-explains: header subtitle reads
// "paused for Fri/Sat", the day-master card and slot list are
// dimmed — exactly how a non-working day should look.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weekday.dart';

/// Computes the day the app should land on when it first opens.
/// Exposed (not private) so tests can override / verify it.
Weekday initialSelectedDay({DateTime? now}) {
  return Weekday.fromDateTime(now ?? DateTime.now());
}

/// StateProvider — holds the currently-viewed weekday.
/// Initial value is today's weekday.
final selectedDayProvider = StateProvider<Weekday>(
  (ref) => initialSelectedDay(),
);
