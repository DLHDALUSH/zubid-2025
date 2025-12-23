import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/utils/logger.dart';
import '../models/profile_model.dart';
import '../models/update_profile_request_model.dart';
import '../models/update_profile_response_model.dart';
import '../models/upload_photo_request_model.dart';
import '../models/upload_photo_response_model.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return ProfileRepository(apiClient);
});

class ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepository(this._apiClient);

  /// Get user profile
  Future<ApiResult<ProfileModel>> getProfile() async {
    try {
      AppLogger.network('GET', '/api/profile');
      
      final response = await _apiClient.dio.get('/api/profile');
      
      AppLogger.network('GET', '/api/profile', statusCode: 200, response: 'Profile fetch successful');
      
      final profile = ProfileModel.fromJson(response.data['profile']);
      return ApiResult.success(profile);
      
    } on DioException catch (e) {
      AppLogger.error('Profile fetch failed', error: e);
      return _handleDioError(e);
    } catch (e) {
      AppLogger.error('Unexpected error in profile fetch', error: e);
      return ApiResult.failure('An unexpected error occurred');
    }
  }

  /// Update user profile
  Future<ApiResult<ProfileModel>> updateProfile(UpdateProfileRequestModel request) async {
    try {
      AppLogger.network('PUT', '/api/profile');
      
      final response = await _apiClient.dio.put(
        '/api/profile',
        data: request.toJson(),
      );
      
      AppLogger.network('PUT', '/api/profile', statusCode: 200, response: 'Profile update successful');
      
      final updateResponse = UpdateProfileResponseModel.fromJson(response.data);
      
      if (updateResponse.success && updateResponse.profile != null) {
        final profile = _convertProfileDataToModel(updateResponse.profile!);
        return ApiResult.success(profile);
      } else {
        return ApiResult.failure(updateResponse.message);
      }
      
    } on DioException catch (e) {
      AppLogger.error('Profile update failed', error: e);
      return _handleDioError(e);
    } catch (e) {
      AppLogger.error('Unexpected error in profile update', error: e);
      return ApiResult.failure('An unexpected error occurred');
    }
  }

  /// Upload profile photo
  Future<ApiResult<String>> uploadProfilePhoto(File imageFile) async {
    try {
      AppLogger.network('POST', '/api/profile/photo');
      
      // Convert image to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final fileName = imageFile.path.split('/').last;
      final fileType = fileName.split('.').last.toLowerCase();
      
      final request = UploadPhotoRequestModel.fromFile(imageFile);
      
      final response = await _apiClient.dio.post(
        '/api/profile/photo',
        data: request.toJson(),
      );
      
      AppLogger.network('POST', '/api/profile/photo', statusCode: 200, response: 'Photo upload successful');
      
      final uploadResponse = UploadPhotoResponseModel.fromJson(response.data);
      
      if (uploadResponse.success && uploadResponse.photoUrl != null) {
        return ApiResult.success(uploadResponse.photoUrl!);
      } else {
        return ApiResult.failure(uploadResponse.message);
      }
      
    } on DioException catch (e) {
      AppLogger.error('Photo upload failed', error: e);
      return _handleDioError(e);
    } catch (e) {
      AppLogger.error('Unexpected error in photo upload', error: e);
      return ApiResult.failure('An unexpected error occurred');
    }
  }

  /// Delete profile photo
  Future<ApiResult<bool>> deleteProfilePhoto() async {
    try {
      AppLogger.network('DELETE', '/api/profile/photo');

      final response = await _apiClient.dio.delete('/api/profile/photo');

      AppLogger.network('DELETE', '/api/profile/photo', statusCode: 200, response: 'Photo deletion successful');
      
      return ApiResult.success(true);
      
    } on DioException catch (e) {
      AppLogger.error('Photo deletion failed', error: e);
      return _handleDioError(e);
    } catch (e) {
      AppLogger.error('Unexpected error in photo deletion', error: e);
      return ApiResult.failure('An unexpected error occurred');
    }
  }

  /// Change password
  Future<ApiResult<bool>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      AppLogger.network('POST', '/api/profile/change-password');

      final response = await _apiClient.dio.post(
        '/api/profile/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      AppLogger.network('POST', '/api/profile/change-password', statusCode: 200, response: 'Password change successful');
      
      return ApiResult.success(true);
      
    } on DioException catch (e) {
      AppLogger.error('Password change failed', error: e);
      return _handleDioError(e);
    } catch (e) {
      AppLogger.error('Unexpected error in password change', error: e);
      return ApiResult.failure('An unexpected error occurred');
    }
  }

  /// Verify email
  Future<ApiResult<bool>> verifyEmail(String token) async {
    try {
      AppLogger.network('POST', '/api/profile/verify-email');

      final response = await _apiClient.dio.post(
        '/api/profile/verify-email',
        data: {'token': token},
      );

      AppLogger.network('POST', '/api/profile/verify-email', statusCode: 200, response: 'Email verification successful');
      
      return ApiResult.success(true);
      
    } on DioException catch (e) {
      AppLogger.error('Email verification failed', error: e);
      return _handleDioError(e);
    } catch (e) {
      AppLogger.error('Unexpected error in email verification', error: e);
      return ApiResult.failure('An unexpected error occurred');
    }
  }

  /// Resend email verification
  Future<ApiResult<bool>> resendEmailVerification() async {
    try {
      AppLogger.network('POST', '/api/profile/resend-verification');

      final response = await _apiClient.dio.post('/api/profile/resend-verification');

      AppLogger.network('POST', '/api/profile/resend-verification', statusCode: 200, response: 'Email verification resent successfully');
      
      return ApiResult.success(true);
      
    } on DioException catch (e) {
      AppLogger.error('Email verification resend failed', error: e);
      return _handleDioError(e);
    } catch (e) {
      AppLogger.error('Unexpected error in email verification resend', error: e);
      return ApiResult.failure('An unexpected error occurred');
    }
  }

  /// Convert ProfileData to ProfileModel
  ProfileModel _convertProfileDataToModel(ProfileData data) {
    return ProfileModel(
      id: data.id,
      username: data.username,
      email: data.email,
      firstName: data.firstName,
      lastName: data.lastName,
      phoneNumber: data.phoneNumber,
      profilePhotoUrl: data.profilePhotoUrl,
      idNumber: data.idNumber,
      address: data.address,
      city: data.city,
      country: data.country,
      postalCode: data.postalCode,
      dateOfBirth: data.dateOfBirth != null ? DateTime.parse(data.dateOfBirth!) : null,
      bio: data.bio,
      preferredLanguage: data.preferredLanguage,
      timezone: data.timezone,
      emailVerified: data.emailVerified,
      phoneVerified: data.phoneVerified,
      profileCompleted: data.profileCompleted,
      rating: data.rating,
      totalBids: data.totalBids,
      totalWins: data.totalWins,
      totalSpent: data.totalSpent,
      memberSince: DateTime.parse(data.memberSince),
      lastActive: data.lastActive != null ? DateTime.parse(data.lastActive!) : null,
    );
  }

  /// Handle Dio errors
  ApiResult<T> _handleDioError<T>(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiResult.failure('Connection timeout. Please try again.');
      
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        
        if (statusCode == 400 && data != null && data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          return ApiResult.failure(firstError.toString());
        } else if (statusCode == 401) {
          return ApiResult.failure('Session expired. Please login again.');
        } else if (statusCode == 403) {
          return ApiResult.failure('Access denied.');
        } else if (statusCode == 404) {
          return ApiResult.failure('Profile not found.');
        } else if (statusCode == 422 && data != null) {
          return ApiResult.failure(data['message'] ?? 'Validation error');
        } else {
          return ApiResult.failure(data?['message'] ?? 'Server error occurred');
        }
      
      case DioExceptionType.cancel:
        return ApiResult.failure('Request was cancelled');
      
      case DioExceptionType.unknown:
        if (e.error is SocketException) {
          return ApiResult.failure('No internet connection');
        }
        return ApiResult.failure('Network error occurred');
      
      default:
        return ApiResult.failure('An unexpected error occurred');
    }
  }
}
