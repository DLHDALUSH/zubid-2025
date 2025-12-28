import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/utils/logger.dart';
import '../models/auction_model.dart';
import '../models/create_auction_model.dart';
import '../models/category_model.dart';

class AuctionCreationRepository {
  final ApiClient _apiClient;

  AuctionCreationRepository(this._apiClient);

  /// Create a new auction
  Future<ApiResult<CreateAuctionResponse>> createAuction(
    CreateAuctionRequest request,
  ) async {
    try {
      AppLogger.info('Creating auction: ${request.title}');

      final response = await _apiClient.post(
        '/auctions',
        data: request.toJson(),
      );

      final createResponse = CreateAuctionResponse.fromJson(response.data);

      if (createResponse.success) {
        AppLogger.info(
            'Auction created successfully: ${createResponse.auctionId}');
        return ApiResult.success(createResponse);
      } else {
        AppLogger.warning('Auction creation failed: ${createResponse.message}');
        return ApiResult.failure(createResponse.message);
      }
    } on DioException catch (e) {
      AppLogger.error('Auction creation error', error: e);
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      AppLogger.error('Unexpected auction creation error', error: e);
      return ApiResult.failure('Failed to create auction');
    }
  }

  /// Upload auction images
  Future<ApiResult<List<String>>> uploadImages(List<File> images) async {
    try {
      AppLogger.info('Uploading ${images.length} auction images');

      final formData = FormData();

      for (int i = 0; i < images.length; i++) {
        final file = images[i];
        final fileName =
            'auction_image_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';

        formData.files.add(
          MapEntry(
            'images',
            await MultipartFile.fromFile(
              file.path,
              filename: fileName,
            ),
          ),
        );
      }

      final response = await _apiClient.post(
        '/auctions/upload-images',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      final imageUrls =
          (response.data['imageUrls'] as List<dynamic>).cast<String>();

      AppLogger.info('Images uploaded successfully: ${imageUrls.length} URLs');
      return ApiResult.success(imageUrls);
    } on DioException catch (e) {
      AppLogger.error('Image upload error', error: e);
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      AppLogger.error('Unexpected image upload error', error: e);
      return ApiResult.failure('Failed to upload images');
    }
  }

  /// Get user's auctions
  Future<ApiResult<List<AuctionModel>>> getUserAuctions({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      AppLogger.info('Fetching user auctions - page: $page, limit: $limit');

      final queryParams = {
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
      };

      final response = await _apiClient.get(
        '/auctions/my-auctions',
        queryParameters: queryParams,
      );

      final auctions = (response.data['auctions'] as List<dynamic>)
          .map((json) => AuctionModel.fromJson(json))
          .toList();

      AppLogger.info('Fetched ${auctions.length} user auctions');
      return ApiResult.success(auctions);
    } on DioException catch (e) {
      AppLogger.error('Get user auctions error', error: e);
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      AppLogger.error('Unexpected get user auctions error', error: e);
      return ApiResult.failure('Failed to fetch auctions');
    }
  }

  /// Update auction
  Future<ApiResult<AuctionModel>> updateAuction(
    int auctionId,
    CreateAuctionRequest request,
  ) async {
    try {
      AppLogger.info('Updating auction: $auctionId');

      final response = await _apiClient.put(
        '/auctions/$auctionId',
        data: request.toJson(),
      );

      final auction = AuctionModel.fromJson(response.data['auction']);

      AppLogger.info('Auction updated successfully: $auctionId');
      return ApiResult.success(auction);
    } on DioException catch (e) {
      AppLogger.error('Update auction error', error: e);
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      AppLogger.error('Unexpected update auction error', error: e);
      return ApiResult.failure('Failed to update auction');
    }
  }

  /// Delete auction
  Future<ApiResult<bool>> deleteAuction(int auctionId) async {
    try {
      AppLogger.info('Deleting auction: $auctionId');

      await _apiClient.delete('/auctions/$auctionId');

      AppLogger.info('Auction deleted successfully: $auctionId');
      return ApiResult.success(true);
    } on DioException catch (e) {
      AppLogger.error('Delete auction error', error: e);
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      AppLogger.error('Unexpected delete auction error', error: e);
      return ApiResult.failure('Failed to delete auction');
    }
  }

  /// End auction early
  Future<ApiResult<AuctionModel>> endAuctionEarly(int auctionId) async {
    try {
      AppLogger.info('Ending auction early: $auctionId');

      final response = await _apiClient.post('/auctions/$auctionId/end');

      final auction = AuctionModel.fromJson(response.data['auction']);

      AppLogger.info('Auction ended early successfully: $auctionId');
      return ApiResult.success(auction);
    } on DioException catch (e) {
      AppLogger.error('End auction early error', error: e);
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      AppLogger.error('Unexpected end auction early error', error: e);
      return ApiResult.failure('Failed to end auction');
    }
  }

  /// Get auction categories
  Future<ApiResult<List<CategoryModel>>> getCategories() async {
    try {
      AppLogger.info('Fetching auction categories');

      final response = await _apiClient.get('/categories');

      // API returns array directly, not wrapped in 'categories' key
      final categoriesData = response.data is List
          ? response.data as List<dynamic>
          : (response.data as Map<String, dynamic>)['categories']
              as List<dynamic>;

      final categories =
          categoriesData.map((json) => CategoryModel.fromJson(json)).toList();

      AppLogger.info('Fetched ${categories.length} categories');
      return ApiResult.success(categories);
    } on DioException catch (e) {
      AppLogger.error('Get categories error', error: e);
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      AppLogger.error('Unexpected get categories error', error: e);
      return ApiResult.failure('Failed to fetch categories');
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? 'Server error';

        switch (statusCode) {
          case 400:
            return 'Invalid request: $message';
          case 401:
            return 'Authentication required. Please log in again.';
          case 403:
            return 'Access denied: $message';
          case 404:
            return 'Resource not found';
          case 422:
            return 'Validation error: $message';
          case 500:
            return 'Server error. Please try again later.';
          default:
            return message;
        }
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet connection.';
      default:
        return 'Network error occurred';
    }
  }
}

// Provider
final auctionCreationRepositoryProvider =
    Provider<AuctionCreationRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AuctionCreationRepository(apiClient);
});
