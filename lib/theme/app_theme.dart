import 'package:flutter/material.dart';

enum NoorTheme {
  sandalwood,
  oliveBranch,
  emeraldArch,
  roseMarble,
  roseLeaves,
  blueMosque,
  blackStone,
}

class NoorThemePalette {
  const NoorThemePalette({
    required this.name,
    required this.description,
    required this.icon,
    required this.gradientStart,
    required this.gradientEnd,
    required this.lightGradientStart,
    required this.lightGradientEnd,
    required this.lightSurface,
    required this.accent,
    required this.secondaryAccent,
    required this.lightSecondary,
  });

  final String name;
  final String description;
  final IconData icon;
  final Color gradientStart;
  final Color gradientEnd;
  final Color lightGradientStart;
  final Color lightGradientEnd;
  final Color lightSurface;
  final Color accent;
  final Color secondaryAccent;
  final Color lightSecondary;

  List<Color> get gradientColors => [gradientStart, gradientEnd];
}

class AppTheme {
  static const Map<NoorTheme, NoorThemePalette> palettes = {
    NoorTheme.sandalwood: NoorThemePalette(
      name: 'Sandalwood',
      description: 'Warm wood & golden accents',
      icon: Icons.park,
      gradientStart: Color(0xFF2D1B14),
      gradientEnd: Color(0xFF4A2E21),
      lightGradientStart: Color(0xFFF7F0E7),
      lightGradientEnd: Color(0xFFEDE0D1),
      lightSurface: Color(0xFFFFFBF5),
      accent: Color(0xFFE5C158),
      secondaryAccent: Color(0xFFF4D98B),
      lightSecondary: Color(0xFF765619),
    ),
    NoorTheme.oliveBranch: NoorThemePalette(
      name: 'Olive Branch',
      description: 'Deep olive & soft cream',
      icon: Icons.eco,
      gradientStart: Color(0xFF1A211B),
      gradientEnd: Color(0xFF2C352D),
      lightGradientStart: Color(0xFFF2F3EA),
      lightGradientEnd: Color(0xFFE5E9D9),
      lightSurface: Color(0xFFFBFCF6),
      accent: Color(0xFFE4D8B8),
      secondaryAccent: Color(0xFFD4AF37),
      lightSecondary: Color(0xFF685519),
    ),
    NoorTheme.emeraldArch: NoorThemePalette(
      name: 'Emerald Arch',
      description: 'Luxury green & pearl gold',
      icon: Icons.architecture,
      gradientStart: Color(0xFF0B221B),
      gradientEnd: Color(0xFF163D30),
      lightGradientStart: Color(0xFFEFF5F0),
      lightGradientEnd: Color(0xFFDCEBE1),
      lightSurface: Color(0xFFFAFCFA),
      accent: Color(0xFFE9E2D0),
      secondaryAccent: Color(0xFFD4AF37),
      lightSecondary: Color(0xFF685519),
    ),
    NoorTheme.roseMarble: NoorThemePalette(
      name: 'Rose Marble',
      description: 'Dusky rose & quartz pink',
      icon: Icons.diamond,
      gradientStart: Color(0xFF381F26),
      gradientEnd: Color(0xFF542E38),
      lightGradientStart: Color(0xFFF8EEF0),
      lightGradientEnd: Color(0xFFF0DDE1),
      lightSurface: Color(0xFFFFF9FA),
      accent: Color(0xFFF3A6B2),
      secondaryAccent: Color(0xFFE7C1C7),
      lightSecondary: Color(0xFF854552),
    ),
    NoorTheme.roseLeaves: NoorThemePalette(
      name: 'Rose Leaves',
      description: 'Botanical mauve & soft rose',
      icon: Icons.local_florist,
      gradientStart: Color(0xFF2E1E24),
      gradientEnd: Color(0xFF422A33),
      lightGradientStart: Color(0xFFF4EFF1),
      lightGradientEnd: Color(0xFFE9DFE3),
      lightSurface: Color(0xFFFCF9FA),
      accent: Color(0xFFD7B0BA),
      secondaryAccent: Color(0xFFB9C1A9),
      lightSecondary: Color(0xFF70505A),
    ),
    NoorTheme.blueMosque: NoorThemePalette(
      name: 'Blue Mosque',
      description: 'Calm navy & turquoise',
      icon: Icons.water,
      gradientStart: Color(0xFF14263D),
      gradientEnd: Color(0xFF1F5360),
      lightGradientStart: Color(0xFFEDF4F7),
      lightGradientEnd: Color(0xFFD9E9ED),
      lightSurface: Color(0xFFF9FCFD),
      accent: Color(0xFFB8E1DF),
      secondaryAccent: Color(0xFFECCB82),
      lightSecondary: Color(0xFF245F6D),
    ),
    NoorTheme.blackStone: NoorThemePalette(
      name: 'Black Stone',
      description: 'Charcoal & pale marble',
      icon: Icons.texture,
      gradientStart: Color(0xFF101113),
      gradientEnd: Color(0xFF25272A),
      lightGradientStart: Color(0xFFF8F8F7),
      lightGradientEnd: Color(0xFFE6E7E8),
      lightSurface: Color(0xFFFCFCFB),
      accent: Color(0xFFF0F0EE),
      secondaryAccent: Color(0xFFC9CBCD),
      lightSecondary: Color(0xFF484B50),
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
    final secondary = isDark ? palette.secondaryAccent : palette.lightSecondary;
    final borderColor = primary.withOpacity(isDark ? 0.34 : 0.2);
    final onPrimary = isDark ? const Color(0xFF17120B) : Colors.white;
    final surface = isDark
        ? Color.lerp(const Color(0xFF20222A), palette.gradientEnd, 0.12)!
        : palette.lightSurface;
    final foreground =
        isDark ? const Color(0xFFF7F1E8) : const Color(0xFF211B1C);
    final surfaceVariant = isDark
        ? Color.lerp(surface, palette.gradientEnd, 0.32)!
        : Color.lerp(surface, palette.lightSecondary, 0.08)!;
    final success = isDark ? const Color(0xFF9AD6A5) : const Color(0xFF287A45);
    final warning = isDark ? const Color(0xFFFFD180) : const Color(0xFF8A5200);
    final colorScheme =
        (isDark ? const ColorScheme.dark() : const ColorScheme.light())
            .copyWith(
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: isDark ? const Color(0xFF17120B) : Colors.white,
      surface: surface,
      surfaceVariant: surfaceVariant,
      surfaceTint: Colors.transparent,
      onSurface: foreground,
      onSurfaceVariant:
          isDark ? const Color(0xFFD0C9C0) : const Color(0xFF5F5753),
      outline: borderColor,
      outlineVariant: borderColor.withOpacity(0.72),
      primaryContainer: Color.lerp(surface, primary, isDark ? 0.2 : 0.12)!,
      onPrimaryContainer: foreground,
      tertiary: isDark ? palette.secondaryAccent : palette.gradientStart,
      onTertiary: isDark ? const Color(0xFF17120B) : Colors.white,
      error: isDark ? const Color(0xFFFF8A80) : const Color(0xFFB3261E),
    );
    final textTheme =
        (isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme)
            .apply(bodyColor: foreground, displayColor: foreground);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primary,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: colorScheme,
      textTheme: textTheme,
      extensions: [
        NoorStatusColors(success: success, warning: warning),
      ],
      appBarTheme: AppBarTheme(
        backgroundColor:
            isDark ? Colors.transparent : surface.withOpacity(0.92),
        foregroundColor: foreground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: foreground.withOpacity(0.65),
      ),
      cardTheme: CardTheme(
        color: isDark ? surface.withOpacity(0.94) : surface,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
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
        backgroundColor:
            isDark ? const Color(0xFF303238) : const Color(0xFF263238),
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
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary.withOpacity(0.48)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface.withOpacity(isDark ? 0.84 : 0.72),
        selectedColor: primary.withOpacity(isDark ? 0.24 : 0.12),
        disabledColor: surface.withOpacity(0.45),
        secondarySelectedColor: primary.withOpacity(0.18),
        labelStyle: TextStyle(color: foreground),
        secondaryLabelStyle: TextStyle(color: foreground),
        side: BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: primary.withOpacity(0.16),
        circularTrackColor: primary.withOpacity(0.16),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith(
          (states) => states.contains(MaterialState.selected) ? primary : null,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        thumbColor: primary,
        inactiveTrackColor: primary.withOpacity(0.25),
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
      colors: [palette.lightGradientStart, palette.lightGradientEnd],
    );
  }
}

@immutable
class NoorStatusColors extends ThemeExtension<NoorStatusColors> {
  const NoorStatusColors({
    required this.success,
    required this.warning,
  });

  final Color success;
  final Color warning;

  @override
  NoorStatusColors copyWith({Color? success, Color? warning}) =>
      NoorStatusColors(
        success: success ?? this.success,
        warning: warning ?? this.warning,
      );

  @override
  NoorStatusColors lerp(
    covariant NoorStatusColors? other,
    double t,
  ) {
    if (other == null) return this;
    return NoorStatusColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}
