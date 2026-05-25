// Small hand-drawn icons for menu/navigation chrome:
//   - HamburgerIcon : the three-line menu button in the main-screen header
//   - GearIcon      : the cog/settings icon used in the drawer's Settings tile
//                     and (later) on the Settings screen header
//
// Both are CustomPainter widgets so they pick up the pen-stroke aesthetic
// without needing image assets.

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────
// Hamburger — three slightly-wobbly horizontal pen strokes
// ─────────────────────────────────────────────────────────────────
class HamburgerIcon extends StatelessWidget {
  final double size;
  final Color color;
  const HamburgerIcon({
    super.key,
    this.size = 22,
    this.color = AppColors.ink,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _HamburgerPainter(color),
    );
  }
}

class _HamburgerPainter extends CustomPainter {
  final Color color;
  _HamburgerPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    // Three horizontal lines with tiny y-perturbations for hand-drawn feel
    canvas.drawLine(Offset(w * 0.16, h * 0.27),
                    Offset(w * 0.84, h * 0.255), paint);
    canvas.drawLine(Offset(w * 0.16, h * 0.50),
                    Offset(w * 0.84, h * 0.515), paint);
    canvas.drawLine(Offset(w * 0.16, h * 0.74),
                    Offset(w * 0.84, h * 0.73), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────
// Gear — centre circle + 8 short radial strokes (matches A5 wireframe)
// ─────────────────────────────────────────────────────────────────
class GearIcon extends StatelessWidget {
  final double size;
  final Color color;
  const GearIcon({
    super.key,
    this.size = 22,
    this.color = AppColors.ink,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GearPainter(color),
    );
  }
}

class _GearPainter extends CustomPainter {
  final Color color;
  _GearPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    // Path coords from the A5 wireframe SVG are in a 22×22 space —
    // scale to whatever pixel size the caller asked for.
    canvas.scale(size.width / 22);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    // Central circle (the gear's hub)
    canvas.drawCircle(const Offset(11, 11), 3.5, paint);

    // 8 radial strokes: 4 cardinal + 4 diagonal
    const lines = [
      [Offset(11, 2),    Offset(11, 4)],     // top
      [Offset(11, 18),   Offset(11, 20)],    // bottom
      [Offset(2, 11),    Offset(4, 11)],     // left
      [Offset(18, 11),   Offset(20, 11)],    // right
      [Offset(4.5, 4.5), Offset(6, 6)],      // top-left
      [Offset(16, 16),   Offset(17.5, 17.5)], // bottom-right
      [Offset(17.5, 4.5), Offset(16, 6)],    // top-right
      [Offset(6, 16),    Offset(4.5, 17.5)], // bottom-left
    ];
    for (final segment in lines) {
      canvas.drawLine(segment[0], segment[1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
