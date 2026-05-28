// Splash screen — matches the A0-splash.html wireframe.
//
// Two widgets live in this file:
//
//   - SplashScreen : the pure-UI splash widget (StatelessWidget).
//   - SplashGate   : a StatefulWidget that displays SplashScreen for
//                    at least `minDuration`, in parallel waits for
//                    settings to finish loading, then replaces itself
//                    with MainScreen via Navigator.pushReplacement.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_version.dart';
import '../theme/app_theme.dart';
import '../viewmodels/settings_provider.dart';
import 'components/bell_icon.dart';
import 'components/scribble.dart';
import 'main_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paperLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          // CrossAxisAlignment.stretch forces every child to fill the
          // available width — then each child can horizontally centre
          // its own contents independently.
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              SizedBox.shrink(),                   // top spacer
              Center(child: _CenterBranding()),    // centred branding block
              Center(child: _BottomLoading()),     // centred loading block
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Centre block: bell icon + name + underline + tagline + byline + days
// ─────────────────────────────────────────────────────────────────────
class _CenterBranding extends StatelessWidget {
  const _CenterBranding();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Bell circle (with offset dashed ring behind) ────────────
        const _BellInCircle(),
        const SizedBox(height: 16),

        // ── App name ────────────────────────────────────────────────
        Text(
          'Pavlovian',
          style: GoogleFonts.architectsDaughter(
            fontSize: 34,
            color: AppColors.ink,
            letterSpacing: 0.5,
            height: 1.1,
          ),
        ),

        // ── Wavy terracotta underline ───────────────────────────────
        const SizedBox(height: 2),
        const WavyUnderline(),

        // ── Tagline ─────────────────────────────────────────────────
        const SizedBox(height: 10),
        Text(
          'break time reminders',
          style: GoogleFonts.patrickHand(
            fontSize: 15,
            color: AppColors.inkMuted,
          ),
        ),

        // ── Byline ──────────────────────────────────────────────────
        const SizedBox(height: 4),
        Text(
          'by HST',
          style: GoogleFonts.caveat(
            fontSize: 13,
            color: AppColors.inkHairline,
            letterSpacing: 0.5,
          ),
        ),

        // ── Working-days badge ──────────────────────────────────────
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.inkHairline, width: 1.5),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'Sun · Mon · Tue · Wed · Thu · Fri',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              color: AppColors.inkMuted,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

/// Bell icon wrapped in a circular paper frame, with a decorative
/// offset dashed circle peeking out behind. Matches the layered
/// hand-drawn feel of the wireframe.
class _BellInCircle extends StatelessWidget {
  const _BellInCircle();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        children: [
          // Decorative dashed offset ring behind
          Positioned(
            top: 5,
            left: 5,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.inkHairline,
                  width: 2,
                  // Note: BoxDecoration doesn't support dashed borders natively.
                  // For the wireframe spirit, a solid hairline ring is the
                  // closest one-liner; we can swap to a CustomPaint dashed
                  // ring later if it matters visually.
                ),
              ),
            ),
          ),
          // Main bell frame
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.paper,
              border: Border.all(color: AppColors.ink, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.15),
                  offset: const Offset(3, 3),
                  blurRadius: 0, // hard shadow for hand-drawn feel
                ),
              ],
            ),
            child: const Center(child: BellIcon(size: 58)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Bottom block: loading dots + version + "loading…" annotation
// ─────────────────────────────────────────────────────────────────────
class _BottomLoading extends ConsumerWidget {
  const _BottomLoading();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appVersion = ref.watch(appVersionProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const LoadingDots(),
        const SizedBox(height: 14),
        Text(
          appVersion.display,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 9,
            color: AppColors.inkHairline,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 14),
        Transform.rotate(
          angle: -1.5 * math.pi / 180, // -1.5°
          child: Text(
            'loading…',
            style: GoogleFonts.caveat(
              fontSize: 12,
              color: AppColors.inkHairline,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// SplashGate — shows SplashScreen for at least `minDuration`, in
// parallel waits for the AsyncNotifier to finish loading, then
// navigates (replaces, so back button can't return here) to MainScreen.
//
// In tests, pass `Duration.zero` to skip the visible splash entirely.
// ─────────────────────────────────────────────────────────────────────
class SplashGate extends ConsumerStatefulWidget {
  /// Minimum time the splash is displayed before transitioning.
  /// Defaults to 2 seconds (the "branded moment" on cold start).
  final Duration minDuration;

  const SplashGate({
    super.key,
    this.minDuration = const Duration(seconds: 2),
  });

  @override
  ConsumerState<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends ConsumerState<SplashGate> {
  @override
  void initState() {
    super.initState();
    // Kick off the wait-and-navigate flow. We don't `await` here —
    // initState must be synchronous — so we fire and forget.
    _waitThenGoToMain();
  }

  Future<void> _waitThenGoToMain() async {
    // Both timers race in parallel; we wait for both to complete.
    //   1. Disk read of AppSettings (typically 5–20 ms)
    //   2. Min splash display time (typically 2 s)
    // So total time = max(load, splash) — splash is the floor.
    final settingsFuture = ref.read(settingsProvider.future);
    await Future.wait<dynamic>([
      settingsFuture,
      Future<void>.delayed(widget.minDuration),
    ]);

    // `mounted` guards against the widget being disposed mid-await
    // (e.g., test tear-down, hot-restart). Without this we'd risk
    // calling Navigator on a defunct State.
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
