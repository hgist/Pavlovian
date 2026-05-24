// Pavlovian — central theme file.
//
// Every screen pulls its colours and fonts from here so the
// hand-drawn wireframe look stays consistent across the app.
//
// For C/Java programmers: think of this file as a static class
// holding constants + a factory method that returns a ThemeData
// (the equivalent of a CSS stylesheet for a Flutter app).

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Wireframe palette — exact hex values from the A0–A5 designs.
class AppColors {
  // Backgrounds
  static const Color paper       = Color(0xFFFBF7EE); // page background
  static const Color paperLight  = Color(0xFFFFFDF7); // card / screen inside phone frame
  static const Color paperShade  = Color(0xFFF0EEE9); // outside-the-phone canvas

  // Ink (text + borders)
  static const Color ink         = Color(0xFF2A2723); // primary text & strokes
  static const Color inkMuted    = Color(0xFF6B655C); // secondary text
  static const Color inkHairline = Color(0xFFB7AD9B); // dashed separators, very faint

  // Accent
  static const Color terracotta  = Color(0xFFE8A07A); // primary accent (checked, FAB, running)
  static const Color warning     = Color(0xFFA8401A); // danger / annotation
}

/// Font family names from Google Fonts — used in `TextStyle.fontFamily`
/// or via the `GoogleFonts.X()` helpers.
class AppFonts {
  static const String body      = 'Patrick Hand';       // body text, general handwritten
  static const String heading   = 'Architects Daughter'; // headings, app name
  static const String accent    = 'Caveat';              // annotations, scribbled labels
  static const String mono      = 'JetBrains Mono';      // times, durations, version
}

/// Builds the app-wide ThemeData. Called once from `MaterialApp`.
ThemeData buildAppTheme() {
  // Base text colour shortcut.
  const ink = AppColors.ink;

  // TextTheme: defines default text styles for headlines / body / labels.
  // We override Flutter's defaults so any Text() widget without an
  // explicit style still ends up in our handwritten fonts.
  final textTheme = TextTheme(
    // Large headlines — app name, screen titles
    displayLarge:   GoogleFonts.architectsDaughter(fontSize: 34, color: ink, letterSpacing: 0.5),
    displayMedium:  GoogleFonts.architectsDaughter(fontSize: 28, color: ink, letterSpacing: 0.4),
    displaySmall:   GoogleFonts.architectsDaughter(fontSize: 22, color: ink, letterSpacing: 0.3),

    // Section headers
    headlineMedium: GoogleFonts.architectsDaughter(fontSize: 20, color: ink),
    headlineSmall:  GoogleFonts.architectsDaughter(fontSize: 15, color: ink),

    // Body text — main written content
    bodyLarge:   GoogleFonts.patrickHand(fontSize: 16, color: ink, height: 1.4),
    bodyMedium:  GoogleFonts.patrickHand(fontSize: 14, color: ink, height: 1.4),
    bodySmall:   GoogleFonts.patrickHand(fontSize: 12, color: AppColors.inkMuted),

    // Labels — buttons, annotations
    labelLarge:  GoogleFonts.caveat(fontSize: 16, color: ink, fontWeight: FontWeight.w600),
    labelMedium: GoogleFonts.caveat(fontSize: 14, color: AppColors.inkMuted),
    labelSmall:  GoogleFonts.jetBrainsMono(fontSize: 10, color: AppColors.inkMuted, letterSpacing: 0.5),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // ColorScheme — Material 3's central colour system.
    // Built from our paper palette so every Material widget
    // (buttons, switches, FAB, etc.) inherits the right tones.
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.terracotta,
      brightness: Brightness.light,
      primary:   AppColors.terracotta,
      onPrimary: AppColors.ink,
      surface:   AppColors.paperLight,
      onSurface: AppColors.ink,
    ),

    scaffoldBackgroundColor: AppColors.paper,
    textTheme: textTheme,

    // AppBar — used on most screens
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.paper,
      foregroundColor: AppColors.ink,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.architectsDaughter(
        fontSize: 22,
        color: AppColors.ink,
        letterSpacing: 0.3,
      ),
    ),

    // Floating Action Button — terracotta with ink border (matches wireframe FAB)
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.terracotta,
      foregroundColor: AppColors.ink,
      elevation: 0,
      shape: CircleBorder(side: BorderSide(color: AppColors.ink, width: 2.5)),
    ),
  );
}
