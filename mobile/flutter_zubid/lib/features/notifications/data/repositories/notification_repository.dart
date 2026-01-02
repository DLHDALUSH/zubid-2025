import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/utils/logger.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository(this._apiClient);

  /// Get all notifications for the current user
  Future<ApiResult<List<NotificationModel>>> getNotifications() async {
    try {
      final response = await _apiClient.get('/notifications');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final notifications = data
            .map((json) => NotificationModel.fromJson(json))
            .toList();
        return ApiResult.success(notifications);
      }

      return ApiResult.failure('Failed to load notifications');
    } on DioException catch (e) {
      AppLogger.error('Failed to get notifications', error: e);
      return ApiResult.failure(e.response?.data?['error'] ?? 'Network error');
    } catch (e) {
      AppLogger.error('Unexpected error getting notifications', error: e);
      return ApiResult.failure('An unexpected error occurred');
    }
  }

  /// Get unread notification count
  Future<ApiResult<int>> getUnreadCount() async {
    try {
      final response = await _apiClient.get('/notifications/unread-count');

      if (response.statusCode == 200) {
        final count = response.data['count'] as int;
        return ApiResult.success(count);
      }

      return ApiResult.failure('Failed to get unread count');
    } on DioException catch (e) {
      AppLogger.error('Failed to get unread count', error: e);
      return ApiResult.failure(e.response?.data?['error'] ?? 'Network error');
    } catch (e) {
      AppLogger.error('Unexpected error getting unread count', error: e);
      return ApiResult.failure('An unexpected error occurred');
    }
  }

  /// Mark a notification as read
  Future<ApiResult<bool>> markAsRead(String notificationId) async {
    try {
      final response = await _apiClient.put('/notifications/$notificationId/read');

      if (response.statusCode == 200) {
        return ApiResult.success(true);
      }

      return ApiResult.failure('Failed to mark notification as read');
    } on DioException catch (e) {
      AppLogger.error('Failed to mark notification as read', error: e);
      return ApiResult.failure(e.response?.data?['error'] ?? 'Network error');
    } catch (e) {
      AppLogger.error('Unexpected error marking notification as read', error: e);
      return ApiResult.failure('An unexpected error occurred');
    }
  }

  /// Mark all notifications as read
  Future<ApiResult<bool>> markAllAsRead() async {
    try {
      final response = await _apiClient.put('/notifications/read-all');

      if (response.statusCode == 200) {
        return ApiResult.success(true);
      }

      return ApiResult.failure('Failed to mark all notifications as read');
    } on DioException catch (e) {
      AppLogger.error('Failed to mark all notifications as read', error: e);
      return ApiResult.failure(e.response?.data?['error'] ?? 'Network error');
    } catch (e) {
      AppLogger.error('Unexpected error marking all notifications as read', error: e);
      return ApiResult.failure('An unexpected error occurred');
    }
  }

  /// Delete a notification
  Future<ApiResult<bool>> deleteNotification(String notificationId) async {
    try {
      final response = await _apiClient.delete('/notifications/$notificationId');

      if (response.statusCode == 200) {
        return ApiResult.success(true);
      }

      return ApiResult.failure('Failed to delete notification');
    } on DioException catch (e) {
      AppLogger.error('Failed to delete notification', error: e);
      return ApiResult.failure(e.response?.data?['error'] ?? 'Network error');
    } catch (e) {
      AppLogger.error('Unexpected error deleting notification', error: e);
      return ApiResult.failure('An unexpected error occurred');
    }
  }
}

// Provider
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return NotificationRepository(apiClient);
});

