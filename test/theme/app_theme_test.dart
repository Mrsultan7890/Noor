import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/providers/theme_provider.dart';
import 'package:noor/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('exposes the five requested dark gradient palettes', () {
    expect(AppTheme.palettes.length, 5);
    final expectedColors = {
      NoorTheme.sandalwood: const [Color(0xFF2D1B14), Color(0xFF4A2E21)],
      NoorTheme.oliveBranch: const [Color(0xFF1A211B), Color(0xFF2C352D)],
      NoorTheme.emeraldArch: const [Color(0xFF0B221B), Color(0xFF163D30)],
      NoorTheme.roseMarble: const [Color(0xFF381F26), Color(0xFF542E38)],
      NoorTheme.roseLeaves: const [Color(0xFF2E1E24), Color(0xFF422A33)],
    };

    for (final entry in expectedColors.entries) {
      expect(
        AppTheme.backgroundGradient(entry.key, Brightness.dark).colors,
        entry.value,
      );
    }
  });

  test('dark palettes use transparent scaffolds and themed overlays', () {
    for (final theme in NoorTheme.values) {
      final data = AppTheme.buildTheme(
        theme: theme,
        brightness: Brightness.dark,
      );
      expect(data.scaffoldBackgroundColor, Colors.transparent);
      expect(data.colorScheme.primary, AppTheme.palettes[theme]!.accent);
      expect(
        data.bottomNavigationBarTheme.selectedItemColor,
        data.colorScheme.primary,
      );
      expect(
        data.elevatedButtonTheme.style?.foregroundColor?.resolve({}),
        data.colorScheme.onPrimary,
      );
      expect(data.dialogTheme.backgroundColor, data.colorScheme.surface);
      final cardShape = data.cardTheme.shape! as RoundedRectangleBorder;
      expect(cardShape.side.color, data.colorScheme.primary.withOpacity(0.34));
      expect(data.cardTheme.elevation, 1);
      expect(
        data.filledButtonTheme.style?.backgroundColor?.resolve({}),
        data.colorScheme.primary,
      );
      expect(data.progressIndicatorTheme.color, data.colorScheme.primary);
      expect(data.colorScheme.surfaceTint, Colors.transparent);
      expect(
        data.inputDecorationTheme.focusedBorder,
        isA<OutlineInputBorder>(),
      );
      expect(data.bottomSheetTheme.backgroundColor, data.colorScheme.surface);
      expect(data.popupMenuTheme.color, data.colorScheme.surface);
      expect(data.snackBarTheme.contentTextStyle?.color, Colors.white);
    }

    final lightData = AppTheme.buildTheme(
      theme: NoorTheme.emeraldArch,
      brightness: Brightness.light,
    );
    expect(
      lightData.colorScheme.primary,
      AppTheme.palettes[NoorTheme.emeraldArch]!.gradientEnd,
    );
    expect(lightData.colorScheme.onPrimary, Colors.white);
    expect(
      lightData.bottomNavigationBarTheme.selectedItemColor,
      lightData.colorScheme.primary,
    );
    final lightCardShape = lightData.cardTheme.shape! as RoundedRectangleBorder;
    expect(
      lightCardShape.side.color,
      lightData.colorScheme.primary.withOpacity(0.2),
    );
  });

  test('selecting the already-selected palette activates its dark gradient',
      () async {
    SharedPreferences.setMockInitialValues({
      'colorTheme': 'emerald',
      'isDarkMode': false,
    });
    final provider = ThemeProvider();
    await provider.initialized;

    expect(provider.selectedTheme, NoorTheme.emeraldArch);
    await provider.setTheme(NoorTheme.emeraldArch);

    expect(provider.themeMode, ThemeMode.dark);
    expect(
      (await SharedPreferences.getInstance()).getBool('isDarkMode'),
      isTrue,
    );
  });
}
