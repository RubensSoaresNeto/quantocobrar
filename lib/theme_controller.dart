import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

Future<void> loadThemeMode() async {
  final value = (await SharedPreferences.getInstance()).getString('theme_mode');
  themeModeNotifier.value = ThemeMode.values.firstWhere(
    (mode) => mode.name == value,
    orElse: () => ThemeMode.system,
  );
}

Future<void> setThemeMode(ThemeMode mode) async {
  themeModeNotifier.value = mode;
  await (await SharedPreferences.getInstance()).setString(
    'theme_mode',
    mode.name,
  );
}
