// Pavlovian — main entry point.
//
// Cold-start flow:
//   runApp(ProviderScope, overrides=[appVersion])
//     → PavlovianApp (MaterialApp with our theme)
//       → SplashGate (shows SplashScreen for ≥ 2 s, awaits settings)
//         → MainScreen (Navigator.pushReplacement)
//
// In tests, pass `splashDuration: Duration.zero` to PavlovianApp
// to skip the visible splash and go straight to MainScreen.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/app_version.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'views/splash_screen.dart';

Future<void> main() async {
  // Required before any async plugin use (SharedPreferences,
  // PackageInfo, notifications, etc.) when running before runApp().
  WidgetsFlutterBinding.ensureInitialized();

  // Load the actual app version from pubspec / Android package
  // metadata once, then inject it through the provider so the
  // whole widget tree gets the real "1.0.X" string.
  final appVersion = await loadAppVersion();

  // Initialize the notification plugin so channels are ready
  // before the first "▶ test" tap. Permission is requested
  // lazily — only when the user actually fires a notification.
  await NotificationService().initialize();

  runApp(ProviderScope(
    overrides: [
      appVersionProvider.overrideWithValue(appVersion),
    ],
    child: const PavlovianApp(),
  ));
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
