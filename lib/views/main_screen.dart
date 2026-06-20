// Main screen — A1/A2/A3/A4 wireframes all reachable from one widget.
//
// Step 6: now a ConsumerWidget — reads AppSettings + selectedDay from
// Riverpod and passes callbacks down to dumb child widgets. The child
// widgets stay StatelessWidget so they don't know Riverpod exists —
// they just receive `bool checked` and `VoidCallback onTap`.
//
// Interactive transitions:
//   - Tap global pill switch → A1 ↔ A4
//   - Tap day master checkbox → A1 ↔ A3
//   - Tap per-slot checkbox  → A1 ↔ A2 (for that slot)
//   - Tap a Sun–Thu chip     → switch active day (A1/A3 for that day)

import 'dart:async';

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/app_settings.dart';
import '../models/break_slot.dart';
import '../models/weekday.dart';
import '../services/notification_service.dart';
import '../viewmodels/countdown_provider.dart';
import '../viewmodels/selected_day_provider.dart';
import '../viewmodels/settings_provider.dart';
import 'components/day_chip.dart';
import 'components/menu_icons.dart';
import 'components/pavlovian_drawer.dart';
import 'components/pen_controls.dart';
import 'components/slot_card.dart';

/// Top-level screen — dispatches on the AsyncValue from the
/// (now async) settings provider. Renders one of three sub-screens
/// depending on whether settings are loading, loaded, or errored.
class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      data: (settings) => _LoadedScreen(settings: settings),
      loading: () => const _LoadingScreen(),
      error: (e, _) => _ErrorScreen(error: e),
    );
  }
}

/// Brief loading screen — shown only for the milliseconds it takes
/// SharedPreferences to read from disk. On most launches the user
/// will not notice it.
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

/// Shown if settings load fails (very unlikely — SharedPreferences
/// returns defaults on parse errors). Visible diagnostic, not pretty.
class _ErrorScreen extends StatelessWidget {
  final Object error;
  const _ErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('${l10n.error_screen_prefix}$error'),
        ),
      ),
    );
  }
}

/// The real main screen — assumes settings are loaded.
/// Stateful so a 1-second ticker can update the live countdown
/// displays and prune expired countdowns.
class _LoadedScreen extends ConsumerStatefulWidget {
  final AppSettings settings;
  const _LoadedScreen({required this.settings});

  @override
  ConsumerState<_LoadedScreen> createState() => _LoadedScreenState();
}

