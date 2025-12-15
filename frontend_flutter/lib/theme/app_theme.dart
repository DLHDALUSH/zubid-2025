import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary color (used as default)
  static const Color primary = Color(0xFFFF6B35);
  static const Color secondary = Color(0xFFFF9F1C);

  // Orange Gradient Theme - Light Mode
  static const Color primaryLight = Color(0xFFFF6B35);
  static const Color primaryDarkLight = Color(0xFFE55A2B);
  static const Color primaryLightLight = Color(0xFFFF8C5A);
  static const Color secondaryLight = Color(0xFFFF9F1C);
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF4A4A4A);
  static const Color textMutedLight = Color(0xFF9E9E9E);

  // Orange Gradient Theme - Dark Mode
  static const Color primaryDark = Color(0xFFFF8C5A);
  static const Color primaryDarkDark = Color(0xFFFF6B35);
  static const Color primaryLightDark = Color(0xFFFFB088);
  static const Color secondaryDark = Color(0xFFFFB347);
  static const Color backgroundDark = Color(0xFF0D0D0D);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color cardDark = Color(0xFF242424);
  static const Color textPrimaryDark = Color(0xFFF5F5F5);
  static const Color textSecondaryDark = Color(0xFFBDBDBD);
  static const Color textMutedDark = Color(0xFF757575);

  // Common
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF9F1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradientDark = LinearGradient(
    colors: [Color(0xFFFF8C5A), Color(0xFFFFB347)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryLight,
      secondary: AppColors.secondaryLight,
      surface: AppColors.surfaceLight,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.textPrimaryLight,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    cardColor: AppColors.cardLight,
    textTheme: GoogleFonts.cairoTextTheme().copyWith(
      headlineLarge: GoogleFonts.cairo(color: AppColors.textPrimaryLight, fontWeight: FontWeight.bold),
      headlineMedium: GoogleFonts.cairo(color: AppColors.textPrimaryLight, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.cairo(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.cairo(color: AppColors.textPrimaryLight),
      bodyLarge: GoogleFonts.cairo(color: AppColors.textPrimaryLight),
      bodyMedium: GoogleFonts.cairo(color: AppColors.textSecondaryLight),
      bodySmall: GoogleFonts.cairo(color: AppColors.textMutedLight),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundLight,
      foregroundColor: AppColors.textPrimaryLight,
      elevation: 0,
      centerTitle: true,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceLight,
      selectedItemColor: AppColors.primaryLight,
      unselectedItemColor: AppColors.textMutedLight,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardLight,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        side: BorderSide(color: AppColors.primaryLight, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.textMutedLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.textMutedLight.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryDark,
      secondary: AppColors.secondaryDark,
      surface: AppColors.surfaceDark,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.textPrimaryDark,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    cardColor: AppColors.cardDark,
    textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme).copyWith(
      headlineLarge: GoogleFonts.cairo(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold),
      headlineMedium: GoogleFonts.cairo(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.cairo(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.cairo(color: AppColors.textPrimaryDark),
      bodyLarge: GoogleFonts.cairo(color: AppColors.textPrimaryDark),
      bodyMedium: GoogleFonts.cairo(color: AppColors.textSecondaryDark),
      bodySmall: GoogleFonts.cairo(color: AppColors.textMutedDark),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      foregroundColor: AppColors.textPrimaryDark,
      elevation: 0,
      centerTitle: true,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      selectedItemColor: AppColors.primaryDark,
      unselectedItemColor: AppColors.textMutedDark,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryDark,
        side: BorderSide(color: AppColors.primaryDark, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.textMutedDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.textMutedDark.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primaryDark, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}

