// Small "pen-stroke" UI controls — the checkbox and the global pill switch.
//
// Step 5: visual only.
// Step 6: now accept an optional `onTap` callback. When null, the widget
//         is non-interactive; when set, tapping the widget invokes it.
//         Riverpod state lives in MainScreen, not here — these stay
//         dumb presentation widgets.

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Square checkbox with a hand-drawn check mark drawn via CustomPainter.
class PenCheckbox extends StatelessWidget {
  final bool checked;
  final bool small;
  final VoidCallback? onTap;

  const PenCheckbox({
    super.key,
    required this.checked,
    this.small = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = small ? 18.0 : 22.0;
    final box = Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        color: checked ? AppColors.terracotta : Colors.transparent,
        border: Border.all(color: AppColors.ink, width: 2),
        borderRadius: BorderRadius.circular(5),
      ),
      child: checked
          ? Center(
              child: SizedBox(
                width: s - 8,
                height: s - 8,
                child: CustomPaint(painter: _CheckPainter()),
              ),
            )
          : null,
    );

    // Wrap in a GestureDetector with a 4px hit-area padding so the
    // tiny checkbox is easier to tap.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: box,
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 14);
    final paint = Paint()
      ..color = AppColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(2, 7)
      ..lineTo(6, 11)
      ..lineTo(12, 3);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// Pill-shaped toggle switch — the global "ALL" master in the header.
class GlobalSwitch extends StatelessWidget {
  final bool on;
  final VoidCallback? onTap;

  const GlobalSwitch({super.key, required this.on, this.onTap});

  @override
  Widget build(BuildContext context) {
    final pill = Container(
      width: 46,
      height: 24,
      decoration: BoxDecoration(
        color: on ? AppColors.terracotta : Colors.transparent,
        border: Border.all(color: AppColors.ink, width: 2),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.2),
            offset: const Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            top: 1,
            left: on ? 22 : 1,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: AppColors.ink,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: pill,
      ),
    );
  }
}
