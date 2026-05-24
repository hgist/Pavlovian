// A single break-slot row card on the main screen.
//
// Visual variants:
//   - normal (active, not running)  : paper-light bg, ink border, dark shadow
//   - running                       : warmer bg + terracotta shadow
//   - dim (day paused OR per-timer off) : faded, no shadow, time struck through

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/break_slot.dart';
import 'pen_controls.dart';

class SlotCard extends StatelessWidget {
  final BreakSlot slot;

  /// Effective day-on state — globalEnabled && day master on.
  /// Pre-computed by the parent so this widget stays dumb.
  final bool dayActuallyOn;

  /// If not null, this slot has an active end-of-break countdown
  /// and we should show the remaining time + the "■ clear" button.
  /// Format: "MM:SS".
  final String? runningRemaining;

  const SlotCard({
    super.key,
    required this.slot,
    required this.dayActuallyOn,
    this.runningRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final dim = !dayActuallyOn || !slot.enabled;
    final running = runningRemaining != null && !dim;

    // Choose card background based on state.
    final Color cardBg;
    if (dim) {
      cardBg = AppColors.ink.withValues(alpha: 0.04);
    } else if (running) {
      cardBg = const Color(0xFFFFF8F2); // warm tinted paper
    } else {
      cardBg = AppColors.paperLight;
    }

    // Shadow: hidden when dim, terracotta when running, ink-soft otherwise.
    final List<BoxShadow>? shadow = dim
        ? null
        : [
            BoxShadow(
              color: running
                  ? AppColors.terracotta
                  : AppColors.ink.withValues(alpha: 0.15),
              offset: const Offset(2, 2),
              blurRadius: 0,
            ),
          ];

    return Opacity(
      opacity: dim ? 0.5 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cardBg,
          border: Border.all(color: AppColors.ink, width: 2),
          borderRadius: BorderRadius.circular(14),
          boxShadow: shadow,
        ),
        child: Row(
          children: [
            // ── Per-slot enable checkbox ──────────────────────────
            PenCheckbox(checked: slot.enabled, small: true),
            const SizedBox(width: 10),

            // ── Time + duration stacked ───────────────────────────
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.time.toDisplay(),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 20,
                    color: AppColors.ink,
                    height: 1.1,
                    decoration: dim
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                Text(
                  '${slot.durationMinutes} min',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    color: AppColors.inkMuted,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),

            // ── Label + status (takes remaining width) ────────────
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot.label,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.patrickHand(
                      fontSize: 14,
                      color: AppColors.ink,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    running
                        ? '⏱ $runningRemaining left'
                        : (slot.enabled ? 'every Sun–Thu' : 'off — whole week'),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: running ? AppColors.warning : AppColors.inkMuted,
                      fontWeight:
                          running ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),

            // ── Start / Clear button (hidden when dim) ────────────
            if (!dim) ...[
              _BreakButton(running: running),
              const SizedBox(width: 6),
            ],

            // ── Edit chevron ──────────────────────────────────────
            Text(
              'edit ›',
              style: GoogleFonts.caveat(
                fontSize: 15,
                color: AppColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pill-shaped button that flips between "▶ start" and "■ clear".
/// Visual only at this stage.
class _BreakButton extends StatelessWidget {
  final bool running;
  const _BreakButton({required this.running});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: running ? AppColors.terracotta : Colors.transparent,
        border: Border.all(color: AppColors.ink, width: 1.5),
        borderRadius: BorderRadius.circular(8),
        boxShadow: running
            ? const [
                BoxShadow(
                  color: AppColors.ink,
                  offset: Offset(1, 1),
                  blurRadius: 0,
                ),
              ]
            : null,
      ),
      child: Text(
        running ? '■ clear' : '▶ start',
        style: GoogleFonts.caveat(
          fontSize: 12,
          color: AppColors.ink,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
