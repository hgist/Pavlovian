// A single day chip in the horizontal day-picker row.
//
// Three visual variants based on the day:
//   - active   : the selected "today" — solid ink fill, paper text, drop shadow
//   - working  : a selectable weekday — outlined pill, terracotta indicator dot
//   - off      : Fri/Sat — no border, struck-through hairline mono text

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/weekday.dart';

class DayChip extends StatelessWidget {
  final Weekday day;
  final bool isActive;

  const DayChip({super.key, required this.day, required this.isActive});

  @override
  Widget build(BuildContext context) {
    // Fri & Sat — non-working, struck through, no pill
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

    // Working day pill (Sun–Thu)
    // Stack lets the terracotta dot escape the pill's top-right corner.
    return Stack(
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
