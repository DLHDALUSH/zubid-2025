import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart'
    as platform;
import 'package:flutter/services.dart';

import '../utils/logger.dart';
import 'storage_service.dart';

enum AppBiometricType {
  none,
  fingerprint,
  face,
  iris,
  multiple,
}

enum BiometricAuthResult {
  success,
  failure,
  cancelled,
  notAvailable,
  notEnrolled,
  lockedOut,
  permanentlyLockedOut,
  unknown,
}

class BiometricService {
  static BiometricService? _instance;
  static BiometricService get instance => _instance ??= BiometricService._();

  BiometricService._();

  final LocalAuthentication _localAuth = LocalAuthentication();
  static const String _biometricKeyPrefix = 'biometric_';
  static const String _biometricHashKey = 'biometric_hash';

  /// Check if biometric authentication is available on the device
  Future<bool> isAvailable() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();

      AppLogger.info(
          'Biometric availability: $isAvailable, Device supported: $isDeviceSupported');
      return isAvailable && isDeviceSupported;
    } catch (e) {
      AppLogger.error('Error checking biometric availability', error: e);
      return false;
    }
  }

  /// Get available biometric types
  Future<List<AppBiometricType>> getAvailableBiometrics() async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      final mappedBiometrics = availableBiometrics
          .map((biometric) => _mapBiometricType(biometric))
          .toList();

      AppLogger.info('Available biometrics: $mappedBiometrics');
      return mappedBiometrics;
    } catch (e) {
      AppLogger.error('Error getting available biometrics', error: e);
      return [];
    }
  }

  /// Check if user has enrolled biometrics
  Future<bool> isEnrolled() async {
    try {
      final availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.isNotEmpty &&
          availableBiometrics.first != AppBiometricType.none;
    } catch (e) {
      AppLogger.error('Error checking biometric enrollment', error: e);
      return false;
    }
  }

  /// Authenticate using biometrics
  Future<BiometricAuthResult> authenticate({
    String localizedReason = 'Please authenticate to access your account',
    bool biometricOnly = false,
    bool stickyAuth = true,
    bool sensitiveTransaction = false,
  }) async {
    try {
      if (!await isAvailable()) {
        return BiometricAuthResult.notAvailable;
      }

      if (!await isEnrolled()) {
        return BiometricAuthResult.notEnrolled;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason,
      );

      if (didAuthenticate) {
        AppLogger.userAction('Biometric authentication successful');
        return BiometricAuthResult.success;
      } else {
        AppLogger.userAction('Biometric authentication failed');
        return BiometricAuthResult.failure;
      }
    } on PlatformException catch (e) {
      AppLogger.error('Biometric authentication platform exception', error: e);
      return _handlePlatformException(e);
    } catch (e) {
      AppLogger.error('Biometric authentication error', error: e);
      return BiometricAuthResult.unknown;
    }
  }

  /// Enable biometric authentication for the app
  Future<bool> enableBiometricAuth({
    required String userCredentials,
    String reason = 'Enable biometric authentication for secure access',
  }) async {
    try {
      // First authenticate with biometrics to ensure it works
      final authResult = await authenticate(localizedReason: reason);

      if (authResult != BiometricAuthResult.success) {
        return false;
      }

      // Generate and store a secure hash of user credentials
      final credentialsHash = _generateSecureHash(userCredentials);
      await StorageService.setString(_biometricHashKey, credentialsHash);

      // Enable biometric setting
      await StorageService.setBiometricEnabled(true);

      AppLogger.userAction('Biometric authentication enabled');
      return true;
    } catch (e) {
      AppLogger.error('Failed to enable biometric authentication', error: e);
      return false;
    }
  }

  /// Disable biometric authentication
  Future<void> disableBiometricAuth() async {
    try {
      await StorageService.setBiometricEnabled(false);
      await _clearBiometricData();
      AppLogger.userAction('Biometric authentication disabled');
    } catch (e) {
      AppLogger.error('Failed to disable biometric authentication', error: e);
    }
  }

  /// Check if biometric authentication is enabled
  Future<bool> isBiometricEnabled() async {
    try {
      return StorageService.isBiometricEnabled() && await isAvailable();
    } catch (e) {
      AppLogger.error('Error checking biometric enabled status', error: e);
      return false;
    }
  }

  /// Verify stored biometric credentials
  Future<bool> verifyStoredCredentials(String userCredentials) async {
    try {
      final storedHash = StorageService.getString(_biometricHashKey);
      if (storedHash == null) {
        return false;
      }

      final credentialsHash = _generateSecureHash(userCredentials);
      return storedHash == credentialsHash;
    } catch (e) {
      AppLogger.error('Error verifying stored credentials', error: e);
      return false;
    }
  }

  /// Authenticate for sensitive transactions (higher security)
  Future<BiometricAuthResult> authenticateForTransaction({
    required String transactionDetails,
    String reason = 'Authenticate to confirm this transaction',
  }) async {
    return await authenticate(
      localizedReason: '$reason\n\n$transactionDetails',
      biometricOnly: true,
      stickyAuth: true,
      sensitiveTransaction: true,
    );
  }

  /// Get biometric strength level
  Future<String> getBiometricStrength() async {
    try {
      final availableBiometrics = await getAvailableBiometrics();

      if (availableBiometrics.contains(AppBiometricType.iris)) {
        return 'Very High';
      } else if (availableBiometrics.contains(AppBiometricType.face)) {
        return 'High';
      } else if (availableBiometrics.contains(AppBiometricType.fingerprint)) {
        return 'Medium';
      } else {
        return 'None';
      }
    } catch (e) {
      AppLogger.error('Error getting biometric strength', error: e);
      return 'Unknown';
    }
  }

  /// Clear all biometric data
  Future<void> _clearBiometricData() async {
    try {
      await StorageService.setString(_biometricHashKey, '');
      AppLogger.info('Biometric data cleared');
    } catch (e) {
      AppLogger.error('Error clearing biometric data', error: e);
    }
  }

  /// Generate secure hash for credentials
  String _generateSecureHash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Map platform biometric types to our enum
  AppBiometricType _mapBiometricType(platform.BiometricType platformType) {
    switch (platformType) {
      case platform.BiometricType.fingerprint:
        return AppBiometricType.fingerprint;
      case platform.BiometricType.face:
        return AppBiometricType.face;
      case platform.BiometricType.iris:
        return AppBiometricType.iris;
      default:
        return AppBiometricType.none;
    }
  }

  /// Handle platform exceptions and map to our result enum
  BiometricAuthResult _handlePlatformException(PlatformException e) {
    switch (e.code) {
      case 'NotAvailable':
        return BiometricAuthResult.notAvailable;
      case 'NotEnrolled':
        return BiometricAuthResult.notEnrolled;
      case 'LockedOut':
        return BiometricAuthResult.lockedOut;
      case 'PermanentlyLockedOut':
        return BiometricAuthResult.permanentlyLockedOut;
      case 'UserCancel':
        return BiometricAuthResult.cancelled;
      default:
        AppLogger.warning('Unknown biometric platform exception: ${e.code}');
        return BiometricAuthResult.unknown;
    }
  }

  /// Get user-friendly error message
  String getErrorMessage(BiometricAuthResult result) {
    switch (result) {
      case BiometricAuthResult.success:
        return 'Authentication successful';
      case BiometricAuthResult.failure:
        return 'Authentication failed. Please try again.';
      case BiometricAuthResult.cancelled:
        return 'Authentication was cancelled';
      case BiometricAuthResult.notAvailable:
        return 'Biometric authentication is not available on this device';
      case BiometricAuthResult.notEnrolled:
        return 'No biometrics enrolled. Please set up biometric authentication in device settings.';
      case BiometricAuthResult.lockedOut:
        return 'Biometric authentication is temporarily locked. Please try again later.';
      case BiometricAuthResult.permanentlyLockedOut:
        return 'Biometric authentication is permanently locked. Please use alternative authentication.';
      case BiometricAuthResult.unknown:
        return 'An unknown error occurred during authentication';
    }
  }
}
