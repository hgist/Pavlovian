// Pavlovian — main entry point.
//
// STEP 5: showing MainScreen directly so we can verify the A1 layout.
// The splash → main navigation flow will be wired back in a later
// polish step (the splash widget code is still in views/splash_screen.dart).

import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'views/main_screen.dart';

void main() {
  runApp(const PavlovianApp());
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
