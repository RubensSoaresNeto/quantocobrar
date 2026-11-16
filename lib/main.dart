import 'package:flutter/material.dart';

import 'screens/budget_form_screen.dart';
import 'theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadThemeMode();
  runApp(const QuantoCobrarApp());
}

class QuantoCobrarApp extends StatelessWidget {
  const QuantoCobrarApp({super.key});

  ThemeData _theme(Brightness brightness) => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF146C5A),
      brightness: brightness,
    ),
    useMaterial3: true,
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      filled: true,
    ),
  );

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ThemeMode>(
    valueListenable: themeModeNotifier,
    builder: (context, mode, child) => MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quanto Cobrar?',
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: mode,
      home: const BudgetFormScreen(),
    ),
  );
}
