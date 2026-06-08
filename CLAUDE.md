# Pavlovian — Workplace Break-Time Reminder App

## Status (read first)
**v1.5.19 shipped.** Core features work end-to-end on HST's test device:
scheduling fires reliably in release mode, survives device reboot, plays
the correct bundled sound, action button on notifications starts the
duration countdown from the lock screen.

**Real-world usage so far: HST only.** The app has been built, installed,
and exercised exclusively on HST's Samsung Galaxy S10 (Android 12). It
has NOT been:
- installed by any colleague,
- tested on any other Android device or OS version,
- exercised against varied vendor skins (Pixel, Xiaomi, OnePlus, etc.),
- soak-tested over multiple days of normal workday use.

Treat "the app works" as "works for HST on one device" — not as
proof of robustness. Bugs around vendor-specific battery management,
notification UX quirks, and timezone edge-cases may still surface
the moment another phone tries it.

**Distribution: GitHub Releases ONLY. The app has never been submitted
to Google Play Store.** GitHub repo is public and has release APKs
attached, so colleagues *could* sideload — but as of this writing none
have. Play Store setup is *prepared* in code (applicationId renamed,
build.gradle.kts configured for keystore-aware release signing) but
the keystore has not been generated, no AAB has been built, and no
Play Console listing exists. See `docs/play-store-setup.md` for the
procedure if/when HST decides to publish.

## Author & user context
- **Author:** HST. Sole developer, sole tester, sole installed user.
  Long-term *intent* is to share with workplace colleagues via GitHub
  Releases sideloading, but no colleague has installed it yet — see
  Status above.
- **Background:** Experienced C / Java programmer. **Pavlovian is HST's
  first mobile / Flutter project.** Explain Flutter / Dart concepts when
  first introduced, using C / Java analogies. Do NOT assume prior
  knowledge of widgets, Riverpod, or pub.dev packages.
- **Toolchain:** VS Code (primary editor) + Android Studio (AVD emulator
  only) + Claude Code (AI assistant).
- **Test device:** Samsung Galaxy S10 (`RF8MB29JMDN`) on Android 12.

## Project location
**`C:\Workspace\AI\Pavlovians`** — flat layout, no `app/` subfolder.

## Naming — Pavlovian vs. "Timers"
- Package / launcher / repo / drawer / splash / Settings header: **Pavlovian**
- **Main screen header text: "Timers"** (intentional — softer everyday
  label, since the app shows wall-clock break times). If asked to
  "change the app name" check which surface is meant — they're not
  the same string.

## What the app does
Up to N configurable break-time alerts per day. Each slot has its own
time, duration, label, start-of-break sound, and enabled flag. A global
end-of-break sound plays when a slot's duration timer expires.

### Factory defaults (after fresh install or "Reset All to Defaults")
| # | Time  | Duration | Label           | Start sound |
|---|-------|----------|-----------------|-------------|
| 1 | 10:00 | 20 min   | Morning Break   | **Rooster** |
| 2 | 12:30 | 45 min   | Lunch Break     | **Rooster** |
| 3 | 15:00 | 20 min   | Afternoon Break | **Rooster** |

End-of-break default sound: **Cuckoo**. Defaults come from
`kDefaultSoundName` and `kDefaultEndSoundName` in `lib/models/app_settings.dart`.

### Three-level enable hierarchy
A timer fires only when **all three** are on:
1. **Global "ALL" pill switch** (top-right header) — kill switch.
2. **Day master checkbox** (card under day chips) — pauses for the day.
3. **Per-slot checkbox** — disables that slot all week.

All 7 days are configurable (no hard Fri/Sat exclusion — that was an
earlier design that got dropped). Days are stored per-day in `perDayEnabled`.

### Per-break countdown
Each slot card has a `▶ start` / `■ clear` button. Start schedules a
one-shot end-of-break notification at `now + slot.durationMinutes` and
shows live `MM:SS` on the card. Clear cancels both.

