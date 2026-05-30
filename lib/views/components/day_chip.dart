// A single day chip in the horizontal day-picker row.
//
// Three visual variants based on the day:
//   - active   : the selected day — solid ink fill, paper text, drop shadow
//   - working  : another selectable weekday — outlined pill, terracotta dot
//   - off      : Fri/Sat — no border, struck-through hairline mono text
//
// Step 6: working chips now accept `onTap` to switch the active day.
//         Fri/Sat chips ignore onTap (non-interactive).

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/weekday.dart';

class DayChip extends StatelessWidget {
  final Weekday day;
  final bool isActive;
  final VoidCallback? onTap;

  const DayChip({
    super.key,
    required this.day,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Non-working day → struck-through, non-tappable. With
    // `isWorking` currently returning true for all 7 days this
    // branch is dormant — kept as a defensive fallback.
    if (!day.isWorking) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          day.label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 13,
            color: AppColors.inkHairline,
            decoration: TextDecoration.lineThrough,
            decorationColor: AppColors.inkHairline,
          ),
        ),
      );
    }

    // Working day pill (Sun–Thu) — tappable
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? AppColors.ink : Colors.transparent,
              border: Border.all(color: AppColors.ink, width: 2),
              borderRadius: BorderRadius.circular(999),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.ink.withValues(alpha: 0.2),
                        offset: const Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Text(
              day.label,
              style: TextStyle(
                fontSize: 14,
                color: isActive ? AppColors.paper : AppColors.ink,
              ),
            ),
          ),
          if (!isActive)
            const Positioned(
              top: 2,
              right: 4,
              child: _Dot(),
            ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      decoration: const BoxDecoration(
        color: AppColors.terracotta,
        shape: BoxShape.circle,
      ),
    );
  }
}
