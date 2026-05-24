// Pavlovian — main entry point.
//
// Step 5: showing MainScreen directly so we can verify the A1 layout.
// Step 6: wrapped in ProviderScope so Riverpod providers are available
//         throughout the widget tree.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'views/main_screen.dart';

void main() {
  // ProviderScope is the root of all Riverpod state. Every widget below
  // it (transitively) can read/watch providers via WidgetRef.
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
