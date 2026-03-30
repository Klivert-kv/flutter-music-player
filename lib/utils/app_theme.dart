import 'package:flutter/material.dart';

abstract class AppColors {
  static const Color primary        = Color(0xFF4169E1);
  // Dark
  static const Color bgDark         = Color(0xFF121212);
  static const Color surfaceDark    = Color(0xFF1E1E1E);
  static const Color surfaceHiDark  = Color(0xFF282828);
  static const Color textPriDark    = Color(0xFFFFFFFF);
  static const Color textSecDark    = Color(0xFFB3B3B3);
  static const Color textDisDark    = Color(0xFF535353);
  static const Color divDark        = Color(0xFF2A2A2A);
  static const Color progBgDark     = Color(0xFF3E3E3E);
  // Light
  static const Color bgLight        = Color(0xFFF5F5F5);
  static const Color surfaceLight   = Color(0xFFFFFFFF);
  static const Color surfaceHiLight = Color(0xFFEEEEEE);
  static const Color textPriLight   = Color(0xFF121212);
  static const Color textSecLight   = Color(0xFF555555);
  static const Color textDisLight   = Color(0xFFAAAAAA);
  static const Color divLight       = Color(0xFFDDDDDD);
  static const Color progBgLight    = Color(0xFFCCCCCC);
}

/// Extensión de colores dinámicos accesible con context.appColors
class AppColorScheme extends ThemeExtension<AppColorScheme> {
  final Color background;
  final Color surface;
  final Color surfaceHigh;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color divider;
  final Color progressBg;

  const AppColorScheme({
    required this.background, required this.surface, required this.surfaceHigh,
    required this.textPrimary, required this.textSecondary, required this.textDisabled,
    required this.divider, required this.progressBg,
  });

  @override
  AppColorScheme copyWith({
    Color? background, Color? surface, Color? surfaceHigh,
    Color? textPrimary, Color? textSecondary, Color? textDisabled,
    Color? divider, Color? progressBg,
  }) => AppColorScheme(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    surfaceHigh: surfaceHigh ?? this.surfaceHigh,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textDisabled: textDisabled ?? this.textDisabled,
    divider: divider ?? this.divider,
    progressBg: progressBg ?? this.progressBg,
  );

  @override
  AppColorScheme lerp(AppColorScheme? other, double t) => this;
}

extension AppColorsX on BuildContext {
  AppColorScheme get ac => Theme.of(this).extension<AppColorScheme>()!;
}

abstract class AppTheme {
  static ThemeData get dark  => _build(true);
  static ThemeData get light => _build(false);

  static ThemeData _build(bool isDark) {
    final bg  = isDark ? AppColors.bgDark         : AppColors.bgLight;
    final sf  = isDark ? AppColors.surfaceDark     : AppColors.surfaceLight;
    final sfH = isDark ? AppColors.surfaceHiDark   : AppColors.surfaceHiLight;
    final tp  = isDark ? AppColors.textPriDark     : AppColors.textPriLight;
    final ts  = isDark ? AppColors.textSecDark     : AppColors.textSecLight;
    final td  = isDark ? AppColors.textDisDark     : AppColors.textDisLight;
    final dv  = isDark ? AppColors.divDark         : AppColors.divLight;
    final pb  = isDark ? AppColors.progBgDark      : AppColors.progBgLight;

    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bg,
      primaryColor: AppColors.primary,
      cardColor: sf,
      dividerColor: dv,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: AppColors.primary, onPrimary: Colors.black,
        secondary: AppColors.primary, onSecondary: Colors.black,
        error: Colors.red, onError: Colors.white,
        surface: sf, onSurface: tp,
      ),
      extensions: [AppColorScheme(
        background: bg, surface: sf, surfaceHigh: sfH,
        textPrimary: tp, textSecondary: ts, textDisabled: td,
        divider: dv, progressBg: pb,
      )],
      appBarTheme: AppBarTheme(
        backgroundColor: bg, elevation: 0, centerTitle: true,
        titleTextStyle: TextStyle(color: tp, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 2),
        iconTheme: IconThemeData(color: tp),
      ),
      iconTheme: IconThemeData(color: tp),
      textTheme: TextTheme(
        titleLarge:  TextStyle(color: tp, fontSize: 20, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: tp, fontSize: 15, fontWeight: FontWeight.w600),
        bodyMedium:  TextStyle(color: ts, fontSize: 14),
        bodySmall:   TextStyle(color: td, fontSize: 12),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: sfH,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        hintStyle: TextStyle(color: td), labelStyle: TextStyle(color: ts),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary, inactiveTrackColor: pb,
        thumbColor: tp,
        overlayColor: AppColors.primary.withValues(alpha: 0.16),
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
      ),
    );
  }
}
