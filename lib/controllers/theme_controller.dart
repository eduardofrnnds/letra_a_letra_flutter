import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const _keyTheme = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeController() {
    _loadThemeMode();
  }

  // Carrega a preferência de tema salva
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_keyTheme) ?? ThemeMode.system.index;
    _themeMode = ThemeMode.values[themeIndex];
    notifyListeners();
  }

  // Define um novo tema e salva a preferência
  Future<void> setThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null || newThemeMode == _themeMode) return;

    _themeMode = newThemeMode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTheme, _themeMode.index);
  }
}
