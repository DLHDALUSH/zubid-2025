import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../models/user_model.dart';
import '../models/auth_response_model.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import '../models/forgot_password_request_model.dart';
import '../models/refresh_token_request_model.dart';
import '../models/reset_password_request_model.dart';
import '../models/change_password_request_model.dart';
import '../models/verify_email_request_model.dart';
import '../models/resend_verification_request_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(apiClientProvider));
});

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  /// Login user
  Future<ApiResult<AuthResponseModel>> login(LoginRequestModel request) async {
    try {
      AppLogger.auth('Attempting login', userId: request.username);
      
      final response = await _apiClient.post(
        '/auth/login',
        data: request.toJson(),
      );

      final authResponse = AuthResponseModel.fromJson(response.data);
      
      if (authResponse.success && authResponse.token != null && authResponse.user != null) {
        // Save authentication data
        await StorageService.saveAuthToken(authResponse.token!);
        if (authResponse.refreshToken != null) {
          await StorageService.saveRefreshToken(authResponse.refreshToken!);
        }
        await StorageService.saveUserData(authResponse.user!);
        
        AppLogger.auth('Login successful', userId: authResponse.user!.id.toString(), success: true);
        return ApiResult.success(authResponse);
      } else {
        AppLogger.auth('Login failed', userId: request.username, success: false);
        return ApiResult.failure(authResponse.message);
      }
    } on DioException catch (e) {
      AppLogger.auth('Login error', userId: request.username, success: false);
      return _handleDioError(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected login error', error: e, stackTrace: stackTrace);
      return ApiResult.failure('An unexpected error occurred during login');
    }
  }

  /// Register user
  Future<ApiResult<AuthResponseModel>> register(RegisterRequestModel request) async {
    try {
      AppLogger.auth('Attempting registration', userId: request.email);
      
      final response = await _apiClient.post(
        '/auth/register',
        data: request.toJson(),
      );

      final authResponse = AuthResponseModel.fromJson(response.data);
      
      if (authResponse.success) {
        AppLogger.auth('Registration successful', userId: request.email, success: true);
        
        // If auto-login after registration
        if (authResponse.token != null && authResponse.user != null) {
          await StorageService.saveAuthToken(authResponse.token!);
          if (authResponse.refreshToken != null) {
            await StorageService.saveRefreshToken(authResponse.refreshToken!);
          }
          await StorageService.saveUserData(authResponse.user!);
        }
        
        return ApiResult.success(authResponse);
      } else {
        AppLogger.auth('Registration failed', userId: request.email, success: false);
        return ApiResult.failure(authResponse.message);
      }
    } on DioException catch (e) {
      AppLogger.auth('Registration error', userId: request.email, success: false);
      return _handleDioError(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected registration error', error: e, stackTrace: stackTrace);
      return ApiResult.failure('An unexpected error occurred during registration');
    }
  }

  /// Forgot password
  Future<ApiResult<AuthResponseModel>> forgotPassword(ForgotPasswordRequestModel request) async {
    try {
      AppLogger.auth('Forgot password request', userId: request.email);
      
      final response = await _apiClient.post(
        '/auth/forgot-password',
        data: request.toJson(),
      );

      final authResponse = AuthResponseModel.fromJson(response.data);
      AppLogger.auth('Forgot password response', success: authResponse.success);
      
      return ApiResult.success(authResponse);
    } on DioException catch (e) {
      AppLogger.auth('Forgot password error');
      return _handleDioError(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected forgot password error', error: e, stackTrace: stackTrace);
      return ApiResult.failure('An unexpected error occurred');
    }
  }

  /// Reset password
  Future<ApiResult<AuthResponseModel>> resetPassword(ResetPasswordRequestModel request) async {
    try {
      AppLogger.auth('Reset password attempt');
      
      final response = await _apiClient.post(
        '/auth/reset-password',
        data: request.toJson(),
      );

      final authResponse = AuthResponseModel.fromJson(response.data);
      AppLogger.auth('Reset password response', success: authResponse.success);
      
      return ApiResult.success(authResponse);
    } on DioException catch (e) {
      AppLogger.auth('Reset password error');
      return _handleDioError(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected reset password error', error: e, stackTrace: stackTrace);
      return ApiResult.failure('An unexpected error occurred');
    }
  }

  /// Change password
  Future<ApiResult<AuthResponseModel>> changePassword(ChangePasswordRequestModel request) async {
    try {
      AppLogger.auth('Change password attempt');
      
      final response = await _apiClient.post(
        '/auth/change-password',
        data: request.toJson(),
      );

      final authResponse = AuthResponseModel.fromJson(response.data);
      AppLogger.auth('Change password response', success: authResponse.success);
      
      return ApiResult.success(authResponse);
    } on DioException catch (e) {
      AppLogger.auth('Change password error');
      return _handleDioError(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected change password error', error: e, stackTrace: stackTrace);
      return ApiResult.failure('An unexpected error occurred');
    }
  }

  /// Refresh token
  Future<ApiResult<AuthResponseModel>> refreshToken() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null) {
        return ApiResult.failure('No refresh token available');
      }

      AppLogger.auth('Refreshing token');
      
      final response = await _apiClient.post(
        '/auth/refresh-token',
        data: RefreshTokenRequestModel(refreshToken: refreshToken).toJson(),
      );

      final authResponse = AuthResponseModel.fromJson(response.data);
      
      if (authResponse.success && authResponse.token != null) {
        await StorageService.saveAuthToken(authResponse.token!);
        if (authResponse.refreshToken != null) {
          await StorageService.saveRefreshToken(authResponse.refreshToken!);
        }
        
        AppLogger.auth('Token refresh successful', success: true);
        return ApiResult.success(authResponse);
      } else {
        AppLogger.auth('Token refresh failed', success: false);
        return ApiResult.failure(authResponse.message);
      }
    } on DioException catch (e) {
      AppLogger.auth('Token refresh error');
      return _handleDioError(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected token refresh error', error: e, stackTrace: stackTrace);
      return ApiResult.failure('An unexpected error occurred');
    }
  }

  /// Verify email
  Future<ApiResult<AuthResponseModel>> verifyEmail(VerifyEmailRequestModel request) async {
    try {
      AppLogger.auth('Email verification attempt');
      
      final response = await _apiClient.post(
        '/auth/verify-email',
        data: request.toJson(),
      );

      final authResponse = AuthResponseModel.fromJson(response.data);
      AppLogger.auth('Email verification response', success: authResponse.success);
      
      return ApiResult.success(authResponse);
    } on DioException catch (e) {
      AppLogger.auth('Email verification error');
      return _handleDioError(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected email verification error', error: e, stackTrace: stackTrace);
      return ApiResult.failure('An unexpected error occurred');
    }
  }

  /// Resend verification email
  Future<ApiResult<AuthResponseModel>> resendVerificationEmail(ResendVerificationRequestModel request) async {
    try {
      AppLogger.auth('Resend verification email');
      
      final response = await _apiClient.post(
        '/auth/resend-verification',
        data: request.toJson(),
      );

      final authResponse = AuthResponseModel.fromJson(response.data);
      AppLogger.auth('Resend verification response', success: authResponse.success);
      
      return ApiResult.success(authResponse);
    } on DioException catch (e) {
      AppLogger.auth('Resend verification error');
      return _handleDioError(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected resend verification error', error: e, stackTrace: stackTrace);
      return ApiResult.failure('An unexpected error occurred');
    }
  }

  /// Logout
  Future<ApiResult<void>> logout() async {
    try {
      AppLogger.auth('Logout attempt');
      
      // Call logout endpoint if token exists
      final token = await StorageService.getAuthToken();
      if (token != null) {
        try {
          await _apiClient.post('/auth/logout');
        } catch (e) {
          // Continue with local logout even if server logout fails
          AppLogger.warning('Server logout failed, continuing with local logout', error: e);
        }
      }

      // Clear local authentication data
      await StorageService.clearAuthData();
      
      AppLogger.auth('Logout successful', success: true);
      return ApiResult.success(null);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected logout error', error: e, stackTrace: stackTrace);
      return ApiResult.failure('An unexpected error occurred during logout');
    }
  }

  /// Get current user
  Future<ApiResult<UserModel>> getCurrentUser() async {
    try {
      AppLogger.auth('Getting current user');
      
      final response = await _apiClient.get('/auth/me');
      if (response.data != null && response.data['user'] != null) {
        final user = UserModel.fromJson(response.data['user']);
        
        // Update stored user data
        await StorageService.saveUserData(user);
        
        AppLogger.auth('Current user retrieved', userId: user.id.toString());
        return ApiResult.success(user);
      } else {
        return ApiResult.failure('Invalid user data received');
      }
    } on DioException catch (e) {
      AppLogger.auth('Get current user error');
      return _handleDioError(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected get current user error', error: e, stackTrace: stackTrace);
      return ApiResult.failure('An unexpected error occurred');
    }
  }

  /// Handle Dio errors
  ApiResult<T> _handleDioError<T>(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiResult.failure('Connection timeout. Please check your internet connection.');
      
      case DioExceptionType.badResponse:
        final message = e.response?.data?['message'] ?? 'A server error occurred.';
        final statusCode = e.response?.statusCode;

        if (statusCode == 401) {
          return ApiResult.failure('Invalid credentials or session expired. Please log in again.');
        } else if (statusCode == 403) {
          return ApiResult.failure('You do not have permission to perform this action.');
        }
        return ApiResult.failure(message);
      
      case DioExceptionType.cancel:
        return ApiResult.failure('The request was cancelled.');
      
      case DioExceptionType.connectionError:
        return ApiResult.failure('No internet connection. Please check your network.');
      
      default:
        return ApiResult.failure('An unexpected error occurred. Please try again later.');
    }
  }
}
