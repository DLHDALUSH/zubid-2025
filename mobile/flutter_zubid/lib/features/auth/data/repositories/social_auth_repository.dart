import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';  // Temporarily disabled

import '../../../../core/network/api_result.dart';
import '../../../../core/utils/logger.dart';
import '../models/auth_response_model.dart';

final socialAuthRepositoryProvider = Provider<SocialAuthRepository>((ref) {
  return SocialAuthRepository();
});

class SocialAuthRepository {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // TODO: Add your server client ID here for Google Sign-In
    // serverClientId: 'YOUR_SERVER_CLIENT_ID',
  );

  /// Sign in with Google
  Future<ApiResult<AuthResponseModel>> signInWithGoogle() async {
    try {
      AppLogger.userAction('Google sign-in attempted');
      
      // TODO: Implement the full Google Sign-In flow
      // 1. Sign in with Google to get the user's account
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return ApiResult.failure('Google sign-in cancelled');
      }

      // 2. Get the authentication tokens
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        return ApiResult.failure('Failed to get Google ID token');
      }

      // 3. Send the ID token to your backend for verification and get your own auth token
      // final response = await _apiClient.post('/auth/google', data: {'token': idToken});
      // final authResponse = AuthResponseModel.fromJson(response.data);

      // For now, returning a mock failure
      return ApiResult.failure('Google sign-in not fully implemented');

    } catch (e, stackTrace) {
      AppLogger.error('Google sign-in error', error: e, stackTrace: stackTrace);
      return ApiResult.failure('An unexpected error occurred during Google sign-in');
    }
  }

  /// Sign in with Apple - Temporarily disabled
  Future<ApiResult<AuthResponseModel>> signInWithApple() async {
    // Temporarily disabled due to build issues
    AppLogger.userAction('Apple sign-in attempted - currently disabled');
    return ApiResult.failure('Apple sign-in temporarily disabled');

    /*
    try {
      AppLogger.userAction('Apple sign-in attempted');

      // TODO: Implement the full Apple Sign-In flow
      // 1. Request the credential from Apple
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // 2. Send the credential to your backend for verification
      // final response = await _apiClient.post('/auth/apple', data: {
      //   'identityToken': credential.identityToken,
      //   'givenName': credential.givenName,
      //   'familyName': credential.familyName,
      //   'email': credential.email,
      // });
      // final authResponse = AuthResponseModel.fromJson(response.data);

      // For now, returning a mock failure
      return ApiResult.failure('Apple sign-in not fully implemented');

    } catch (e, stackTrace) {
      AppLogger.error('Apple sign-in error', error: e, stackTrace: stackTrace);
      return ApiResult.failure('An unexpected error occurred during Apple sign-in');
    }
    */
  }
}
