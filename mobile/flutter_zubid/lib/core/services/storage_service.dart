import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../utils/logger.dart';
import '../../features/auth/data/models/user_model.dart';

class StorageService {
  static late SharedPreferences _prefs;
  static late Box _secureBox;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Storage Keys
  static const String _keyAuthToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserData = 'user_data';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLanguage = 'language';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyFirstLaunch = 'first_launch';
  static const String _keyLastSyncTime = 'last_sync_time';
  static const String _keyOfflineData = 'offline_data';
  static const String _keySearchHistory = 'search_history';
  static const String _keyFavoriteAuctions = 'favorite_auctions';
  static const String _keyRecentlyViewed = 'recently_viewed';

  /// Initialize storage services
  static Future<void> init() async {
    try {
      AppLogger.info('Initializing storage services...');

      // Initialize SharedPreferences
      _prefs = await SharedPreferences.getInstance();
      AppLogger.info('SharedPreferences initialized');

      // Check if Hive is initialized
      if (!Hive.isBoxOpen('secure_storage')) {
        // Initialize Hive secure box
        _secureBox = await Hive.openBox('secure_storage');
        AppLogger.info('Hive secure box opened');
      } else {
        _secureBox = Hive.box('secure_storage');
        AppLogger.info('Hive secure box already open');
      }

      AppLogger.info('Storage services initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize storage services',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // ==================== Authentication Storage ====================

  /// Save authentication token
  static Future<void> saveAuthToken(String token) async {
    try {
      await _secureStorage.write(key: _keyAuthToken, value: token);
      AppLogger.auth('Auth token saved');
    } catch (e) {
      AppLogger.error('Failed to save auth token', error: e);
      rethrow;
    }
  }

  /// Get authentication token
  static Future<String?> getAuthToken() async {
    try {
      return await _secureStorage.read(key: _keyAuthToken);
    } catch (e) {
      AppLogger.error('Failed to get auth token', error: e);
      return null;
    }
  }

  /// Save refresh token
  static Future<void> saveRefreshToken(String token) async {
    try {
      await _secureStorage.write(key: _keyRefreshToken, value: token);
      AppLogger.auth('Refresh token saved');
    } catch (e) {
      AppLogger.error('Failed to save refresh token', error: e);
      rethrow;
    }
  }

  /// Get refresh token
  static Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: _keyRefreshToken);
    } catch (e) {
      AppLogger.error('Failed to get refresh token', error: e);
      return null;
    }
  }