class _LoadedScreenState extends ConsumerState<_LoadedScreen>
    with WidgetsBindingObserver {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Observe app lifecycle so we can pick up countdowns started from
    // a notification's "▶ Start countdown" action while the app was
    // backgrounded / killed.
    WidgetsBinding.instance.addObserver(this);

    // Tick once a second to refresh the MM:SS countdown labels and
    // drop any countdown that has reached zero.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final running = ref.read(countdownProvider);
      if (running.isNotEmpty) {
        ref.read(countdownProvider.notifier).pruneExpired();
        setState(() {}); // recompute remaining-time strings
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.resumed) {
      // Re-read countdowns from disk so the running MM:SS shows up
      // immediately when the user returns from a notification tap.
      // ignore: discarded_futures
      ref.read(countdownProvider.notifier).refreshFromDisk();

      // Re-run scheduleAll() in case the user just granted
      // SCHEDULE_EXACT_ALARM in Settings and came back — without this
      // the permission is now held but no alarms are registered yet.
      final settings = ref.read(settingsProvider).value;
      if (settings != null) {
        // ignore: discarded_futures
        ref.read(notificationServiceProvider).scheduleAll(settings);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    super.dispose();
  }

  /// Format the time left until [end] as MM:SS (clamped at 00:00).
  String _formatRemaining(DateTime end) {
    final diff = end.difference(DateTime.now());
    if (diff.isNegative) return '00:00';
    final m = diff.inMinutes;
    final s = diff.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = widget.settings;
    final today = ref.watch(selectedDayProvider);
    final countdowns = ref.watch(countdownProvider);

    // A countdown is a "right now" action, so the start/clear control
    // is only usable when the viewed day IS the actual current day.
    final actualToday = Weekday.fromDateTime(DateTime.now());
    final isViewingToday = today == actualToday;

    final dayActuallyOn =
        settings.globalEnabled && settings.isDayEnabled(today);

    final settingsNotifier = ref.read(settingsProvider.notifier);
    final countdownNotifier = ref.read(countdownProvider.notifier);

    // Build slotId → "MM:SS" only for countdowns belonging to the
    // currently-viewed day. A countdown started on Wed shows on Wed's
    // view only — not on Thu's, even though it's the same break slot.
    final remainingById = <int, String>{
      for (final slot in settings.slots)
        if (countdowns[CountdownNotifier.keyFor(slot.id, today)]
            case final DateTime end)
          slot.id: _formatRemaining(end),
    };

    return Scaffold(
      drawer: const PavlovianDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              settings: settings,
              today: today,
              onToggleGlobal: settingsNotifier.toggleGlobal,
            ),
            _DayChipsRow(
              today: today,
              globalEnabled: settings.globalEnabled,
              onSelectDay: (d) =>
                  ref.read(selectedDayProvider.notifier).state = d,
            ),
            const SizedBox(height: 4),
            _DayMasterCard(
              today: today,
              dayEnabled: settings.isDayEnabled(today),
              globalEnabled: settings.globalEnabled,
              onToggleDay: () => settingsNotifier.toggleDay(today),
              l10n: l10n,
            ),
            _Legend(globalEnabled: settings.globalEnabled, l10n: l10n),
            const _DashedSeparator(),
            Expanded(
              child: _SlotList(
                settings: settings,
                dayActuallyOn: dayActuallyOn,
                remainingById: remainingById,
                countdownEnabled: isViewingToday,
                onToggleSlot: settingsNotifier.toggleSlot,
                onStartClear: (slot) {
                  // Countdown is tied to the currently-viewed day.
                  if (countdownNotifier.isRunning(slot.id, today)) {
                    countdownNotifier.clear(slot.id, today);
                  } else {
                    countdownNotifier.start(slot, today);
                  }
                  setState(() {}); // reflect immediately
                },
                l10n: l10n,
              ),
            ),
          ],
        ),
      ),
      // FAB removed — slot add/remove lives in Settings now.
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Header — title + subtitle on the left, ALL switch on the right
// ─────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final AppSettings settings;
  final Weekday today;
  final VoidCallback onToggleGlobal;

  const _Header({
    required this.settings,
    required this.today,
    required this.onToggleGlobal,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dayEnabled = settings.isDayEnabled(today);
    final subtitle = !settings.globalEnabled
        ? l10n.subtitle_all_timers_off
        : dayEnabled
            ? '${settings.enabledSlotCount} of ${settings.slots.length} '
                '${l10n.subtitle_active_count} · ${today.label}'
            : '${l10n.subtitle_paused_for} ${today.label}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 14, 14, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hamburger (opens the drawer) ──────────────────────────
          // Builder gives us a context that's a descendant of Scaffold
          // so Scaffold.of(...) can find it.
          Builder(
            builder: (ctx) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Scaffold.of(ctx).openDrawer(),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(4, 6, 8, 4),
                child: HamburgerIcon(size: 22),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.timers_screen_title,
                  style: GoogleFonts.architectsDaughter(
                    fontSize: 22,
                    color: AppColors.ink,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.patrickHand(
                    fontSize: 12,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              GlobalSwitch(on: settings.globalEnabled, onTap: onToggleGlobal),
              const SizedBox(height: 2),
              Text(
                settings.globalEnabled ? l10n.global_all_on : l10n.global_all_off,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  color: AppColors.inkMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Horizontal row of day pills — tappable Sun–Thu + struck Fri/Sat
// ─────────────────────────────────────────────────────────────────
class _DayChipsRow extends StatelessWidget {
  final Weekday today;
  final bool globalEnabled;
  final ValueChanged<Weekday> onSelectDay;

  const _DayChipsRow({
    required this.today,
    required this.globalEnabled,
    required this.onSelectDay,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: globalEnabled ? 1.0 : 0.5,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 4, 10, 0),
        // 7 equal-width cells so the chips spread evenly across the
        // screen — no horizontal scroll, no left-clustering. Each chip
        // fills its cell width so wider glyphs ('M','W') don't make
        // some chips look almost circular while others look like ovals.
        child: Row(
          children: [
            for (final day in Weekday.values)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: DayChip(
                    day: day,
                    isActive: day == today,
                    onTap: day.isWorking ? () => onSelectDay(day) : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Day-master card — checkbox + "Monday timers" + helper text
// ─────────────────────────────────────────────────────────────────
class _DayMasterCard extends StatelessWidget {
  final Weekday today;
  final bool dayEnabled;
  final bool globalEnabled;
  final VoidCallback onToggleDay;
  final AppLocalizations l10n;

  const _DayMasterCard({
    required this.today,
    required this.dayEnabled,
    required this.globalEnabled,
    required this.onToggleDay,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    // Effective on-state: card looks "active" only when both global
    // and per-day are on. When global is off, the whole card dims
    // (opacity 0.55) regardless of per-day state — matches A4 wireframe.
    final dayActuallyOn = globalEnabled && dayEnabled;

    return Opacity(
      opacity: globalEnabled ? 1.0 : 0.55,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 4, 14, 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: dayActuallyOn
              ? AppColors.paperLight
              : AppColors.ink.withValues(alpha: 0.06),
          border: Border.all(color: AppColors.ink, width: 2),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.15),
              offset: const Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            PenCheckbox(checked: dayEnabled, onTap: onToggleDay),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${today.fullName}${l10n.day_master_card_label}',
                    style: GoogleFonts.patrickHand(
                      fontSize: 15,
                      color: AppColors.ink,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dayEnabled
                        ? l10n.day_master_card_pauses
                        : l10n.day_master_card_paused,
                    style: dayEnabled
                        ? GoogleFonts.patrickHand(
                            fontSize: 12, color: AppColors.inkMuted)
                        : GoogleFonts.caveat(
                            fontSize: 13, color: AppColors.warning),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Legend — the slightly-rotated terracotta annotation
// ─────────────────────────────────────────────────────────────────
class _Legend extends StatelessWidget {
  final bool globalEnabled;
  final AppLocalizations l10n;

  const _Legend({required this.globalEnabled, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: globalEnabled ? 1.0 : 0.5,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Transform.rotate(
            angle: -0.035,
            child: Text(
              l10n.legend_annotation,
              style: GoogleFonts.caveat(
                fontSize: 14,
                color: AppColors.warning,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Dashed horizontal separator
// ─────────────────────────────────────────────────────────────────
class _DashedSeparator extends StatelessWidget {
  const _DashedSeparator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 6),
      child: CustomPaint(
        size: const Size(double.infinity, 1.5),
        painter: _DashedLinePainter(),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.inkHairline
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dash = 6.0;
    const gap = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────
// Scrollable list of slot cards (extra bottom padding clears the FAB)
// ─────────────────────────────────────────────────────────────────
class _SlotList extends StatelessWidget {
  final AppSettings settings;
  final bool dayActuallyOn;

  /// slotId → "MM:SS" for slots with a live countdown. Absent = idle.
  final Map<int, String> remainingById;

  /// Whether countdown start/clear is usable (only on the current day).
  final bool countdownEnabled;
  final void Function(int slotId) onToggleSlot;
  final void Function(BreakSlot slot) onStartClear;
  final AppLocalizations l10n;

  const _SlotList({
    required this.settings,
    required this.dayActuallyOn,
    required this.remainingById,
    required this.countdownEnabled,
    required this.onToggleSlot,
    required this.onStartClear,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 90),
      itemCount: settings.slots.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final slot = settings.slots[i];
        return SlotCard(
          slot: slot,
          dayActuallyOn: dayActuallyOn,
          runningRemaining: remainingById[slot.id],
          countdownEnabled: countdownEnabled,
          onToggleEnabled: () => onToggleSlot(slot.id),
          onStartClear: () => onStartClear(slot),
          l10n: l10n,
        );
      },
    );
  }
}
