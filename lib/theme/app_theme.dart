import 'package:flutter/material.dart';

enum NoorTheme { burgundy, emerald, midnightVelvet }

class NoorThemePalette {
  const NoorThemePalette({
    required this.name,
    required this.description,
    required this.gradientStart,
    required this.gradientEnd,
    required this.accent,
  });

  final String name;
  final String description;
  final Color gradientStart;
  final Color gradientEnd;
  final Color accent;

  List<Color> get gradientColors => [gradientStart, gradientEnd];
}

class AppTheme {
  static const Map<NoorTheme, NoorThemePalette> palettes = {
    NoorTheme.burgundy: NoorThemePalette(
      name: 'Burgundy',
      description: 'Maroon & soft gold',
      gradientStart: Color(0xFF1F0A12),
      gradientEnd: Color(0xFF3D1424),
      accent: Color(0xFFE5C158),
    ),
    NoorTheme.emerald: NoorThemePalette(
      name: 'Emerald',
      description: 'Deep green & champagne',
      gradientStart: Color(0xFF0B1F17),
      gradientEnd: Color(0xFF13382B),
      accent: Color(0xFFD4AF37),
    ),
    NoorTheme.midnightVelvet: NoorThemePalette(
      name: 'Midnight Velvet',
      description: 'Navy & silver-rose',
      gradientStart: Color(0xFF0E101C),
      gradientEnd: Color(0xFF1C2036),
      accent: Color(0xFFDFCFBE),
    ),
  };

  static ThemeData buildTheme({
    required NoorTheme theme,
    required Brightness brightness,
  }) {
    final palette = palettes[theme]!;
    final isDark = brightness == Brightness.dark;
    final accent = palette.accent;
    final primary = isDark
        ? accent
        : Color.lerp(palette.gradientEnd, Colors.black, 0.2)!;
    final surface = isDark ? const Color(0xFF20222A) : const Color(0xFFFFFCF7);
    final foreground = isDark ? const Color(0xFFF7F1E8) : const Color(0xFF211B1C);
    final colorScheme = (isDark
            ? const ColorScheme.dark()
            : const ColorScheme.light())
        .copyWith(
      primary: primary,
      onPrimary: isDark ? const Color(0xFF17120B) : Colors.white,
      secondary: accent,
      onSecondary: const Color(0xFF17120B),
      surface: surface,
      onSurface: foreground,
      tertiary: accent,
      error: isDark ? const Color(0xFFFF8A80) : const Color(0xFFB3261E),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primary,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? Colors.transparent : surface.withOpacity(0.92),
        foregroundColor: foreground,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        color: isDark ? surface.withOpacity(0.94) : surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: accent.withOpacity(isDark ? 0.18 : 0.3),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith(
          (states) => states.contains(MaterialState.selected) ? accent : null,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accent,
        thumbColor: accent,
        inactiveTrackColor: accent.withOpacity(0.25),
      ),
      dividerTheme: DividerThemeData(
        color: accent.withOpacity(0.22),
      ),
    );
  }

  static LinearGradient backgroundGradient(
    NoorTheme theme,
    Brightness brightness,
  ) {
    final palette = palettes[theme]!;
    if (brightness == Brightness.dark) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: palette.gradientColors,
      );
    }

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(palette.gradientStart, Colors.white, 0.92)!,
        Color.lerp(palette.gradientEnd, Colors.white, 0.88)!,
      ],
    );
  }
}
