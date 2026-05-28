# Pavlovian — Workplace Break-Time Reminder App

## Project Purpose
A workplace break-time alert app for colleagues. Built in Flutter/Dart for cross-platform
portability. Fires up to 3 configurable notifications per day, **Sunday–Thursday** only
(Friday and Saturday are always off). Each slot has its own time, duration, label, and
alert sound. All data is local — no network, no accounts, no server.

**Author:** HST
**In-app title:** "Timers"
**Project codename:** Pavlovian

## Developer Background
- Experienced C/Java programmer. First mobile / Flutter app project.
- Toolchain: VS Code (primary editor) + Android Studio (AVD/emulator only) + Claude Code (AI assistant).
- Explain Flutter/Dart concepts when first introduced; use C/Java analogies where helpful.
- Do not assume prior knowledge of Flutter APIs, widget tree, or pub.dev packages.

## Project Location
Flutter project files live in **`C:\Workspace\AI\Pavlovians`** alongside the wireframe
HTML files. Do NOT create an `app/` subfolder — keep the layout flat at the project root.

## Tech Stack
- Language: Dart (latest stable)
- Framework: Flutter (latest stable channel)
- Target: Android primary; iOS portability is a future goal — avoid Android-only plugins where possible.
- State management: **Riverpod**
- Local storage: **shared_preferences**
- Notifications: **flutter_local_notifications** + **android_alarm_manager_plus** + **timezone**
- Audio preview: **audioplayers**

## Architecture: MVVM
- `lib/models/`      — Plain Dart data classes. No Flutter imports. No logic.
- `lib/viewmodels/`  — Business logic, Riverpod providers, storage + scheduler calls. No UI imports.
- `lib/views/`       — Flutter widgets only. Reactive. Zero business logic.
- `lib/services/`    — Wrappers for notifications, sound, persistence. Called by ViewModels only.
- **Rule:** if a widget evaluates business logic, move it to the ViewModel.

## Core Features

### Break Slots (factory defaults)
| # | Time  | Duration | Label             | Default Sound |
|---|-------|----------|-------------------|---------------|
| 1 | 10:00 | 20 min   | Morning Break     | **Chime**     |
| 2 | 12:30 | 45 min   | Lunch Break       | **Chime**     |
| 3 | 15:00 | 20 min   | Afternoon Break   | **Chime**     |

- Each slot is independently configurable (time, duration, label, sound, enabled).
- Time picker granularity: **5-minute steps** (00, 05, 10 … 55).
- Same sound plays for that slot on all working days (no per-day sound variation).

### Three-Level Enable Hierarchy
A timer fires **only when all three are ON**:
1. **Global "ALL" pill switch** (top-right of header) — kill switch for the whole app.
2. **Day master checkbox** (card under day chips) — pauses every timer for that day only.
3. **Per-timer checkbox** — disables that specific slot across the whole week.

### Per-Break Countdown
Every active timer row has a **`▶ start` / `■ clear`** button.
- Tapping `▶ start` schedules a one-shot "end of break" notification at `now + duration min`
  and shows a live countdown (`⏱ MM:SS left`) in the card.
- Tapping `■ clear` cancels the countdown and the pending end-of-break notification.

### Day-of-Week Awareness
- Read **system clock only**: `DateTime.now().weekday`.
- **No** `READ_CALENDAR` permission. **No** Calendar app integration. **No** manual day selection.
- The app always knows what day it is via the OS clock.

### Sound Picker
- Scrollable list of bundled sounds (Chime as default + 3–4 alternatives).
- **Preview on tap**: when the user taps a sound in the picker, that sound plays
  *immediately* so they can hear it before confirming the selection.

### Settings & Reset
- Settings screen has a "Reset All to Defaults" action.
- Shows a confirmation dialog before resetting.
- Restoring defaults reverts times, durations, labels, sounds (all → Chime), and enable flags.

### Persistence & Background Behaviour
1. All settings persist across app restarts (`shared_preferences`).
2. Alerts must fire even when the app is **closed / killed** (use `android_alarm_manager_plus` with exact alarms).
3. After **device reboot**, settings must persist *and* scheduled alarms must be re-armed
   automatically via a `RECEIVE_BOOT_COMPLETED` BootReceiver.

## Wireframe Reference (design spec, not shipped)
The design is fully specified in 6 HTML wireframes at the project root:

| File                | Screen                                      |
|---------------------|---------------------------------------------|
| `A0-splash.html`    | Startup / branded loading                   |
| `A1-all-on.html`    | Main — everything active, countdown running |
| `A2-lunch-off.html` | Main — one slot disabled all week           |
| `A3-day-paused.html`| Main — day master off                       |
| `A4-all-off.html`   | Main — global kill switch off               |
| `A5-settings.html`  | Configuration / settings                    |

## Visual Style (wireframe vibe)
- Paper background: `#fbf7ee`
- Ink: `#2a2723`
- Accent (terracotta): `#e8a07a`
- Annotation/warning: `#a8401a`
- Muted: `#6b655c`
- Hairline: `#b7ad9b`

**Fonts** (declared in `pubspec.yaml`):
- `Patrick Hand` — body text / general handwritten
- `Architects Daughter` — headings, app name
- `Caveat` — annotations, button labels, scribbles
- `JetBrains Mono` — times, durations, version strings, technical labels

