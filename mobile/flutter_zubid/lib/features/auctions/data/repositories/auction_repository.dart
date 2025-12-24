import 'dart:io';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/utils/logger.dart';
import '../models/auction_model.dart';
import '../models/category_model.dart';
import '../models/auction_search_filters.dart';
import '../models/bid_model.dart';

class AuctionRepository {
  final ApiClient _apiClient;

  AuctionRepository(this._apiClient);

  // Get auctions with pagination and filters
  Future<ApiResult<List<AuctionModel>>> getAuctions({
    int page = 1,
    int limit = 20,
    String? search,
    AuctionSearchFilters? filters,
  }) async {
    try {
      AppLogger.info('Fetching auctions - page: $page, limit: $limit');

      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (filters != null) {
        queryParams.addAll(filters.toJson());
      }

      final response = await _apiClient.get(
        '/auctions',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final auctionsData = data['auctions'] as List<dynamic>;
        
        final auctions = auctionsData
            .map((json) => AuctionModel.fromJson(json as Map<String, dynamic>))
            .toList();

        AppLogger.info('Successfully fetched ${auctions.length} auctions');
        return ApiResult.success(auctions);
      } else {
        AppLogger.warning('Failed to fetch auctions: ${response.statusCode}');
        return ApiResult.error('Failed to load auctions');
      }
    } catch (e) {
      AppLogger.error('Error fetching auctions', error: e);
      return ApiResult.error('Network error: ${e.toString()}');
    }
  }

