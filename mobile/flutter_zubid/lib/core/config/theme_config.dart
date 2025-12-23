import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeConfig {
  // Font Families
  static const String poppinsFont = 'Poppins';
  static const String interFont = 'Inter';

  // Light Theme Colors
  static const _LightColors {
    static const primary = Color(0xFF2E7D32);
    static const onPrimary = Colors.white;
    static const primaryContainer = Color(0xFF4CAF50);
    static const secondary = Color(0xFFFF6B35);
    static const onSecondary = Colors.white;
    static const secondaryContainer = Color(0xFFFF8A65);
    static const surface = Color(0xFFFFFFFF);
    static const onSurface = Color(0xFF212121);
    static const background = Color(0xFFFAFAFA);
    static const onBackground = Color(0xFF212121);
    static const error = Color(0xFFE53935);
    static const onError = Colors.white;
    static const textPrimary = Color(0xFF212121);
    static const textSecondary = Color(0xFF757575);
    static const textHint = Color(0xFFBDBDBD);
    static const border = Color(0xFFE0E0E0);
    static const divider = Color(0xFFEEEEEE);
  }

  // Dark Theme Colors
  static const _DarkColors {
    static const primary = Color(0xFF4CAF50);
    static const onPrimary = Colors.black;
    static const primaryContainer = Color(0xFF2E7D32);
    static const secondary = Color(0xFFFF8A65);
    static const onSecondary = Colors.black;
    static const secondaryContainer = Color(0xFFFF6B35);
    static const surface = Color(0xFF1E1E1E);
    static const onSurface = Color(0xFFE0E0E0);
    static const background = Color(0xFF121212);
    static const onBackground = Color(0xFFE0E0E0);
    static const error = Color(0xFFEF9A9A);
    static const onError = Color(0xFF6f1d1b);
    static const textPrimary = Color(0xFFE0E0E0);
    static const textSecondary = Color(0xFFBDBDBD);
    static const textHint = Color(0xFF9E9E9E);
    static const border = Color(0xFF424242);
    static const divider = Color(0xFF424242);
  }

  // Common ThemeData
  static final _commonTheme = ThemeData(
    useMaterial3: true,
    fontFamily: poppinsFont,
  );

  // Light Theme
  static ThemeData get lightTheme {
    return _commonTheme.copyWith(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _LightColors.primary,
        onPrimary: _LightColors.onPrimary,
        primaryContainer: _LightColors.primaryContainer,
        secondary: _LightColors.secondary,
        onSecondary: _LightColors.onSecondary,
        secondaryContainer: _LightColors.secondaryContainer,
        surface: _LightColors.surface,
        onSurface: _LightColors.onSurface,
        background: _LightColors.background,
        onBackground: _LightColors.onBackground,
        error: _LightColors.error,
        onError: _LightColors.onError,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _LightColors.surface,
        foregroundColor: _LightColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      inputDecorationTheme: _inputDecorationTheme(isDark: false),
      textTheme: _textTheme(_LightColors.textPrimary, _LightColors.textSecondary),
      // Add other specific light theme properties here
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return _commonTheme.copyWith(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _DarkColors.primary,
        onPrimary: _DarkColors.onPrimary,
        primaryContainer: _DarkColors.primaryContainer,
        secondary: _DarkColors.secondary,
        onSecondary: _DarkColors.onSecondary,
        secondaryContainer: _DarkColors.secondaryContainer,
        surface: _DarkColors.surface,
        onSurface: _DarkColors.onSurface,
        background: _DarkColors.background,
        onBackground: _DarkColors.onBackground,
        error: _DarkColors.error,
        onError: _DarkColors.onError,
      ),
      scaffoldBackgroundColor: _DarkColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: _DarkColors.background,
        foregroundColor: _DarkColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      inputDecorationTheme: _inputDecorationTheme(isDark: true),
      textTheme: _textTheme(_DarkColors.textPrimary, _DarkColors.textSecondary),
      // Add other specific dark theme properties here
    );
  }

  static InputDecorationTheme _inputDecorationTheme({required bool isDark}) {
    return InputDecorationTheme(
      filled: true,
      fillColor: isDark ? _DarkColors.surface : Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? _DarkColors.border : _LightColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? _DarkColors.border : _LightColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? _DarkColors.primary : _LightColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? _DarkColors.error : _LightColors.error),
      ),
      hintStyle: TextStyle(color: isDark ? _DarkColors.textHint : _LightColors.textHint, fontFamily: interFont),
      labelStyle: TextStyle(color: isDark ? _DarkColors.textSecondary : _LightColors.textSecondary, fontFamily: interFont),
    );
  }

  static TextTheme _textTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: TextStyle(fontFamily: poppinsFont, fontWeight: FontWeight.bold, color: primary),
      displayMedium: TextStyle(fontFamily: poppinsFont, fontWeight: FontWeight.bold, color: primary),
      displaySmall: TextStyle(fontFamily: poppinsFont, fontWeight: FontWeight.w600, color: primary),
      headlineMedium: TextStyle(fontFamily: poppinsFont, fontWeight: FontWeight.w600, color: primary),
      headlineSmall: TextStyle(fontFamily: poppinsFont, fontWeight: FontWeight.w600, color: primary),
      titleLarge: TextStyle(fontFamily: poppinsFont, fontWeight: FontWeight.w600, color: primary),
      bodyLarge: TextStyle(fontFamily: interFont, color: primary),
      bodyMedium: TextStyle(fontFamily: interFont, color: primary),
      bodySmall: TextStyle(fontFamily: interFont, color: secondary),
      labelLarge: TextStyle(fontFamily: interFont, fontWeight: FontWeight.w500, color: primary),
      labelSmall: TextStyle(fontFamily: interFont, color: secondary),
    );
  }
}