Visual style: pen-stroke borders, dashed separators, slight offset drop-shadows for a hand-drawn feel.

## Versioning convention
`pubspec.yaml` uses `MAJOR.MINOR.PATCH+BUILD` where **PATCH == BUILD**
(Android versionCode) at all times.

- **MAJOR** — major release / rewrite (manual; stays 1 for now)
- **MINOR** — "app evolvement": bump when a roadmap phase / significant
  feature set is completed. (Baseline minor = 4 = Phases 1–4 done.)
- **PATCH** — monotonic build counter: +1 on EVERY build, never resets
- **BUILD** — kept equal to PATCH

On a minor/major bump the patch/build keep counting (no reset) so the
build number is a true monotonic dev counter.

Bump via the helper (run before each build):
```
dart run tools/bump_version.dart            # = build: patch+1, build=patch
dart run tools/bump_version.dart build      # same
dart run tools/bump_version.dart minor      # minor+1 AND patch+1
dart run tools/bump_version.dart major      # major+1 AND patch+1
dart run tools/bump_version.dart set 1.5.0  # set exact X.Y.Z, build=patch
```
The version is read at runtime by `lib/services/app_version.dart`
(`package_info_plus`) and surfaced via `appVersionProvider`, so the
splash, drawer footer, and settings header always reflect pubspec.yaml.

## Build & Run
```
flutter doctor                      # verify toolchain
flutter pub get                     # install dependencies
flutter run                         # debug run on emulator or device
flutter build apk                   # release APK for sideloading
flutter test                        # unit + widget tests
flutter clean && flutter pub get    # fix broken builds
```
- **Hot reload** (`r` / lightning bolt): re-renders UI, keeps state. Use after widget changes.
- **Hot restart** (`R` / restart button): full restart, resets state. Use after ViewModel/Model changes.
- Release APK: `build/app/outputs/flutter-apk/app-release.apk` — share directly for sideloading.

## Key Constraints
- Sideloaded APK — no Play Store. Colleagues must enable "Install from unknown sources" once.
- No network, no server, no login. Fully local.
- Sound assets: add to `assets/sounds/` AND copy to `android/app/src/main/res/raw/` for
  Android notification channels. Declare in `pubspec.yaml` under `flutter: assets:`.
- Wrap Android-specific code in Services (not ViewModels) to keep the iOS path open.

## Android Gotchas
- Reboot clears alarms — `RECEIVE_BOOT_COMPLETED` BootReceiver must re-schedule them.
- Android 12+: `SCHEDULE_EXACT_ALARM` permission required in `AndroidManifest.xml`.
- Doze mode: use exact alarms; advise colleagues to disable battery optimization for this app.
- Notification channels (Android 8+): one channel per slot; **sound cannot change after channel creation** —
  changing a slot's sound means destroying and recreating that channel.
- Enforce 5-min granularity in the ViewModel, not just the UI picker.
- Enforce Friday/Saturday exclusion in the scheduling Service, not just the UI.
- Request `POST_NOTIFICATIONS` runtime permission on Android 13+.

## Development Roadmap
See `dev-roadmap.html` for the full 6-phase / 16-step plan. One step per session.
Each step produces something runnable on the emulator.

| Phase | Steps  | Outcome                                                |
|-------|--------|--------------------------------------------------------|
| 1     | 1–3    | Splash screen launches with right look                 |
| 2     | 4–5    | Main screen looks like A1, nothing interactive yet     |
| 3     | 6–7    | All 4 main-screen states work and persist              |
| 4     | 8–10   | Times, durations, sounds editable with preview         |
| 5     | 11–13  | Real alerts fire on schedule; countdowns work          |
| 6     | 14–16  | Works when app is closed; survives reboot; APK ready   |

## Project Layout (target)
```
C:\Workspace\AI\Pavlovians\
├── lib/
│   ├── models/        # data classes (BreakSlot, AppSettings)
│   ├── viewmodels/    # logic + Riverpod providers
│   ├── views/         # widgets (screens + components)
│   ├── services/      # notifications, storage, sound, scheduler
│   └── main.dart
├── assets/
│   ├── sounds/        # chime.mp3 (default) + alternatives
│   └── fonts/         # Patrick Hand, Architects Daughter, Caveat, JetBrains Mono
├── android/app/src/main/
│   ├── res/raw/       # same sounds for notification channels
│   └── AndroidManifest.xml
├── test/
│   └── viewmodels/    # unit tests: scheduling logic, enable hierarchy
├── pubspec.yaml
├── CLAUDE.md          ← this file
├── A0-splash.html     ← wireframe reference
├── A1-all-on.html
├── A2-lunch-off.html
├── A3-day-paused.html
├── A4-all-off.html
├── A5-settings.html
├── dev-roadmap.html   ← development plan
└── dev-setup-guide.html
```

## Out of Scope
- No per-day sound variation (each slot plays one sound for all its working days).
- No cloud sync, no user accounts, no authentication.
- No Play Store release at this stage.
- No iOS build yet — keep architecture portable.
- No Calendar (`READ_CALENDAR`) integration — system clock is sufficient.
- No per-day-distinct timer lists — one shared schedule across all working days.
