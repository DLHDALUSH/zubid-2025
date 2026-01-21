import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/storage_service.dart';

/// Theme mode notifier (Riverpod 3.x)
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Load from storage after the first build so we don't crash the provider
    // if storage isn't ready yet.
    Future.microtask(_loadTheme);
    return ThemeMode.system;
  }

  Future<void> _loadTheme() async {
    try {
      await StorageService.ensureInitialized();
      final savedTheme = StorageService.getThemeMode();
      state = _themeFromString(savedTheme);
    } catch (_) {
      // Keep default ThemeMode.system
    }
  }

  ThemeMode _themeFromString(String themeStr) {
    switch (themeStr) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  String _themeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await StorageService.setThemeMode(_themeToString(mode));
  }

  Future<void> toggleDarkMode(bool isDark) async {
    final mode = isDark ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(mode);
  }

  bool get isDarkMode => state == ThemeMode.dark;
  bool get isLightMode => state == ThemeMode.light;
  bool get isSystemMode => state == ThemeMode.system;
}

/// Provider for theme mode
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

/// Convenience provider for checking if dark mode is enabled
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  return themeMode == ThemeMode.dark;
});
