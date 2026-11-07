import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  NoorTheme _selectedTheme = NoorTheme.emeraldArch;
  double _arabicFontScale = 1;
  late final Future<void> _initialization;

  ThemeMode get themeMode => _themeMode;
  NoorTheme get selectedTheme => _selectedTheme;
  double get arabicFontScale => _arabicFontScale;
  ThemeData get lightTheme => AppTheme.buildTheme(
        theme: _selectedTheme,
        brightness: Brightness.light,
      );
  ThemeData get darkTheme => AppTheme.buildTheme(
        theme: _selectedTheme,
        brightness: Brightness.dark,
      );
  LinearGradient get backgroundGradient => AppTheme.backgroundGradient(
        _selectedTheme,
        _themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light,
      );

  ThemeProvider() {
    _initialization = _loadTheme();
  }

  ThemeProvider._loaded() {
    _initialization = Future<void>.value();
  }

  Future<void> get initialized => _initialization;

  static Future<ThemeProvider> load() async {
    final provider = ThemeProvider._loaded();
    await provider._loadTheme();
    return provider;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    final storedTheme = prefs.getString('colorTheme');
    final storedFontScale = prefs.getDouble('arabicFontScale') ?? 1;
    _selectedTheme = switch (storedTheme) {
      'burgundy' => NoorTheme.roseMarble,
      'emerald' => NoorTheme.emeraldArch,
      'midnightVelvet' => NoorTheme.oliveBranch,
      _ => NoorTheme.values.firstWhere(
          (theme) => theme.name == storedTheme,
          orElse: () => NoorTheme.emeraldArch,
        ),
    };
    _arabicFontScale = storedFontScale.clamp(0.8, 1.6).toDouble();
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> setTheme(NoorTheme theme) async {
    if (_selectedTheme == theme && _themeMode == ThemeMode.dark) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('colorTheme', theme.name);
    await prefs.setBool('isDarkMode', true);
    _selectedTheme = theme;
    _themeMode = ThemeMode.dark;
    notifyListeners();
  }

  Future<void> setArabicFontScale(double scale) async {
    final safeScale = scale.clamp(0.8, 1.6).toDouble();
    if (_arabicFontScale == safeScale) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('arabicFontScale', safeScale);
    _arabicFontScale = safeScale;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final nextMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', nextMode == ThemeMode.dark);
    _themeMode = nextMode;
    notifyListeners();
  }
}
