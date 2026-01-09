import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ThemeProvider extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoading = true;
  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;
  ThemeProvider() {
    _loadThemeMode();
  }
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeIndex = prefs.getInt(_themeModeKey) ?? 0;
      _themeMode = ThemeMode.values[themeModeIndex];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme mode: $e');
      _themeMode = ThemeMode.system;
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;
    _themeMode = themeMode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, themeMode.index);
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }
  Future<void> toggleTheme() async {
    switch (_themeMode) {
      case ThemeMode.light:
        await setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        await setThemeMode(ThemeMode.system);
        break;
      case ThemeMode.system:
        await setThemeMode(ThemeMode.light);
        break;
    }
  }
  String get currentThemeName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Jasny';
      case ThemeMode.dark:
        return 'Ciemny';
      case ThemeMode.system:
        return 'Systemowy';
    }
  }
  IconData get currentThemeIcon {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode_rounded;
      case ThemeMode.dark:
        return Icons.dark_mode_rounded;
      case ThemeMode.system:
        return Icons.auto_mode_rounded;
    }
  }
  ThemeMode getEffectiveThemeMode(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      final brightness = MediaQuery.of(context).platformBrightness;
      return brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    }
    return _themeMode;
  }
  bool isCurrentlyDark(BuildContext context) {
    final effectiveMode = getEffectiveThemeMode(context);
    return effectiveMode == ThemeMode.dark;
  }
}
