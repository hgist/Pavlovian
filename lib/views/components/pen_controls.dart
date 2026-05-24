// Small "pen-stroke" UI controls — the checkbox and the global pill switch.
// Both match the hand-drawn wireframe aesthetic (thick ink borders,
// terracotta fill when active, hard offset shadows for depth).
//
// Visual only at this stage — interactivity (onChanged callbacks)
// is wired in Step 6 when we add Riverpod state management.

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Square checkbox with a hand-drawn check mark drawn via CustomPainter.
/// Pass `small: true` for the in-row variant used inside slot cards.
class PenCheckbox extends StatelessWidget {
  final bool checked;
  final bool small;

  const PenCheckbox({
    super.key,
    required this.checked,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final s = small ? 18.0 : 22.0;
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        color: checked ? AppColors.terracotta : Colors.transparent,
        border: Border.all(color: AppColors.ink, width: 2),
        borderRadius: BorderRadius.circular(5),
      ),
      // Render the check-mark stroke when checked.
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
  }
}

class _CheckPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 14); // SVG coord system is 14x14
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
  const GlobalSwitch({super.key, required this.on});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Positioned(
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
  }
}
