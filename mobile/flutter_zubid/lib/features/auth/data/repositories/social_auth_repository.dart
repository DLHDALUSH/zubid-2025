import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';  // Temporarily disabled

import '../../../../core/network/api_result.dart';
import '../../../../core/utils/logger.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import 'auth_repository.dart';

final socialAuthRepositoryProvider = Provider<SocialAuthRepository>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return SocialAuthRepository(authRepository);
});

class SocialAuthRepository {
  // AuthRepository is kept for future backend integration
  // ignore: unused_field
  final AuthRepository _authRepository;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  SocialAuthRepository(this._authRepository);

  /// Sign in with Google
  Future<ApiResult<AuthResponseModel>> signInWithGoogle() async {
    try {
      AppLogger.userAction('Google sign-in attempted');

      // 1. Sign in with Google to get the user's account
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        AppLogger.info('Google sign-in cancelled by user');
        return const ApiResult.failure('Google sign-in cancelled');
      }

      AppLogger.info('Google sign-in successful for: ${googleUser.email}');

      // 2. Get the authentication tokens
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      // accessToken can be used for additional API calls if needed
      // final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        AppLogger.error('Failed to get Google ID token');
        return const ApiResult.failure('Failed to get Google ID token');
      }

      // 3. Try to authenticate with backend using the Google token
      // For now, we'll create a mock successful response since backend integration
      // would require the backend to have Google OAuth verification

      // Create a mock auth response for demonstration
      // In production, you would send the idToken to your backend:
      // final response = await _authRepository.socialLogin('google', idToken);

      // Parse display name into first and last name
      String? firstName;
      String? lastName;
      if (googleUser.displayName != null) {
        final nameParts = googleUser.displayName!.split(' ');
        firstName = nameParts.isNotEmpty ? nameParts.first : null;
        lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : null;
      }

      final mockUser = UserModel(
        id: googleUser.id.hashCode,
        email: googleUser.email,
        username: googleUser.email.split('@').first,
        firstName: firstName,
        lastName: lastName,
        profilePhotoUrl: googleUser.photoUrl,
        isVerified: true,
        emailVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mockResponse = AuthResponseModel(
        success: true,
        message: 'Google sign-in successful',
        token:
            'google_${DateTime.now().millisecondsSinceEpoch}_${idToken.substring(0, 20)}',
        refreshToken: 'refresh_google_${DateTime.now().millisecondsSinceEpoch}',
        user: mockUser,
      );

      AppLogger.info('Google authentication successful for: ${mockUser.email}');
      return ApiResult.success(mockResponse);
    } catch (e, stackTrace) {
      AppLogger.error('Google sign-in error', error: e, stackTrace: stackTrace);

      // Handle specific Google Sign-In errors
      if (e.toString().contains('sign_in_canceled')) {
        return const ApiResult.failure('Google sign-in was cancelled');
      } else if (e.toString().contains('network_error')) {
        return const ApiResult.failure(
            'Network error. Please check your connection.');
      } else if (e.toString().contains('sign_in_failed')) {
        return const ApiResult.failure(
            'Google sign-in failed. Please try again.');
      }

      return ApiResult.failure('Google sign-in error: ${e.toString()}');
    }
  }

  /// Sign out from Google
  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
      AppLogger.info('Google sign-out successful');
    } catch (e) {
      AppLogger.error('Google sign-out error', error: e);
    }
  }

  /// Check if user is signed in with Google
  Future<bool> isSignedInWithGoogle() async {
    return await _googleSignIn.isSignedIn();
  }

  /// Sign in with Apple - Temporarily disabled
  Future<ApiResult<AuthResponseModel>> signInWithApple() async {
    // Temporarily disabled due to build issues
    AppLogger.userAction('Apple sign-in attempted - currently disabled');
    return const ApiResult.failure(
        'Apple sign-in is not available on this platform');
  }
}
