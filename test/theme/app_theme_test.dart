import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/providers/theme_provider.dart';
import 'package:noor/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('exposes all three requested dark gradient palettes', () {
    expect(AppTheme.palettes.length, 3);
    expect(
      AppTheme.backgroundGradient(
        NoorTheme.burgundy,
        Brightness.dark,
      ).colors,
      const [Color(0xFF1F0A12), Color(0xFF3D1424)],
    );
    expect(
      AppTheme.backgroundGradient(
        NoorTheme.emerald,
        Brightness.dark,
      ).colors,
      const [Color(0xFF0B1F17), Color(0xFF13382B)],
    );
    expect(
      AppTheme.backgroundGradient(
        NoorTheme.midnightVelvet,
        Brightness.dark,
      ).colors,
      const [Color(0xFF0E101C), Color(0xFF1C2036)],
    );
  });

  test('dark palettes use transparent scaffolds so gradients remain visible', () {
    for (final theme in NoorTheme.values) {
      final data = AppTheme.buildTheme(
        theme: theme,
        brightness: Brightness.dark,
      );
      expect(data.scaffoldBackgroundColor, Colors.transparent);
      expect(data.colorScheme.secondary, AppTheme.palettes[theme]!.accent);
    }
  });

  test('selecting the already-selected palette activates its dark gradient', () async {
    SharedPreferences.setMockInitialValues({
      'colorTheme': NoorTheme.emerald.name,
      'isDarkMode': false,
    });
    final provider = ThemeProvider();
    await SharedPreferences.getInstance();

    await provider.setTheme(NoorTheme.emerald);

    expect(provider.themeMode, ThemeMode.dark);
    expect(
      (await SharedPreferences.getInstance()).getBool('isDarkMode'),
      isTrue,
    );
  });
}
