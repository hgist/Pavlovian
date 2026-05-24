// Hand-drawn bell icon.
//
// Drawn with CustomPaint (Flutter's low-level drawing API).
// The paths below are a direct translation of the SVG paths in
// the A0-splash.html wireframe — same 80x80 coordinate space.
//
// For C/Java programmers:
//   - CustomPainter is like overriding paint(Graphics g) in Java Swing.
//   - Canvas is the drawing surface; Path is a sequence of moves + curves.
//   - Paint holds colour/stroke/style (like a Java Graphics2D state).

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Renders the bell at the requested size.
/// All path math is in an 80x80 virtual canvas, then scaled to fit.
class BellIcon extends StatelessWidget {
  final double size;
  const BellIcon({super.key, this.size = 58});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _BellPainter(),
    );
  }
}

class _BellPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Scale the 80x80 SVG coordinate space to whatever physical size we got.
    canvas.scale(size.width / 80);

    // Reusable Paint objects ────────────────────────────────────────────
    final inkStroke = Paint()
      ..color = AppColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final terraFill = Paint()
      ..color = AppColors.terracotta.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    // ── Bell body (main rounded shape) ────────────────────────────────
    final body = Path()
      ..moveTo(40, 10)
      ..cubicTo(26, 10, 18, 22, 17, 36)
      ..cubicTo(16, 46, 14, 52, 10, 58)
      ..lineTo(70, 58)
      ..cubicTo(66, 52, 64, 46, 63, 36)
      ..cubicTo(62, 22, 54, 10, 40, 10)
      ..close();
    canvas.drawPath(body, terraFill);
    canvas.drawPath(body, inkStroke);

    // ── Bell top stem (small loop on top) ─────────────────────────────
    final stemStroke = Paint()
      ..color = AppColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final stem = Path()
      ..moveTo(37, 10)
      ..cubicTo(37, 7, 43, 7, 43, 10);
    canvas.drawPath(stem, stemStroke);

    // ── Clapper (small circle hanging below) ──────────────────────────
    final clapperFill = Paint()
      ..color = AppColors.terracotta.withValues(alpha: 0.5);
    final clapperStroke = Paint()
      ..color = AppColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(const Offset(40, 64), 4.5, clapperFill);
    canvas.drawCircle(const Offset(40, 64), 4.5, clapperStroke);

    // ── Motion dashes on both sides (suggest the bell is ringing) ─────
    _drawDashedPath(canvas,
      Path()..moveTo(68, 30)..cubicTo(72, 28, 74, 24, 73, 20));
    _drawDashedPath(canvas,
      Path()..moveTo(12, 30)..cubicTo(8, 28, 6, 24, 7, 20));

    // ── Inner highlight squiggle (subtle shine) ───────────────────────
    final highlight = Paint()
      ..color = AppColors.ink.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    final hl = Path()
      ..moveTo(30, 38)
      ..quadraticBezierTo(36, 34, 42, 38)
      ..quadraticBezierTo(48, 42, 52, 38);
    canvas.drawPath(hl, highlight);
  }

  /// Walks along `path` and draws short dashes by extracting sub-paths.
  /// Equivalent to SVG's stroke-dasharray="2 2".
  void _drawDashedPath(Canvas canvas, Path path) {
    const dash = 2.0;
    const gap = 2.0;
    final paint = Paint()
      ..color = AppColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final next = (dist + dash).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(dist, next), paint);
        dist = next + gap;
      }
    }
  }

  // Bell is static — never needs to repaint.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