### Notification action button
Every scheduled break notification carries a `▶ Start countdown` action.
Tapping it works **from the lock screen with the app killed** — a top-
level `@pragma('vm:entry-point')` handler in a background isolate
persists the new countdown to `SharedPreferences` and schedules the end-
of-break notification. When the user later opens the app, the
`didChangeAppLifecycleState(resumed)` hook in `main_screen.dart` calls
`CountdownNotifier.refreshFromDisk()` + `NotificationService.scheduleAll()`
so the UI reflects the new state immediately.

Notification BODY tap (not the action) pops back to MainScreen via
`rootNavigatorKey` in `main.dart`, so the user never lands on Settings/
Diagnostics by accident.

## Tech stack
| Concern | Package | Notes |
|---|---|---|
| State | `flutter_riverpod` | `AsyncNotifier` for settings, `Notifier` for countdowns/selectedDay |
| Persistence | `shared_preferences` | JSON-encoded `AppSettings` + countdowns map |
| Notifications | `flutter_local_notifications` v18.0.1 | **DO NOT upgrade** — v21 has breaking API changes |
| Alarms | (via above plugin) | Uses `AndroidScheduleMode.alarmClock` so it survives Doze + Samsung sleeping |
| Timezones | `timezone` + `flutter_timezone` | Required by `zonedSchedule` |
| Audio preview | `audioplayers` | In-app sound picker preview only |
| Version | `package_info_plus` | Read pubspec version at runtime |
| Icons | `flutter_launcher_icons` | Adaptive icon generator |

## Architecture — MVVM
- `lib/models/`      — Plain Dart data classes. No Flutter imports. No logic.
- `lib/viewmodels/`  — Business logic, Riverpod providers, storage + scheduler calls. No UI imports.
- `lib/views/`       — Flutter widgets only. Reactive. Zero business logic.
- `lib/services/`    — Wrappers for notifications, sound, persistence, logging. Called by ViewModels only.
- Rule: if a widget evaluates business logic, move it to the ViewModel.

## ⚠ Critical Android release-mode lessons (do not relearn)

These cost ~3 days of debugging during v1.5.12 → v1.5.14. Honour them.

### 1. R8 strips Gson generic type info
flutter_local_notifications v18 persists scheduled notifications as JSON
via Gson + `TypeToken<ArrayList<NotificationDetails>>`. In release mode
R8 obfuscates the TypeToken superclass and `getSuperclassTypeParameter()`
throws `RuntimeException: Missing type parameter`. This kills the FIRST
`_plugin.cancel()` call inside `_cancelAllScheduled`, which aborts
`scheduleAll` before a single alarm gets registered.

**Fix:** `android/app/proguard-rules.pro` keeps `Signature` attribute +
Gson + flutter_local_notifications model classes. Do not delete that file.

