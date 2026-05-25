// Pavlovian — main entry point.
//
// Cold-start flow:
//   runApp(ProviderScope)
//     → PavlovianApp (MaterialApp with our theme)
//       → SplashGate (shows SplashScreen for ≥ 2 s, awaits settings)
//         → MainScreen (Navigator.pushReplacement)
//
// In tests, pass `splashDuration: Duration.zero` to PavlovianApp
// to skip the visible splash and go straight to MainScreen.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'views/splash_screen.dart';

void main() {
  // Required before any async plugin use (SharedPreferences,
  // notifications, etc.) when running before runApp().
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PavlovianApp()));
}

class PavlovianApp extends StatelessWidget {
  /// How long the splash screen stays visible on cold start before
  /// transitioning to the main screen. Defaults to 2 seconds in
  /// production; tests can pass `Duration.zero`.
  final Duration splashDuration;

  const PavlovianApp({
    super.key,
    this.splashDuration = const Duration(seconds: 2),
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pavlovian',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: SplashGate(minDuration: splashDuration),
    );
  }
}
