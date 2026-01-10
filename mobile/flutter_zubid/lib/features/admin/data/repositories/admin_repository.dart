import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/utils/logger.dart';
import '../models/admin_stats_model.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.read(apiClientProvider));
});

class AdminRepository {
  final ApiClient _apiClient;

  AdminRepository(this._apiClient);

  /// Get admin statistics
  Future<ApiResult<AdminStatsModel>> getAdminStats() async {
    try {
      AppLogger.info('Fetching admin statistics');

      final response = await _apiClient.get('/admin/stats');

      final stats = AdminStatsModel.fromJson(response.data);
      AppLogger.info('Admin stats fetched successfully');
      return ApiResult.success(stats);
    } catch (e) {
      AppLogger.error('Failed to fetch admin stats', error: e);
      return ApiResult.failure('Failed to fetch admin statistics');
    }
  }

  /// Get admin users list
  Future<ApiResult<Map<String, dynamic>>> getAdminUsers({
    int page = 1,
    int perPage = 20,
    String? search,
  }) async {
    try {
      AppLogger.info('Fetching admin users - page: $page');

      final queryParams = {
        'page': page,
        'per_page': perPage,
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await _apiClient.get(
        '/admin/users',
        queryParameters: queryParams,
      );

      AppLogger.info('Admin users fetched successfully');
      return ApiResult.success(response.data);
    } catch (e) {
      AppLogger.error('Failed to fetch admin users', error: e);
      return ApiResult.failure('Failed to fetch users');
    }
  }

  /// Get admin auctions list
  Future<ApiResult<Map<String, dynamic>>> getAdminAuctions({
    int page = 1,
    int perPage = 20,
    String? status,
  }) async {
    try {
      AppLogger.info('Fetching admin auctions - page: $page');

      final queryParams = {
        'page': page,
        'per_page': perPage,
        if (status != null && status.isNotEmpty) 'status': status,
      };

      final response = await _apiClient.get(
        '/admin/auctions',
        queryParameters: queryParams,
      );

      AppLogger.info('Admin auctions fetched successfully');
      return ApiResult.success(response.data);
    } catch (e) {
      AppLogger.error('Failed to fetch admin auctions', error: e);
      return ApiResult.failure('Failed to fetch auctions');
    }
  }
}