  // Get auction by ID
  Future<ApiResult<AuctionModel>> getAuctionById(int id) async {
    try {
      AppLogger.info('Fetching auction details for ID: $id');

      final response = await _apiClient.get('/auctions/$id');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final auction = AuctionModel.fromJson(data['auction']);

        AppLogger.info('Successfully fetched auction: ${auction.title}');
        return ApiResult.success(auction);
      } else {
        AppLogger.warning('Failed to fetch auction: ${response.statusCode}');
        return ApiResult.error('Failed to load auction details');
      }
    } catch (e) {
      AppLogger.error('Error fetching auction details', error: e);
      return ApiResult.error('Network error: ${e.toString()}');
    }
  }

  // Get featured auctions
  Future<ApiResult<List<AuctionModel>>> getFeaturedAuctions({
    int limit = 10,
  }) async {
    try {
      AppLogger.info('Fetching featured auctions');

      final response = await _apiClient.get(
        '/auctions/featured',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final auctionsData = data['auctions'] as List<dynamic>;
        
        final auctions = auctionsData
            .map((json) => AuctionModel.fromJson(json as Map<String, dynamic>))
            .toList();

        AppLogger.info('Successfully fetched ${auctions.length} featured auctions');
        return ApiResult.success(auctions);
      } else {
        AppLogger.warning('Failed to fetch featured auctions: ${response.statusCode}');
        return ApiResult.error('Failed to load featured auctions');
      }
    } catch (e) {
      AppLogger.error('Error fetching featured auctions', error: e);
      return ApiResult.error('Network error: ${e.toString()}');
    }
  }

  // Get ending soon auctions
  Future<ApiResult<List<AuctionModel>>> getEndingSoonAuctions({
    int limit = 10,
  }) async {
    try {
      AppLogger.info('Fetching ending soon auctions');

      final response = await _apiClient.get(
        '/auctions/ending-soon',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final auctionsData = data['auctions'] as List<dynamic>;
        
        final auctions = auctionsData
            .map((json) => AuctionModel.fromJson(json as Map<String, dynamic>))
            .toList();

        AppLogger.info('Successfully fetched ${auctions.length} ending soon auctions');
        return ApiResult.success(auctions);
      } else {
        AppLogger.warning('Failed to fetch ending soon auctions: ${response.statusCode}');
        return ApiResult.error('Failed to load ending soon auctions');
      }
    } catch (e) {
      AppLogger.error('Error fetching ending soon auctions', error: e);
      return ApiResult.error('Network error: ${e.toString()}');
    }
  }

  // Get categories
  Future<ApiResult<List<CategoryModel>>> getCategories() async {
    try {
      AppLogger.info('Fetching categories');

      final response = await _apiClient.get('/api/categories');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final categoriesData = data['categories'] as List<dynamic>;
        
        final categories = categoriesData
            .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
            .toList();

        AppLogger.info('Successfully fetched ${categories.length} categories');
        return ApiResult.success(categories);
      } else {
        AppLogger.warning('Failed to fetch categories: ${response.statusCode}');
        return ApiResult.error('Failed to load categories');
      }
    } catch (e) {
      AppLogger.error('Error fetching categories', error: e);
      return ApiResult.error('Network error: ${e.toString()}');
    }
  }

  // Add to watchlist
  Future<ApiResult<bool>> addToWatchlist(int auctionId) async {
    try {
      AppLogger.info('Adding auction $auctionId to watchlist');

      final response = await _apiClient.post(
        '/api/watchlist',
        data: {'auction_id': auctionId},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.info('Successfully added auction to watchlist');
        return ApiResult.success(true);
      } else {
        AppLogger.warning('Failed to add to watchlist: ${response.statusCode}');
        return ApiResult.error('Failed to add to watchlist');
      }
    } catch (e) {
      AppLogger.error('Error adding to watchlist', error: e);
      return ApiResult.error('Network error: ${e.toString()}');
    }
  }

  // Remove from watchlist
  Future<ApiResult<bool>> removeFromWatchlist(int auctionId) async {
    try {
      AppLogger.info('Removing auction $auctionId from watchlist');

      final response = await _apiClient.delete('/api/watchlist/$auctionId');

      if (response.statusCode == 200 || response.statusCode == 204) {
        AppLogger.info('Successfully removed auction from watchlist');
        return ApiResult.success(true);
      } else {
        AppLogger.warning('Failed to remove from watchlist: ${response.statusCode}');
        return ApiResult.error('Failed to remove from watchlist');
      }
    } catch (e) {
      AppLogger.error('Error removing from watchlist', error: e);
      return ApiResult.error('Network error: ${e.toString()}');
    }
  }

  // Get watchlist
  Future<ApiResult<List<AuctionModel>>> getWatchlist({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      AppLogger.info('Fetching watchlist - page: $page, limit: $limit');

      final response = await _apiClient.get(
        '/api/watchlist',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final auctionsData = data['auctions'] as List<dynamic>;
        
        final auctions = auctionsData
            .map((json) => AuctionModel.fromJson(json as Map<String, dynamic>))
            .toList();

        AppLogger.info('Successfully fetched ${auctions.length} watchlist items');
        return ApiResult.success(auctions);
      } else {
        AppLogger.warning('Failed to fetch watchlist: ${response.statusCode}');
        return ApiResult.error('Failed to load watchlist');
      }
    } catch (e) {
      AppLogger.error('Error fetching watchlist', error: e);
      return ApiResult.error('Network error: ${e.toString()}');
    }
  }

  // Get single auction by ID
  Future<ApiResult<AuctionModel>> getAuction(String auctionId) async {
    try {
      AppLogger.info('Fetching auction: $auctionId');

      final response = await _apiClient.get('/auctions/$auctionId');

      if (response.statusCode == 200) {
        final auction = AuctionModel.fromJson(response.data);
        return ApiResult.success(auction);
      } else {
        return ApiResult.error('Failed to fetch auction');
      }
    } catch (e) {
      AppLogger.error('Error fetching auction', error: e);
      return ApiResult.error('Network error: ${e.toString()}');
    }
  }

  // Get auction bids
  Future<ApiResult<List<BidModel>>> getAuctionBids(String auctionId) async {
    try {
      AppLogger.info('Fetching bids for auction: $auctionId');

      final response = await _apiClient.get('/auctions/$auctionId/bids');

      if (response.statusCode == 200) {
        final List<dynamic> bidsJson = response.data['bids'] ?? [];
        final bids = bidsJson.map((json) => BidModel.fromJson(json)).toList();
        return ApiResult.success(bids);
      } else {
        return ApiResult.error('Failed to fetch auction bids');
      }
    } catch (e) {
      AppLogger.error('Error fetching auction bids', error: e);
      return ApiResult.error('Network error: ${e.toString()}');
    }
  }
}