  /// Save user data
  static Future<void> saveUserData(UserModel user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await _secureBox.put(_keyUserData, userJson);
      await _prefs.setBool(_keyIsLoggedIn, true);
      AppLogger.auth('User data saved', userId: user.id.toString());
    } catch (e) {
      AppLogger.error('Failed to save user data', error: e);
      rethrow;
    }
  }

  /// Get user data
  static Future<UserModel?> getUserData() async {
    try {
      final userJson = _secureBox.get(_keyUserData);
      if (userJson != null) {
        final userMap = jsonDecode(userJson);
        return UserModel.fromJson(userMap);
      }
      return null;
    } catch (e) {
      AppLogger.error('Failed to get user data', error: e);
      return null;
    }
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final token = await getAuthToken();
      final isLoggedIn = _prefs.getBool(_keyIsLoggedIn) ?? false;
      return token != null && isLoggedIn;
    } catch (e) {
      AppLogger.error('Failed to check login status', error: e);
      return false;
    }
  }

  /// Clear authentication data
  static Future<void> clearAuthData() async {
    try {
      await _secureStorage.delete(key: _keyAuthToken);
      await _secureStorage.delete(key: _keyRefreshToken);
      await _secureBox.delete(_keyUserData);
      await _prefs.setBool(_keyIsLoggedIn, false);
      AppLogger.auth('Auth data cleared');
    } catch (e) {
      AppLogger.error('Failed to clear auth data', error: e);
      rethrow;
    }
  }

  // ==================== App Settings Storage ====================

  /// Save biometric authentication preference
  static Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs.setBool(_keyBiometricEnabled, enabled);
    AppLogger.info(
        'Biometric authentication ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Get biometric authentication preference
  static bool isBiometricEnabled() {
    return _prefs.getBool(_keyBiometricEnabled) ?? false;
  }

  /// Save theme mode
  static Future<void> setThemeMode(String themeMode) async {
    await _prefs.setString(_keyThemeMode, themeMode);
    AppLogger.info('Theme mode set to: $themeMode');
  }

  /// Get theme mode
  static String getThemeMode() {
    return _prefs.getString(_keyThemeMode) ?? 'system';
  }

  /// Save language preference
  static Future<void> setLanguage(String language) async {
    await _prefs.setString(_keyLanguage, language);
    AppLogger.info('Language set to: $language');
  }

  /// Get language preference
  static String getLanguage() {
    return _prefs.getString(_keyLanguage) ?? 'en';
  }

  /// Save notifications preference
  static Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_keyNotificationsEnabled, enabled);
    AppLogger.info('Notifications ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Get notifications preference
  static bool isNotificationsEnabled() {
    return _prefs.getBool(_keyNotificationsEnabled) ?? true;
  }

  /// Check if this is first launch
  static bool isFirstLaunch() {
    return _prefs.getBool(_keyFirstLaunch) ?? true;
  }

  /// Mark first launch as completed
  static Future<void> setFirstLaunchCompleted() async {
    await _prefs.setBool(_keyFirstLaunch, false);
    AppLogger.info('First launch completed');
  }

  // ==================== Data Caching ====================

  /// Generic method to save string data
  static Future<void> setString(String key, String value) async {
    try {
      await _prefs.setString(key, value);
      AppLogger.info('String data saved for key: $key');
    } catch (e) {
      AppLogger.error('Failed to save string data', error: e);
      rethrow;
    }
  }

  /// Generic method to get string data
  static String? getString(String key) {
    try {
      return _prefs.getString(key);
    } catch (e) {
      AppLogger.error('Failed to get string data', error: e);
      return null;
    }
  }

  /// Save last sync time
  static Future<void> setLastSyncTime(DateTime time) async {
    await _prefs.setString(_keyLastSyncTime, time.toIso8601String());
    AppLogger.info('Last sync time updated: ${time.toIso8601String()}');
  }

  /// Get last sync time
  static DateTime? getLastSyncTime() {
    final timeString = _prefs.getString(_keyLastSyncTime);
    if (timeString != null) {
      return DateTime.parse(timeString);
    }
    return null;
  }

  /// Save offline data
  static Future<void> saveOfflineData(
      String key, Map<String, dynamic> data) async {
    try {
      final dataJson = jsonEncode(data);
      await _secureBox.put('${_keyOfflineData}_$key', dataJson);
      AppLogger.database('Offline data saved', table: key);
    } catch (e) {
      AppLogger.error('Failed to save offline data', error: e);
    }
  }

  /// Get offline data
  static Future<Map<String, dynamic>?> getOfflineData(String key) async {
    try {
      final dataJson = _secureBox.get('${_keyOfflineData}_$key');
      if (dataJson != null) {
        return jsonDecode(dataJson);
      }
      return null;
    } catch (e) {
      AppLogger.error('Failed to get offline data', error: e);
      return null;
    }
  }

  /// Clear offline data
  static Future<void> clearOfflineData(String key) async {
    try {
      await _secureBox.delete('${_keyOfflineData}_$key');
      AppLogger.database('Offline data cleared', table: key);
    } catch (e) {
      AppLogger.error('Failed to clear offline data', error: e);
    }
  }

  // ==================== User Preferences ====================

  /// Save search history
  static Future<void> addToSearchHistory(String query) async {
    try {
      List<String> history = getSearchHistory();
      history.remove(query); // Remove if already exists
      history.insert(0, query); // Add to beginning

      // Keep only last 20 searches
      if (history.length > 20) {
        history = history.take(20).toList();
      }

      await _prefs.setStringList(_keySearchHistory, history);
      AppLogger.userAction('Search query added to history',
          parameters: {'query': query});
    } catch (e) {
      AppLogger.error('Failed to add to search history', error: e);
    }
  }

  /// Get search history
  static List<String> getSearchHistory() {
    return _prefs.getStringList(_keySearchHistory) ?? [];
  }

  /// Clear search history
  static Future<void> clearSearchHistory() async {
    await _prefs.remove(_keySearchHistory);
    AppLogger.userAction('Search history cleared');
  }

  /// Add to favorite auctions
  static Future<void> addToFavorites(String auctionId) async {
    try {
      List<String> favorites = getFavoriteAuctions();
      if (!favorites.contains(auctionId)) {
        favorites.add(auctionId);
        await _prefs.setStringList(_keyFavoriteAuctions, favorites);
        AppLogger.userAction('Auction added to favorites',
            parameters: {'auctionId': auctionId});
      }
    } catch (e) {
      AppLogger.error('Failed to add to favorites', error: e);
    }
  }

  /// Remove from favorite auctions
  static Future<void> removeFromFavorites(String auctionId) async {
    try {
      List<String> favorites = getFavoriteAuctions();
      favorites.remove(auctionId);
      await _prefs.setStringList(_keyFavoriteAuctions, favorites);
      AppLogger.userAction('Auction removed from favorites',
          parameters: {'auctionId': auctionId});
    } catch (e) {
      AppLogger.error('Failed to remove from favorites', error: e);
    }
  }

  /// Get favorite auctions
  static List<String> getFavoriteAuctions() {
    return _prefs.getStringList(_keyFavoriteAuctions) ?? [];
  }

  /// Add to recently viewed
  static Future<void> addToRecentlyViewed(String auctionId) async {
    try {
      List<String> recentlyViewed = getRecentlyViewed();
      recentlyViewed.remove(auctionId); // Remove if already exists
      recentlyViewed.insert(0, auctionId); // Add to beginning

      // Keep only last 50 items
      if (recentlyViewed.length > 50) {
        recentlyViewed = recentlyViewed.take(50).toList();
      }

      await _prefs.setStringList(_keyRecentlyViewed, recentlyViewed);
      AppLogger.userAction('Auction added to recently viewed',
          parameters: {'auctionId': auctionId});
    } catch (e) {
      AppLogger.error('Failed to add to recently viewed', error: e);
    }
  }

  /// Get recently viewed auctions
  static List<String> getRecentlyViewed() {
    return _prefs.getStringList(_keyRecentlyViewed) ?? [];
  }

  /// Clear all user data
  static Future<void> clearAllData() async {
    try {
      await _prefs.clear();
      await _secureBox.clear();
      await _secureStorage.deleteAll();
      AppLogger.info('All user data cleared');
    } catch (e) {
      AppLogger.error('Failed to clear all data', error: e);
      rethrow;
    }
  }
}
