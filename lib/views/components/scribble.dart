// Small hand-drawn decorations used across screens.
//
//  - WavyUnderline  : the terracotta squiggle under "Pavlovian" on the splash
//  - LoadingDots    : the three-dot loading indicator at the bottom of splash
//
// Both are CustomPaint widgets (drawn directly on a canvas) so the
// "hand-drawn" feel is built in rather than coming from a bitmap.

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────
// Wavy underline
// ─────────────────────────────────────────────────────────────────────
class WavyUnderline extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final double strokeWidth;

  const WavyUnderline({
    super.key,
    this.width = 140,
    this.height = 8,
    this.color = AppColors.terracotta,
    this.strokeWidth = 2.5,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _WavyPainter(color, strokeWidth),
    );
  }
}

class _WavyPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _WavyPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Two stacked quadratic Beziers create the wavy "M Q T" effect
    // from the SVG <path d="M2 5 Q30 1, 60 5 T118 4">
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(4, h - 3)
      ..quadraticBezierTo(w * 0.25, 1, w * 0.5, h - 3)
      ..quadraticBezierTo(w * 0.75, h, w - 4, h - 4);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────
// Loading dots — three small circles, middle one filled with terracotta
// ─────────────────────────────────────────────────────────────────────
class LoadingDots extends StatelessWidget {
  const LoadingDots({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Dot(filled: false),
        SizedBox(width: 8),
        _Dot(filled: true),
        SizedBox(width: 8),
        _Dot(filled: false),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final bool filled;
  const _Dot({required this.filled});

  @override
  Widget build(BuildContext context) {
    // For C/Java analogy: BoxDecoration is Flutter's equivalent of
    // setting background colour + border on a JComponent.
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled
            ? AppColors.terracotta
            : AppColors.ink.withValues(alpha: 0.3),
        border: Border.all(color: AppColors.ink, width: 1.5),
      ),
    );
  }
}
