import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _colorIndexKey = 'color_index';
  
  static const List<Color> colorPalette = [
    Color(0xFF2196F3),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFFF44336),
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
    Color(0xFF795548),
    Color(0xFF607D8B),
    Color(0xFFE91E63),
    Color(0xFF3F51B5),
    Color(0xFF009688),
    Color(0xFFFF5722),
  ];
  
  ThemeMode _themeMode = ThemeMode.system;
  int _selectedColorIndex = 0;
  SharedPreferences? _prefs;
  
  ThemeMode get themeMode => _themeMode;
  int get selectedColorIndex => _selectedColorIndex;
  Color get selectedColor => colorPalette[_selectedColorIndex];
  
  ThemeProvider() {
    _loadPreferences();
  }
  
  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    
    final savedThemeMode = _prefs?.getString(_themeModeKey);
    if (savedThemeMode != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == savedThemeMode,
        orElse: () => ThemeMode.system,
      );
    }
    
    _selectedColorIndex = _prefs?.getInt(_colorIndexKey) ?? 0;
    
    notifyListeners();
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs?.setString(_themeModeKey, mode.toString());
    notifyListeners();
  }
  
  Future<void> setColorIndex(int index) async {
    if (index >= 0 && index < colorPalette.length) {
      _selectedColorIndex = index;
      await _prefs?.setInt(_colorIndexKey, index);
      notifyListeners();
    }
  }
  
  bool get isDarkMode {
    switch (_themeMode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        return brightness == Brightness.dark;
    }
  }
}