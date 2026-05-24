# Pavlovian — Timers App

## What it is
A simple Android timers app for a **working day**. Several scheduled alert times fire each day, Sun–Fri. **No timers on Saturday.** User sets each timer's time in 24-hour format.

## Chosen direction
**Option A — Day Tabs + List** (sketchy wireframe, not hi-fi yet).
- Day chips at the top (Sun, Mon, Tue, Wed, Thu, Fri). Saturday is shown crossed-out, not selectable.
- Currently 3 timers per day. Each timer = `{ time (HH:MM, 24h), label }` and applies to every working day.
- FAB (`+`) at bottom-right to add a new timer.
- Each row has a quick "edit ›" affordance.

## Enable / disable hierarchy (rule of thumb)
Three nested scopes — **a timer only fires when ALL three are ON**:

1. **Global ALL switch** (pill switch, top-right of header) — kill switch for the whole app.
2. **Day master checkbox** (card under the day chips) — pauses every timer for just that day.
3. **Per-timer checkbox** (left of each row) — disables that specific time across the whole week (Sun–Fri).

## Visual / aesthetic decisions
- Wireframe vibe: paper bg `#fbf7ee`, ink `#2a2723`, one warm accent `#e8a07a` (terracotta).
- Fonts: Patrick Hand (body/handwritten), Architects Daughter (headings), JetBrains Mono (times/labels), Caveat (annotations).
- Pen-stroke borders, dashed separators, slight offset drop-shadows for a hand-drawn feel.
- No Material chrome yet — phone frame is a plain rounded rectangle with speaker slit + nav pill.

## Files
- `Timers App Wireframes.html` — main file, all four states on a design canvas.
- `states/A1-all-on.html` — global ✓, day ✓, all rows ✓.
- `states/A2-lunch-off.html` — one row unchecked → off all week.
- `states/A3-day-paused.html` — day checkbox off → all rows dim for that day.
- `states/A4-all-off.html` — global switch off → everything dim.
- `states/A5-settings.html` — config settings screen.
- `wireframes/option-a.jsx` — the single screen component, parameterized by `globalEnabled`, `dayEnabled`, `timers[]`.
- `wireframes/phone-frame.jsx` — sketchy phone-frame wrapper.

## Open / next steps
- **Add/edit time picker** — flow for tapping `+` or `edit ›` (24h input). Not designed yet.
- **Notification appearance** — what the actual alert looks like when a timer fires. Not designed yet.
- **Per-day differences?** — current model has one set of timers shared across all working days. If per-day timer lists are needed, the data model changes.
- **Hi-fi pass** — Material 3 styling, real Android components, color/type system, app icon. Deferred.
- **App name** — project is called "Pavlovian"; in-app title is currently "Timers".
