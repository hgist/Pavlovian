// Pavlovian — main entry point.
//
// Step 5: showing MainScreen directly so we can verify the A1 layout.
// Step 6: wrapped in ProviderScope so Riverpod providers are available
//         throughout the widget tree.
// Step 7: WidgetsFlutterBinding.ensureInitialized() required because
//         SharedPreferences needs platform-channel access at startup.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'views/main_screen.dart';

void main() {
  // Must be called before any async plugin use (SharedPreferences,
  // notifications, etc.) when running before runApp().
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PavlovianApp()));
}

class PavlovianApp extends StatelessWidget {
  const PavlovianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pavlovian',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const MainScreen(),
    );
  }
}
