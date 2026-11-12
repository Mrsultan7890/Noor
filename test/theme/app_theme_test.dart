import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/providers/theme_provider.dart';
import 'package:noor/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('exposes all seven dark gradient palettes', () {
    expect(AppTheme.palettes.length, 7);
    final expectedColors = {
      NoorTheme.sandalwood: const [Color(0xFF2D1B14), Color(0xFF4A2E21)],
      NoorTheme.oliveBranch: const [Color(0xFF1A211B), Color(0xFF2C352D)],
      NoorTheme.emeraldArch: const [Color(0xFF0B221B), Color(0xFF163D30)],
      NoorTheme.roseMarble: const [Color(0xFF381F26), Color(0xFF542E38)],
      NoorTheme.roseLeaves: const [Color(0xFF2E1E24), Color(0xFF422A33)],
      NoorTheme.blueMosque: const [Color(0xFF14263D), Color(0xFF1F5360)],
      NoorTheme.blackStone: const [Color(0xFF101113), Color(0xFF25272A)],
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
      expect(
        _contrastRatio(
          data.colorScheme.primary,
          data.colorScheme.onPrimary,
        ),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(
          data.colorScheme.secondary,
          data.colorScheme.onSecondary,
        ),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(
          data.colorScheme.tertiary,
          data.colorScheme.onTertiary,
        ),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(
          data.colorScheme.error,
          data.colorScheme.surface,
        ),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(
          data.colorScheme.onSurface,
          data.colorScheme.surface,
        ),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(
          data.colorScheme.onSurfaceVariant,
          data.colorScheme.surfaceVariant,
        ),
        greaterThanOrEqualTo(4.5),
      );
      final statusColors = data.extension<NoorStatusColors>()!;
      expect(
        _contrastRatio(statusColors.success, data.colorScheme.surface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(statusColors.warning, data.colorScheme.surface),
        greaterThanOrEqualTo(4.5),
      );
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

  test('light palettes have distinct tinted surfaces and secondary accents',
      () {
    final lightGradients = <List<Color>>[];
    final lightSurfaces = <Color>{};

    for (final theme in NoorTheme.values) {
      final palette = AppTheme.palettes[theme]!;
      final data = AppTheme.buildTheme(
        theme: theme,
        brightness: Brightness.light,
      );
      final gradient = AppTheme.backgroundGradient(theme, Brightness.light);
      lightGradients.add(gradient.colors);
      lightSurfaces.add(data.colorScheme.surface);

      expect(
        gradient.colors,
        [palette.lightGradientStart, palette.lightGradientEnd],
      );
      expect(data.colorScheme.surface, palette.lightSurface);
      expect(data.colorScheme.secondary, palette.lightSecondary);
      expect(data.colorScheme.secondary, isNot(data.colorScheme.primary));
      expect(data.colorScheme.surfaceVariant, isNot(data.colorScheme.surface));
    }

    expect(lightSurfaces, hasLength(NoorTheme.values.length));
    expect(lightGradients.toSet(), hasLength(NoorTheme.values.length));
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

double _contrastRatio(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter =
      firstLuminance > secondLuminance ? firstLuminance : secondLuminance;
  final darker =
      firstLuminance > secondLuminance ? secondLuminance : firstLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}
