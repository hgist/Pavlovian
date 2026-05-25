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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/app_settings.dart';
import '../models/weekday.dart';
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
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Couldn\'t load settings:\n$error'),
        ),
      ),
    );
  }
}

/// The real main screen — assumes settings are loaded.
/// This is where Steps 4–6 logic now lives.
class _LoadedScreen extends ConsumerWidget {
  final AppSettings settings;
  const _LoadedScreen({required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(selectedDayProvider);

    // Demo running countdown — still hardcoded; wired in Step 13.
    const runningSlotId = 1;
    const runningRemaining = '16:42';

    final dayActuallyOn =
        settings.globalEnabled && settings.isDayEnabled(today);

    // Notifier — used inside callbacks (read, not watch — we don't
    // want this widget to rebuild when the notifier instance changes).
    final settingsNotifier = ref.read(settingsProvider.notifier);

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
            ),
            _Legend(globalEnabled: settings.globalEnabled),
            const _DashedSeparator(),
            Expanded(
              child: _SlotList(
                settings: settings,
                dayActuallyOn: dayActuallyOn,
                runningSlotId: runningSlotId,
                runningRemaining: runningRemaining,
                onToggleSlot: settingsNotifier.toggleSlot,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // Step 9 — opens add/edit slot sheet
        child: const Icon(Icons.add, size: 28),
      ),
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
    final dayEnabled = settings.isDayEnabled(today);
    final subtitle = !settings.globalEnabled
        ? 'all timers off'
        : dayEnabled
            ? '${settings.enabledSlotCount} of ${settings.slots.length} '
                'active · ${today.label}'
            : 'paused for ${today.label}';

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
                  'Timers',
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
                settings.globalEnabled ? 'ALL ON' : 'ALL OFF',
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
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
          itemCount: Weekday.values.length,
          separatorBuilder: (_, _) => const SizedBox(width: 6),
          itemBuilder: (_, i) {
            final day = Weekday.values[i];
            return DayChip(
              day: day,
              isActive: day == today,
              onTap: day.isWorking ? () => onSelectDay(day) : null,
            );
          },
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

  const _DayMasterCard({
    required this.today,
    required this.dayEnabled,
    required this.globalEnabled,
    required this.onToggleDay,
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
                    '${today.fullName} timers',
                    style: GoogleFonts.patrickHand(
                      fontSize: 15,
                      color: AppColors.ink,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dayEnabled
                        ? 'pauses every timer just for today'
                        : '✕ paused for today',
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
  const _Legend({required this.globalEnabled});

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
              '↓ each break runs every Sun–Thu',
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
  final int runningSlotId;
  final String runningRemaining;
  final void Function(int slotId) onToggleSlot;

  const _SlotList({
    required this.settings,
    required this.dayActuallyOn,
    required this.runningSlotId,
    required this.runningRemaining,
    required this.onToggleSlot,
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
          runningRemaining:
              slot.id == runningSlotId ? runningRemaining : null,
          onToggleEnabled: () => onToggleSlot(slot.id),
        );
      },
    );
  }
}