### 2. R8 strips bundled raw resources
Notification sounds are referenced by string at runtime
(`RawResourceAndroidNotificationSound("chime")`). R8's resource shrinker
can't see those references and strips `chime.wav` etc. Android then
falls back to the system default (Samsung's "Spaceline" on S10).

**Fix:** `android/app/src/main/res/raw/keep.xml` lists every bundled
sound. **When adding a new sound, update keep.xml.**

### 3. Notification channel sound is immutable after creation
Android refuses to change a channel's sound once created. If you change
the sound mapping, you must use a **NEW channel ID**, not modify the
existing one.

Channel IDs encode: `pavlovian_s<slotId>_<soundKey>_v<vibrate>_l<led>_r2`
— the `_r2` suffix is a revision bump. If you change the channel schema
(e.g. add a new property), bump to `_r3` so fresh channels get created
on existing installs.

### 4. SCHEDULE_EXACT_ALARM permission is opaque
On Android 12+ targeting SDK 33+, the manifest declaration is NOT enough
— the user must grant it via Settings → Apps → Pavlovian → Alarms &
Reminders. `requestExactAlarmsPermission()` doesn't grant it; it opens
the system settings page where the user toggles manually.

**Mitigations in code:**
- `canScheduleExactAlarms()` queries current state without prompting.
- Test snackbar shows "exact alarms ON" / "blocked — tap to fix" so the
  user can spot the missing grant immediately.
- `scheduleAll` no longer aborts when exact alarms are denied — it falls
  back to `inexactAllowWhileIdle` so alarms still fire (possibly delayed
  by Doze) instead of silently failing.
- `didChangeAppLifecycleState(resumed)` re-runs `scheduleAll` so granting
  the permission and coming back to the app picks it up.

### 5. `pendingNotificationRequests()` throws in AOT
Even with the Gson fix, this specific query throws in profile/release
mode. Don't surface its result to users — wrap in try/catch and
return -1 silently. The Diagnostics screen suppresses it.

## Notable subsystems

### `lib/services/log_service.dart` + `lib/views/diagnostics_screen.dart`
Ring-buffer logger persisted to SharedPreferences. Every `scheduleAll`,
`fireTest`, and per-slot schedule writes a line. Diagnostics screen
displays persisted settings + permissions + computed next-fire times +
the log. **Open it via long-press on the version label in Settings
header.** This is the single most valuable debug tool in the app — if
the user reports any runtime weirdness, ask them to copy the
Diagnostics snapshot and paste it.

### `kTimeGranularityMin` (in `lib/models/app_settings.dart`)
Single constant controlling minute step for both slot times and durations:
- `1` = current value, single-minute precision for testing
- `5` = the original production granularity

`BreakTime.roundedToNearest(step)`, `SettingsNotifier.setSlotTime/setSlotDuration`,
and `EditDurationSheet._stepMin` all read this. Flip once to change everything.

### Top-level notification handlers
`onBackgroundNotificationResponse` + `onForegroundNotificationResponse`
in `lib/services/notification_service.dart`. Both annotated
`@pragma('vm:entry-point')` so AOT doesn't strip them. They share
`_handleNotificationResponse` which parses payload `start:<slotId>:<dayIdx>`,
loads `AppSettings`, writes the countdown, and schedules end-of-break.

### `rootNavigatorKey` in `lib/main.dart`
`GlobalKey<NavigatorState>` passed to MaterialApp + used by the
foreground tap handler to `popUntil(isFirst)`. Lets the notification
body tap always land on MainScreen.

## Build & run
```
flutter doctor                    # verify toolchain
flutter pub get                   # install dependencies
flutter run                       # debug, attached to device
flutter run --release             # release, attached (useful for testing R8 issues live)
flutter run --profile             # profile, attached, AOT-compiled but VM service still works
flutter build apk --release       # release APK for sideloading
flutter build appbundle --release # AAB for Play Store (needs key.properties)
flutter test                      # 59 tests
flutter clean && flutter pub get  # last-resort fix for stuck builds
```

Release APK at `build/app/outputs/flutter-apk/app-release.apk`.
AAB at `build/app/outputs/bundle/release/app-release.aab`.

## Versioning convention
`pubspec.yaml` uses `MAJOR.MINOR.PATCH+BUILD` where **PATCH == BUILD**
at all times. Bumped **manually** by HST in pubspec.yaml before each
release build (no helper script — `tools/bump_version.dart` referenced
in older docs does not exist).

- MAJOR — stays at 1 for now
- MINOR — feature group / phase complete
- PATCH — monotonic counter, +1 every release build
- BUILD — kept equal to PATCH (Android versionCode)

## Distribution

### GitHub Releases (current channel)
Public repo at https://github.com/hgist/Pavlovian. Always-latest APK URL
that auto-redirects: `https://github.com/hgist/Pavlovian/releases/latest/download/app-release.apk`.

Workflow after a code change:
1. Bump `pubspec.yaml` version + buildNumber.
2. `flutter build apk --release` — verify APK at `build/app/outputs/flutter-apk/`.
3. `git add -A && git commit -m "..."`, `git push`.
4. `git tag -a vX.Y.Z -m "..." && git push origin vX.Y.Z`.
5. `gh release create vX.Y.Z build/app/outputs/flutter-apk/app-release.apk --title "..." --notes "..."`.

`gh` CLI lives at `C:/Program Files/GitHub CLI/gh.exe` (not on PATH in
the bash shell — use the full quoted path).

### Play Store — NOT live, NEVER submitted
The app is not on Google Play. No Play Console listing exists.
Don't reference "Play Store version" as if it exists, and don't
assume any user has installed via Play Store.

What IS done (code-side only):
- applicationId renamed to `com.hst.pavlovian` (was the doubled
  `com.hst.pavlovian.pavlovian` from the Flutter scaffold).
- `build.gradle.kts` reads optional `key.properties` for release
  signing; falls back to debug signing when absent.
- `.gitignore` excludes `key.properties` and `*.jks` / `*.keystore`.

What is NOT done:
- No keystore generated.
- No `key.properties` file created.
- No AAB ever built.
- No Play Console account / app listing.
- No identity verification with Google.

When HST decides to publish, follow **`docs/play-store-setup.md`**
end-to-end — don't re-derive the steps inline.

## Visual style — "hand-drawn notebook" aesthetic
**Aesthetic name (use this term consistently): hand-drawn notebook.**
Sometimes also called "wireframe-as-final-design" or "sketchnote." The
look is a **deliberate, terminal design choice** — paper background,
ink-coloured pen-stroke borders, dashed separators, slight offset drop-
shadows, hand-written fonts, custom-painted controls. Buttons, chips,
checkboxes, and switches are **bespoke pen-stroke widgets**
(`DayChip`, `PenCheckbox`, `GlobalSwitch`, `SlotCard`), NOT Material
components in disguise.

Do **NOT**:
- "Modernise" to Material 3 / Material You.
- Switch to filled Material `ElevatedButton`, `Switch`, `Checkbox`, etc.
- Replace the custom widgets with vanilla Material counterparts.
- Introduce primary-color buttons or branded ripples.
- Suggest a "polish pass with proper Android UI conventions."

The notebook aesthetic IS the brand. The wireframes weren't a
placeholder waiting for a hi-fi pass — they ARE the hi-fi.

- Paper: `#FBF7EE`. Paper-light: `#FFFDF7`. Ink: `#2A2723`.
- Terracotta accent: `#E8A07A`. Warning: `#A8401A`.
- Muted: `#6B655C`. Hairline: `#B7AD9B`.
- Fonts (via `google_fonts`, downloaded at runtime + cached):
  Patrick Hand (body), Architects Daughter (headings),
  Caveat (annotations, button labels), JetBrains Mono (times / version).
- Pen-stroke borders, dashed separators, 2px ink-coloured drop shadows.

### Design source-of-truth
**Six HTML wireframes at the project root** (`A0-splash.html` …
`A5-settings.html`) define the original intent. Refer to these when in
doubt about a screen's structure. They are the original brief, not
just illustrations.

Note that the wireframes reflect the *original* design and have not
been updated for every shipped iteration. Treat them as the **enduring
design contract** (look, structure, philosophy); trust the live code
for fine details that have evolved (e.g. the original `+` FAB and
"edit ›" chevron were both removed; all 7 days are now configurable
instead of the original Sun–Fri).

| File                 | Screen / state                                |
|----------------------|-----------------------------------------------|
| `A0-splash.html`     | Branded loading                               |
| `A1-all-on.html`     | Main — everything active, countdown running   |
| `A2-lunch-off.html`  | Main — one slot disabled all week             |
| `A3-day-paused.html` | Main — day master off                         |
| `A4-all-off.html`    | Main — global kill switch off                 |
| `A5-settings.html`   | Settings                                      |

The newer mockups in `docs/main_screen.html` and `docs/settings_screen.html`
are *snapshots of current state* (v1.5.18+) for sharing with non-devs;
regenerate them after UI-material changes. **The A-files are the design
contract — those mockups are derived works.**

## Project layout
```
C:\Workspace\AI\Pavlovians\
├── lib/
│   ├── main.dart                            # entry + rootNavigatorKey
│   ├── models/                              # AppSettings, BreakSlot, BreakTime, Weekday
│   ├── viewmodels/                          # SettingsNotifier, CountdownNotifier, selectedDay
│   ├── views/                               # MainScreen, SettingsScreen, SplashScreen,
│   │   ├── components/                      #   shared widgets (DayChip, SlotCard, drawer, …)
│   │   ├── dialogs/                         #   bottom sheets (sound, duration, label)
│   │   └── diagnostics_screen.dart          #   hidden via long-press on version label
│   ├── services/
│   │   ├── notification_service.dart        # plugin wrapper + top-level @pragma handlers
│   │   ├── ringtone_picker.dart             # MethodChannel for native Android picker
│   │   ├── settings_repository.dart         # shared_preferences I/O
│   │   ├── sound_catalog.dart               # bundled sound entries
│   │   ├── sound_player.dart                # audioplayers wrapper
│   │   ├── log_service.dart                 # ring-buffer in shared_preferences
│   │   └── app_version.dart                 # package_info_plus provider
│   └── theme/app_theme.dart                 # AppColors + ThemeData
├── assets/
│   ├── icon/                                # launcher + adaptive icon sources
│   └── sounds/                              # bell, chime, ping, soft, rooster, cuckoo
├── android/app/
│   ├── proguard-rules.pro                   # R8 keep rules — CRITICAL
│   ├── src/main/
│   │   ├── kotlin/com/hst/pavlovian/MainActivity.kt
│   │   ├── res/raw/                         # SAME sound files (notification channels)
│   │   │   ├── keep.xml                     # tools:keep, listing every sound — CRITICAL
│   │   │   └── *.wav / *.mp3
│   │   └── AndroidManifest.xml              # permissions + ScheduledNotificationReceiver entries
│   └── build.gradle.kts                     # signing config reads optional key.properties
├── test/                                    # 59 tests across models, services, viewmodels
├── docs/
│   ├── main_screen.html                     # mockup
│   ├── settings_screen.html                 # mockup
│   └── play-store-setup.md                  # Phase 2 procedure
├── README.md                                # GitHub landing + APK badges
├── CLAUDE.md                                # this file
└── pubspec.yaml
```

## Working with HST — preferences captured over time
- **Brief, decisive answers.** HST wants the recommendation + tradeoffs,
  not a survey of every possibility.
- **Instruct, don't drive.** When commands run interactively or affect
  HST's local env (build, install, keystore creation), provide step-by-
  step instructions for HST to run in VS Code. Don't background `flutter
  run` and try to interpret half-captured logs.
- **HST manages pubspec.yaml version bumps.** Don't edit it without
  asking — HST often bumps it themselves between turns.
- **No emojis in code or commits.** README and release notes are fine.
- **Hot-reload is the default** for UI tweaks. Tell HST to hot-reload
  via Save-on-save in VS Code. Only request a full rebuild for sounds,
  manifest, channel schema, or ProGuard rule changes.
- **Diagnostics first.** If something fires (or doesn't fire) on the
  phone, ask HST to long-press the version label and paste the
  Diagnostics snapshot. Don't guess.
- **The verify-after-every-edit loop costs tokens.** Run `flutter analyze`
  + `flutter test` after substantive changes; skip them for cosmetic-
  only tweaks.

## Out of scope
- No cloud sync, no accounts, no auth.
- No iOS build (architecture is kept portable — wrap Android-specific
  code in `services/`).
- **Not on Google Play Store** (sideload-only via GitHub Releases).
  Internal-testing track also unused — no Play Console account exists.
- No `READ_CALENDAR` integration. Day-of-week comes from `DateTime.now()`.
