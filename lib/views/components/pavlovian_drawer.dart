// Side drawer — slides in from the left edge (or via the hamburger
// in the main-screen header). Contains the branded header and a
// Settings entry. More items (About, Help, Reset, etc.) can be
// added later without restructuring.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/app_version.dart';
import '../../theme/app_theme.dart';
import '../settings_screen.dart';
import 'bell_icon.dart';
import 'menu_icons.dart';

class PavlovianDrawer extends ConsumerWidget {
  const PavlovianDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appVersion = ref.watch(appVersionProvider);
    return Drawer(
      backgroundColor: AppColors.paperLight,
      width: 280,
      // No rounded corners so the drawer edge matches our flat
      // pen-stroke aesthetic.
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _DrawerHeader(),
            const _DashedDivider(),
            const SizedBox(height: 6),

            // ── Items ────────────────────────────────────────────
            _DrawerItem(
              icon: const GearIcon(size: 22),
              label: 'Settings',
              onTap: () => _handleSettings(context),
            ),

            // (Future items go here — About, Help, Reset, etc.)

            const Spacer(),
            // ── Footer ───────────────────────────────────────────
            const _DashedDivider(),
            // Attribution for the bundled sounds — sits above the
            // version line so anyone curious about the defaults finds
            // the credits instantly. Rooster = factory start-of-break;
            // cuckoo = factory end-of-break.
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
              child: Text(
                'rooster sound attribute to\nRibhav Agrawal @ pixabay.com'
                '\n\ncuckoo sound attribute to\nMonkay @ freesound.org',
                style: GoogleFonts.caveat(
                  fontSize: 13,
                  color: AppColors.inkMuted,
                  letterSpacing: 0.2,
                  height: 1.2,
                ),
              ),
            ),
            // Separator between credits block and version line.
            const _DashedDivider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
              child: Text(
                appVersion.display,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: AppColors.inkHairline,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Closes the drawer, then pushes the settings screen onto the
  /// nav stack. User can return via the ← back arrow in its header.
  void _handleSettings(BuildContext context) {
    Navigator.of(context).pop(); // close drawer first
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Drawer header — bell + app name + tagline + byline
// ─────────────────────────────────────────────────────────────────
class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      color: AppColors.paper,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Small bell in a circle, smaller than the splash version
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.paperLight,
              border: Border.all(color: AppColors.ink, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.12),
                  offset: const Offset(2, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: const Center(child: BellIcon(size: 34)),
          ),
          const SizedBox(height: 12),
          Text(
            'Pavlovian',
            style: GoogleFonts.architectsDaughter(
              fontSize: 24,
              color: AppColors.ink,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'break time reminders',
            style: GoogleFonts.patrickHand(
              fontSize: 13,
              color: AppColors.inkMuted,
            ),
          ),
          Text(
            'by HST',
            style: GoogleFonts.caveat(
              fontSize: 13,
              color: AppColors.inkHairline,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// One tappable row — icon + label + chevron
// ─────────────────────────────────────────────────────────────────
class _DrawerItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            SizedBox(width: 24, height: 24, child: Center(child: icon)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.patrickHand(
                  fontSize: 16,
                  color: AppColors.ink,
                ),
              ),
            ),
            Text(
              '›',
              style: GoogleFonts.caveat(
                fontSize: 18,
                color: AppColors.inkHairline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Reuse the dashed-line look from main screen
// ─────────────────────────────────────────────────────────────────
class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
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
