import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeConfig {
  // Font Families - Using system fonts for now
  static const String? poppinsFont = null; // Use system font
  static const String? interFont = null; // Use system font

  // ============================================
  // LIGHT THEME COLORS - High Contrast & Readable
  // ============================================
  static const _lightPrimary = Color(0xFF1259C3); // Samsung Blue
  static const _lightOnPrimary = Colors.white;
  static const _lightPrimaryContainer = Color(0xFF4285F4);
  static const _lightSecondary = Color(0xFFFF6B35);
  static const _lightOnSecondary = Colors.white;
  static const _lightSecondaryContainer = Color(0xFFFF8A65);
  static const _lightSurface = Color(0xFFFFFFFF);
  static const _lightOnSurface =
      Color(0xFF1A1A1A); // Darker for better contrast
  static const _lightBackground = Color(0xFFF7F7F7);
  static const _lightOnBackground =
      Color(0xFF1A1A1A); // Darker for better contrast
  static const _lightError = Color(0xFFD32F2F);
  static const _lightOnError = Colors.white;
  static const _lightTextPrimary =
      Color(0xFF1A1A1A); // Near black - maximum contrast
  static const _lightTextSecondary =
      Color(0xFF4A4A4A); // Darker gray - better readability
  static const _lightTextHint = Color(0xFF8A8A8A); // Medium gray
  static const _lightBorder = Color(0xFFE0E0E0);
  static const _lightDivider = Color(0xFFEEEEEE);

  // ============================================
  // DARK THEME COLORS - High Contrast & Readable
  // ============================================
  static const _darkPrimary = Color(0xFF4285F4); // Brighter blue for dark mode
  static const _darkOnPrimary = Colors.white;
  static const _darkPrimaryContainer = Color(0xFF1259C3);
  static const _darkSecondary = Color(0xFFFF8A65);
  static const _darkOnSecondary = Colors.black;
  static const _darkSecondaryContainer = Color(0xFFFF6B35);
  static const _darkSurface = Color(0xFF1E1E1E);
  static const _darkOnSurface = Color(0xFFF5F5F5); // Brighter white
  static const _darkBackground = Color(0xFF121212);
  static const _darkOnBackground = Color(0xFFF5F5F5); // Brighter white
  static const _darkError = Color(0xFFFF6B6B);
  static const _darkOnError = Color(0xFF1A1A1A);
  static const _darkTextPrimary =
      Color(0xFFF5F5F5); // Near white - maximum contrast
  static const _darkTextSecondary =
      Color(0xFFCCCCCC); // Light gray - better readability
  static const _darkTextHint = Color(0xFF9E9E9E);
  static const _darkBorder = Color(0xFF3D3D3D);
  static const _darkDivider = Color(0xFF3D3D3D);

  // Common ThemeData
  static final _commonTheme = ThemeData(
    useMaterial3: true,
    // fontFamily: poppinsFont, // Disabled to use system font
  );

  // ============================================
  // LIGHT THEME - Clean & Readable
  // ============================================
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
      scaffoldBackgroundColor: _lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightSurface,
        foregroundColor: _lightTextPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: _lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
      cardTheme: const CardThemeData(
        color: _lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: _lightBorder, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: _lightDivider,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(
        color: _lightTextPrimary,
        size: 24,
      ),
      inputDecorationTheme: _inputDecorationTheme(isDark: false),
      textTheme: _textTheme(_lightTextPrimary, _lightTextSecondary),
    );
  }

  // ============================================
  // DARK THEME - High Contrast & Comfortable
  // ============================================
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
        titleTextStyle: TextStyle(
          color: _darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
      cardTheme: const CardThemeData(
        color: _darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: _darkBorder, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: _darkDivider,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(
        color: _darkTextPrimary,
        size: 24,
      ),
      inputDecorationTheme: _inputDecorationTheme(isDark: true),
      textTheme: _textTheme(_darkTextPrimary, _darkTextSecondary),
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
        borderSide:
            BorderSide(color: isDark ? _darkPrimary : _lightPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? _darkError : _lightError),
      ),
      hintStyle: TextStyle(color: isDark ? _darkTextHint : _lightTextHint),
      labelStyle:
          TextStyle(color: isDark ? _darkTextSecondary : _lightTextSecondary),
    );
  }

  // ============================================
  // TEXT THEME - Optimized for Readability
  // ============================================
  static TextTheme _textTheme(Color primary, Color secondary) {
    return TextTheme(
      // Display styles - Headlines and large text
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: -0.25,
        height: 1.12,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: 0,
        height: 1.16,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: primary,
        letterSpacing: 0,
        height: 1.22,
      ),
      // Headline styles
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: primary,
        letterSpacing: 0,
        height: 1.25,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: primary,
        letterSpacing: 0,
        height: 1.29,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primary,
        letterSpacing: 0,
        height: 1.33,
      ),
      // Title styles - Section headers
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: primary,
        letterSpacing: 0,
        height: 1.27,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primary,
        letterSpacing: 0.15,
        height: 1.5,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      // Body styles - Main content
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primary,
        letterSpacing: 0.5,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: primary,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondary,
        letterSpacing: 0.4,
        height: 1.33,
      ),
      // Label styles - Buttons and small text
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: primary,
        letterSpacing: 0.5,
        height: 1.33,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: secondary,
        letterSpacing: 0.5,
        height: 1.45,
      ),
    );
  }
}
