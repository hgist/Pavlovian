# Pavlovian — Multi-Language Implementation Plan
## English + Russian (v2 target)

Russian is LTR — no layout mirroring required.  
All four steps below are independent; they can be tackled in order or in parallel.

---

## Step 1 — Flutter i18n wiring (one-time setup)

### 1.1 `pubspec.yaml`

Add under `dependencies`:
```yaml
intl: ^0.19.0
```

Add under `flutter:`:
```yaml
flutter:
  generate: true          # enables flutter gen-l10n
  uses-material-design: true
```

### 1.2 `l10n.yaml` (create at project root)

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
```

### 1.3 ARB files

Create `lib/l10n/app_en.arb` and `lib/l10n/app_ru.arb`.  
See **Step 2** for the full string inventory.

### 1.4 `lib/main.dart`

Add to `MaterialApp`:
```dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

MaterialApp(
  ...
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: const [
    Locale('en'),
    Locale('ru'),
  ],
  ...
)
```

### 1.5 Generate code

```
flutter gen-l10n
```

Re-run after every ARB change. The generated file lives at
`lib/flutter_gen/gen_l10n/app_localizations.dart` and is gitignored.

### 1.6 Language toggle in Settings

Add a **Language** row to the ③ Notifications card (or a new ⑤ Language section).  
Tapping it shows a simple picker: `English` / `Русский`.  
Persist the chosen locale to `SharedPreferences` (key `app_locale`).  
On startup, read it and pass to `MaterialApp.locale`.

---

## Step 2 — ARB string inventory

All user-visible strings grouped by screen. Every key appears in both
`app_en.arb` and `app_ru.arb`.

### Splash screen
| Key | English |
|---|---|
| `splashTagline` | break time reminders |
| `splashByline` | by HST |
| `splashBadge` | every day · configurable |
| `splashLoading` | loading… |

### Main screen — header & day row
| Key | English | Notes |
|---|---|---|
| `mainTitle` | Timers | screen heading |
| `mainSubtitleAllOff` | all timers off | global switch off |
| `mainSubtitleActive` | {count} of {total} active · {day} | pluralised |
| `mainSubtitlePaused` | paused for {day} | day master off |
| `dayMasterTitle` | {day} timers | |
| `dayMasterHint` | pauses every timer just for today | |
| `mainLegend` | ↓ runs on each enabled day | |

### Main screen — slot cards
| Key | English |
|---|---|
| `slotStatusEveryDay` | every enabled day |
| `slotStatusOff` | off — whole week |
| `slotStatusCountdown` | ⏱ {remaining} left |
| `btnStart` | ▶ start |
| `btnClear` | ■ clear |

### Day names (short, used in chips)
| Key | English |
|---|---|
| `daySun` | Sun |
| `dayMon` | Mon |
| `dayTue` | Tue |
| `dayWed` | Wed |
| `dayThu` | Thu |
| `dayFri` | Fri |
| `daySat` | Sat |

### Settings screen
| Key | English |
|---|---|
| `settingsTitle` | Settings |
| `sectionBreakSlots` | ① Break Slots |
| `sectionWorkingDays` | ② Working Days |
| `sectionNotifications` | ③ Notifications |
| `sectionReset` | ④ Reset |
| `slotEditLabel` | edit label › |
| `slotRowBreakTime` | Break time |
| `slotRowDuration` | Duration |
| `slotRowAlertSound` | Alert sound |
| `addBreak` | + Add a break |
| `workingDaysHint` | Timers fire on checked days only. |
| `workingDaysFoot` | tap a day to toggle it on / off |
| `testNotifTitle` | Test notification |
| `testNotifSub` | fires a sample alert with selected sound |
| `testNotifBtn` | ▶ test |
| `endBreakSound` | End-of-break sound |
| `vibrateOnAlert` | Vibrate on alert |
| `flashLedOnAlert` | Flash LED on alert |
| `resetTitle` | Reset All to Defaults |
| `resetSub` | restores times, durations & sounds |
| `resetAnnotation` | ↑ shows a confirm dialog first |
| `languageLabel` | Language |

### Dialogs
| Key | English |
|---|---|
| `deleteSlotTitle` | Delete "{label}"? |
| `deleteSlotBody` | This break and its alarms will be removed. |
| `btnCancel` | cancel |
| `btnDelete` | delete |
| `resetDialogTitle` | Reset all settings? |
| `resetDialogBody` | All times, durations, labels and toggles return to defaults. Your selected test sound is kept (slot sounds match it). |
| `btnReset` | reset |

### Drawer
| Key | English |
|---|---|
| `drawerTagline` | break time reminders |
| `drawerByline` | by HST |
| `drawerSettings` | Settings |

### Default slot labels (factory defaults only — user edits are untranslated)
| Key | English |
|---|---|
| `defaultSlot1Label` | Morning Break |
| `defaultSlot2Label` | Lunch Break |
| `defaultSlot3Label` | Afternoon Break |

### Notification text (passed to `scheduleAll` / `scheduleBreakEnd`)
| Key | English |
|---|---|
| `notifBreakTitle` | {label} |
| `notifBreakBody` | Break time — it's {time}. Enjoy your {duration} minutes. |
| `notifEndTitle` | {label} |
| `notifEndBody` | Break over — your {duration}-minute break has ended. Time to head back. |
| `notifTestTitle` | Timers Test Alert |
| `notifTestBody` | Testing alert — {sound} sound{vibrate}{led}. |
| `notifActionStart` | ▶ Start countdown |

---

## Step 3 — Font substitution for Cyrillic

Patrick Hand and Architects Daughter contain no Cyrillic glyphs.  
Caveat and JetBrains Mono already cover Cyrillic — no changes needed for those.

### 3.1 Add a font-helper utility

Create `lib/theme/app_fonts.dart`:

```dart
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts {
  static bool _isRussian(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ru';

  /// Replaces Patrick Hand (body copy) — Comfortaa covers full Cyrillic.
  static TextStyle body(BuildContext context, {
    double fontSize = 14,
    Color? color,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return _isRussian(context)
        ? GoogleFonts.comfortaa(fontSize: fontSize, color: color, fontWeight: fontWeight)
        : GoogleFonts.patrickHand(fontSize: fontSize, color: color, fontWeight: fontWeight);
  }

  /// Replaces Architects Daughter (headings) — Caveat covers full Cyrillic.
  static TextStyle heading(BuildContext context, {
    double fontSize = 20,
    Color? color,
    double letterSpacing = 0.3,
  }) {
    return _isRussian(context)
        ? GoogleFonts.caveat(fontSize: fontSize, color: color, letterSpacing: letterSpacing, fontWeight: FontWeight.w600)
        : GoogleFonts.architectsDaughter(fontSize: fontSize, color: color, letterSpacing: letterSpacing);
  }
}
```

### 3.2 Widget migration

Replace direct font calls:

| Before | After |
|---|---|
| `GoogleFonts.patrickHand(...)` | `AppFonts.body(context, ...)` |
| `GoogleFonts.architectsDaughter(...)` | `AppFonts.heading(context, ...)` |

Caveat and JetBrains Mono calls are unchanged.

### 3.3 New Google Fonts to declare in `pubspec.yaml`

```yaml
# Under flutter: fonts: — only needed if pre-bundling; google_fonts fetches at runtime by default.
# No pubspec change required if using google_fonts network fetch (current behaviour).
```

Comfortaa is available from Google Fonts and will be fetched and cached automatically
by the `google_fonts` package on first use — no manual download needed.

---

## Step 4 — Notification text + locale change flow

### 4.1 The problem

Notification bodies are written into Android alarms at `scheduleAll()` time.
Changing the app language after scheduling leaves old-language text in pending alarms.

### 4.2 Fix — reschedule on locale change

In the locale-toggle handler (wherever the user picks Russian / English), immediately
call `scheduleAll()` after persisting the new locale:

```dart
Future<void> setLocale(Locale locale) async {
  await _prefs.setString('app_locale', locale.languageCode);
  // Rebuild the entire alarm set with translated notification text.
  await ref.read(notificationServiceProvider).scheduleAll(
    ref.read(settingsProvider).value!,
  );
}
```

### 4.3 Pass translated strings into `NotificationService`

`NotificationService` has no `BuildContext`. Instead of calling `AppLocalizations`
inside the service, pass the already-resolved strings from the ViewModel:

```dart
// New parameter bag (add to scheduleAll / _scheduleSlotOnDay)
class NotifStrings {
  final String Function(String label, String time, int duration) breakBody;
  final String Function(String label, int duration) endBody;
  final String actionStart;
  // ...
}
```

The ViewModel constructs `NotifStrings` from `AppLocalizations.of(context)` and
passes it down. The service stays context-free and testable.

### 4.4 Default slot labels

Factory defaults are currently hardcoded strings in `AppSettings.defaults()`.
Change them to accept the locale-resolved strings at construction time:

```dart
// In SettingsNotifier.resetToDefaults():
final l = AppLocalizations.of(context);
await notifier.resetToDefaults(
  slot1Label: l.defaultSlot1Label,
  slot2Label: l.defaultSlot2Label,
  slot3Label: l.defaultSlot3Label,
);
```

User-renamed labels are stored verbatim and are never auto-translated — this is
intentional (same behaviour as every major calendar / reminder app).

---

## Implementation order (suggested)

1. Step 1 — wiring + empty ARB files (compiles, no visible change)
2. Step 2 — fill ARB files + replace all hardcoded strings in widgets
3. Step 3 — add `AppFonts` helper + migrate widget font calls
4. Step 4 — pass translated strings to NotificationService + reschedule on change
5. QA pass — test both locales end-to-end on device; verify notifications fire in correct language
