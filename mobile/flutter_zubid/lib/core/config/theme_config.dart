import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeConfig {
  // Font Families - Using system fonts for now
  static const String? poppinsFont = null; // Use system font
  static const String? interFont = null; // Use system font

  // Light Theme Colors
  static const _lightPrimary = Color(0xFF2E7D32);
  static const _lightOnPrimary = Colors.white;
  static const _lightPrimaryContainer = Color(0xFF4CAF50);
  static const _lightSecondary = Color(0xFFFF6B35);
  static const _lightOnSecondary = Colors.white;
  static const _lightSecondaryContainer = Color(0xFFFF8A65);
  static const _lightSurface = Color(0xFFFFFFFF);
  static const _lightOnSurface = Color(0xFF212121);
  static const _lightBackground = Color(0xFFFAFAFA);
  static const _lightOnBackground = Color(0xFF212121);
  static const _lightError = Color(0xFFE53935);
  static const _lightOnError = Colors.white;
  static const _lightTextPrimary = Color(0xFF212121);
  static const _lightTextSecondary = Color(0xFF757575);
  static const _lightTextHint = Color(0xFFBDBDBD);
  static const _lightBorder = Color(0xFFE0E0E0);
  static const _lightDivider = Color(0xFFEEEEEE);

  // Dark Theme Colors
  static const _darkPrimary = Color(0xFF4CAF50);
  static const _darkOnPrimary = Colors.black;
  static const _darkPrimaryContainer = Color(0xFF2E7D32);
  static const _darkSecondary = Color(0xFFFF8A65);
  static const _darkOnSecondary = Colors.black;
  static const _darkSecondaryContainer = Color(0xFFFF6B35);
  static const _darkSurface = Color(0xFF1E1E1E);
  static const _darkOnSurface = Color(0xFFE0E0E0);
  static const _darkBackground = Color(0xFF121212);
  static const _darkOnBackground = Color(0xFFE0E0E0);
  static const _darkError = Color(0xFFEF9A9A);
  static const _darkOnError = Color(0xFF6f1d1b);
  static const _darkTextPrimary = Color(0xFFE0E0E0);
  static const _darkTextSecondary = Color(0xFFBDBDBD);
  static const _darkTextHint = Color(0xFF9E9E9E);
  static const _darkBorder = Color(0xFF424242);
  static const _darkDivider = Color(0xFF424242);

  // Common ThemeData
  static final _commonTheme = ThemeData(
    useMaterial3: true,
    // fontFamily: poppinsFont, // Disabled to use system font
  );

  // Light Theme
  static ThemeData get lightTheme {
    return _commonTheme.copyWith(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _lightPrimary,
        onPrimary: _lightOnPrimary,
        primaryContainer: _lightPrimaryContainer,
        secondary: _lightSecondary,
        onSecondary: _lightOnSecondary,
        secondaryContainer: _lightSecondaryContainer,
        surface: _lightSurface,
        onSurface: _lightOnSurface,
        error: _lightError,
        onError: _lightOnError,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightSurface,
        foregroundColor: _lightTextPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      inputDecorationTheme: _inputDecorationTheme(isDark: false),
      textTheme: _textTheme(_lightTextPrimary, _lightTextSecondary),
      // Add other specific light theme properties here
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return _commonTheme.copyWith(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _darkPrimary,
        onPrimary: _darkOnPrimary,
        primaryContainer: _darkPrimaryContainer,
        secondary: _darkSecondary,
        onSecondary: _darkOnSecondary,
        secondaryContainer: _darkSecondaryContainer,
        surface: _darkSurface,
        onSurface: _darkOnSurface,
        error: _darkError,
        onError: _darkOnError,
      ),
      scaffoldBackgroundColor: _darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkBackground,
        foregroundColor: _darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      inputDecorationTheme: _inputDecorationTheme(isDark: true),
      textTheme: _textTheme(_darkTextPrimary, _darkTextSecondary),
      // Add other specific dark theme properties here
    );
  }

  static InputDecorationTheme _inputDecorationTheme({required bool isDark}) {
    return InputDecorationTheme(
      filled: true,
      fillColor: isDark ? _darkSurface : Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? _darkBorder : _lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? _darkBorder : _lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? _darkPrimary : _lightPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? _darkError : _lightError),
      ),
      hintStyle: TextStyle(color: isDark ? _darkTextHint : _lightTextHint),
      labelStyle: TextStyle(color: isDark ? _darkTextSecondary : _lightTextSecondary),
    );
  }

  static TextTheme _textTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: TextStyle(fontWeight: FontWeight.bold, color: primary),
      displayMedium: TextStyle(fontWeight: FontWeight.bold, color: primary),
      displaySmall: TextStyle(fontWeight: FontWeight.w600, color: primary),
      headlineMedium: TextStyle(fontWeight: FontWeight.w600, color: primary),
      headlineSmall: TextStyle(fontWeight: FontWeight.w600, color: primary),
      titleLarge: TextStyle(fontWeight: FontWeight.w600, color: primary),
      bodyLarge: TextStyle(color: primary),
      bodyMedium: TextStyle(color: primary),
      bodySmall: TextStyle(color: secondary),
      labelLarge: TextStyle(fontWeight: FontWeight.w500, color: primary),
      labelSmall: TextStyle(color: secondary),
    );
  }
}
