import 'package:flutter/material.dart';

enum NoorTheme {
  sandalwood,
  oliveBranch,
  emeraldArch,
  roseMarble,
  roseLeaves,
}

class NoorThemePalette {
  const NoorThemePalette({
    required this.name,
    required this.description,
    required this.gradientStart,
    required this.gradientEnd,
    required this.accent,
    required this.secondaryAccent,
  });

  final String name;
  final String description;
  final Color gradientStart;
  final Color gradientEnd;
  final Color accent;
  final Color secondaryAccent;

  List<Color> get gradientColors => [gradientStart, gradientEnd];
}

class AppTheme {
  static const Map<NoorTheme, NoorThemePalette> palettes = {
    NoorTheme.sandalwood: NoorThemePalette(
      name: 'Sandalwood',
      description: 'Warm wood & golden accents',
      gradientStart: Color(0xFF2D1B14),
      gradientEnd: Color(0xFF4A2E21),
      accent: Color(0xFFE5C158),
      secondaryAccent: Color(0xFFF4D98B),
    ),
    NoorTheme.oliveBranch: NoorThemePalette(
      name: 'Olive Branch',
      description: 'Deep olive & soft cream',
      gradientStart: Color(0xFF1A211B),
      gradientEnd: Color(0xFF2C352D),
      accent: Color(0xFFE4D8B8),
      secondaryAccent: Color(0xFFD4AF37),
    ),
    NoorTheme.emeraldArch: NoorThemePalette(
      name: 'Emerald Arch',
      description: 'Luxury green & pearl gold',
      gradientStart: Color(0xFF0B221B),
      gradientEnd: Color(0xFF163D30),
      accent: Color(0xFFE9E2D0),
      secondaryAccent: Color(0xFFD4AF37),
    ),
    NoorTheme.roseMarble: NoorThemePalette(
      name: 'Rose Marble',
      description: 'Dusky rose & quartz pink',
      gradientStart: Color(0xFF381F26),
      gradientEnd: Color(0xFF542E38),
      accent: Color(0xFFF3A6B2),
      secondaryAccent: Color(0xFFE7C1C7),
    ),
    NoorTheme.roseLeaves: NoorThemePalette(
      name: 'Rose Leaves',
      description: 'Botanical mauve & soft rose',
      gradientStart: Color(0xFF2E1E24),
      gradientEnd: Color(0xFF422A33),
      accent: Color(0xFFD7B0BA),
      secondaryAccent: Color(0xFFB9C1A9),
    ),
  };

  static ThemeData buildTheme({
    required NoorTheme theme,
    required Brightness brightness,
  }) {
    final palette = palettes[theme]!;
    final isDark = brightness == Brightness.dark;
    final accent = palette.accent;
    final primary = isDark ? palette.accent : palette.gradientEnd;
    final borderColor = primary.withOpacity(isDark ? 0.42 : 0.32);
    final onPrimary = isDark ? const Color(0xFF17120B) : Colors.white;
    final secondary = isDark ? palette.secondaryAccent : palette.gradientEnd;
    final surface = isDark ? const Color(0xFF20222A) : const Color(0xFFFFFCF7);
    final foreground = isDark ? const Color(0xFFF7F1E8) : const Color(0xFF211B1C);
    final colorScheme = (isDark
            ? const ColorScheme.dark()
            : const ColorScheme.light())
        .copyWith(
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: const Color(0xFF17120B),
      surface: surface,
      onSurface: foreground,
      tertiary: palette.secondaryAccent,
      error: isDark ? const Color(0xFFFF8A80) : const Color(0xFFB3261E),
    );
    final textTheme = (isDark
            ? ThemeData.dark().textTheme
            : ThemeData.light().textTheme)
        .apply(bodyColor: foreground, displayColor: foreground);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primary,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: colorScheme,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? Colors.transparent : surface.withOpacity(0.92),
        foregroundColor: foreground,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: accent,
        unselectedItemColor: foreground.withOpacity(0.65),
      ),
      cardTheme: CardTheme(
        color: isDark ? surface.withOpacity(0.94) : surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: borderColor,
            width: 1.2,
          ),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borderColor),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: accent,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          side: BorderSide(color: borderColor),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        textStyle: textTheme.bodyMedium,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark
            ? const Color(0xFF303238)
            : const Color(0xFF263238),
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        labelStyle: TextStyle(color: foreground.withOpacity(0.75)),
        hintStyle: TextStyle(color: foreground.withOpacity(0.55)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1.8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
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
