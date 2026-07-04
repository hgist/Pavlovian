// A single break-slot row card on the main screen.
//
// Visual variants:
//   - normal (active, not running)  : paper-light bg, ink border, dark shadow
//   - running                       : warmer bg + terracotta shadow
//   - dim (day paused OR per-timer off) : faded, no shadow, time struck through

import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
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

  /// Called when the per-timer checkbox is tapped.
  /// Optional so the card can also render as visual-only.
  final VoidCallback? onToggleEnabled;

  /// Called when the ▶ start / ■ clear button is tapped.
  final VoidCallback? onStartClear;

  /// Whether the countdown start/clear control is usable. False when
  /// viewing a day other than the actual current day — a countdown is
  /// a "right now" action, so it's greyed-out and non-tappable for
  /// other days.
  final bool countdownEnabled;

  final AppLocalizations l10n;

  const SlotCard({
    super.key,
    required this.slot,
    required this.dayActuallyOn,
    this.runningRemaining,
    this.onToggleEnabled,
    this.onStartClear,
    this.countdownEnabled = true,
    required this.l10n,
  });

  String _getDisplayLabel() {
    return switch (slot.label) {
      'Morning Break' => l10n.slot_label_default_1,
      'Lunch Break' => l10n.slot_label_default_2,
      'Afternoon Break' => l10n.slot_label_default_3,
      _ => slot.label,
    };
  }

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
            PenCheckbox(
              checked: slot.enabled,
              small: true,
              onTap: onToggleEnabled,
            ),
            const SizedBox(width: 6),

            // ── Time + duration stacked ───────────────────────────
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.time.toDisplay(),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 23,
                    color: AppColors.ink,
                    height: 1.1,
                    decoration: dim
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                Text(
                  '${slot.durationMinutes}${l10n.duration_suffix}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 18,
                    color: AppColors.inkMuted,
                    fontWeight: FontWeight.w700,
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
                    _getDisplayLabel(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.patrickHand(
                      fontSize: 16,
                      color: AppColors.ink,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    running
                        ? '${l10n.slot_status_running}$runningRemaining${l10n.slot_status_left}'
                        : (slot.enabled ? l10n.slot_status_enabled : l10n.slot_status_disabled),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: running ? AppColors.warning : AppColors.inkMuted,
                      fontWeight:
                          running ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 3),

            // ── Start / Clear button (hidden when dim, greyed when
            //     viewing a non-current day) ─────────────────────────
            if (!dim)
              _BreakButton(
                running: running,
                enabled: countdownEnabled,
                onTap: countdownEnabled ? onStartClear : null,
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
  final bool enabled;
  final VoidCallback? onTap;
  const _BreakButton({
    required this.running,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      // Greyed-out when disabled (non-current day).
      opacity: enabled ? 1.0 : 0.3,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: running ? AppColors.terracotta : Colors.transparent,
            border: Border.all(color: AppColors.ink, width: 1.5),
            borderRadius: BorderRadius.circular(9),
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
            running ? AppLocalizations.of(context)!.button_clear : AppLocalizations.of(context)!.button_start,
            style: GoogleFonts.caveat(
              fontSize: 19,
              color: AppColors.ink,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
