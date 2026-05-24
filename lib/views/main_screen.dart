// Main screen — matches the A1-all-on.html wireframe.
//
// STEP 5: layout only, using AppSettings.defaults() as static data.
// No toggles or buttons do anything yet — that's Step 6.
//
// Structure:
//   ┌── header ───────────── Title + subtitle ── [global switch ↓ ALL ON]
//   ├── day chips row ────── Sun  Mon*  Tue  Wed  Thu   F̶r̶i̶  S̶a̶t̶
//   ├── day master card ──── ☑ "Monday timers" + pauses-every-timer subtext
//   ├── legend ────────────── "↓ each break runs every Sun–Thu"
//   ├── dashed separator
//   └── slot list ─────────── 3 break cards (Morning shown with running countdown)
// FAB lives at bottom-right.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/app_settings.dart';
import '../models/weekday.dart';
import 'components/day_chip.dart';
import 'components/pen_controls.dart';
import 'components/slot_card.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ──── Hardcoded demo data for Step 5 ─────────────────────────
    // Phase 3 (Steps 6–7) will replace this with reactive Riverpod state.
    final settings = AppSettings.defaults();
    const today = Weekday.mon;          // pretend today is Monday
    const runningSlotId = 1;             // Morning Break is "running"
    const runningRemaining = '16:42';    // demo countdown remaining
    // ─────────────────────────────────────────────────────────────

    final dayActuallyOn =
        settings.globalEnabled && settings.isDayEnabled(today);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(settings: settings, today: today),
            _DayChipsRow(today: today),
            const SizedBox(height: 4),
            _DayMasterCard(today: today, dayEnabled: settings.isDayEnabled(today)),
            const _Legend(),
            const _DashedSeparator(),
            Expanded(
              child: _SlotList(
                settings: settings,
                dayActuallyOn: dayActuallyOn,
                runningSlotId: runningSlotId,
                runningRemaining: runningRemaining,
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
  const _Header({required this.settings, required this.today});

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
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title + subtitle ──
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
          // ── Global pill switch + label ──
          Column(
            children: [
              GlobalSwitch(on: settings.globalEnabled),
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
// Horizontal row of day pills (Sun–Thu + struck-out Fri/Sat)
// ─────────────────────────────────────────────────────────────────
class _DayChipsRow extends StatelessWidget {
  final Weekday today;
  const _DayChipsRow({required this.today});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
        itemCount: Weekday.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final day = Weekday.values[i];
          return DayChip(day: day, isActive: day == today);
        },
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
  const _DayMasterCard({required this.today, required this.dayEnabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 4, 14, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: dayEnabled
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
          PenCheckbox(checked: dayEnabled),
          const SizedBox(width: 10),
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
                  'pauses every timer just for today',
                  style: GoogleFonts.patrickHand(
                    fontSize: 12,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Legend — the slightly-rotated terracotta annotation
// ─────────────────────────────────────────────────────────────────
class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Transform.rotate(
          angle: -0.035, // ≈ -2°
          child: Text(
            '↓ each break runs every Sun–Thu',
            style: GoogleFonts.caveat(
              fontSize: 14,
              color: AppColors.warning,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Dashed horizontal separator (Flutter has no native dashed border)
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

  const _SlotList({
    required this.settings,
    required this.dayActuallyOn,
    required this.runningSlotId,
    required this.runningRemaining,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 90), // 90 = clears FAB
      itemCount: settings.slots.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final slot = settings.slots[i];
        return SlotCard(
          slot: slot,
          dayActuallyOn: dayActuallyOn,
          runningRemaining:
              slot.id == runningSlotId ? runningRemaining : null,
        );
      },
    );
  }
}
