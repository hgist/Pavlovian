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
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';
import 'services/app_version.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'viewmodels/settings_provider.dart';
import 'views/splash_screen.dart';

/// Root navigator key — let non-widget code (e.g. the foreground
/// notification tap handler in `notification_service.dart`) reach the
/// app's navigator to pop back to the Main screen when the user taps
/// a break notification while the app was sitting on Settings or
/// Diagnostics.
final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>();

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

class PavlovianApp extends ConsumerWidget {
  /// How long the splash screen stays visible on cold start before
  /// transitioning to the main screen. Defaults to 2 seconds in
  /// production; tests can pass `Duration.zero`.
  final Duration splashDuration;

  const PavlovianApp({
    super.key,
    this.splashDuration = const Duration(seconds: 2),
  });

  Locale? _parseLocaleCode(String code) {
    if (code == 'auto') return null;
    final parts = code.split('_');
    return Locale(parts[0], parts.length > 1 ? parts[1] : null);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final selectedLocaleCode = settingsAsync.value?.selectedLocaleCode ?? 'auto';

    return MaterialApp(
      title: 'Pavlovian',
      navigatorKey: rootNavigatorKey,
      debugShowCheckedModeBanner: false,
      locale: _parseLocaleCode(selectedLocaleCode),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: buildAppTheme(),
      home: SplashGate(minDuration: splashDuration),
    );
  }
}
