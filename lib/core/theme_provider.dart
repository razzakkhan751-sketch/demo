// ──────────────────────────────────────────────────────────
// theme_provider.dart — Dark/Light Mode Management
// Default: Light mode. Only dark when user enables it.
// ──────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light; // Default: LIGHT mode
  ThemeMode get themeMode => _themeMode;

  /// Returns true if dark mode is active
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider({bool isDarkMode = false}) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  // initializeTheme removed - handled in constructor via main.dart injection

  /// Toggle between dark and light themes
  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }
}
