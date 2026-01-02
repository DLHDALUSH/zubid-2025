import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/utils/logger.dart';
import '../models/bid_model.dart';
import '../models/bid_request_models.dart';

class BiddingRepository {
  final ApiClient _apiClient;

  BiddingRepository(this._apiClient);

  // Get bids for an auction
  Future<List<BidModel>> getBids(String auctionId) async {
    try {
      AppLogger.info('Fetching bids for auction: $auctionId');

      final result = await _apiClient.get('/auctions/$auctionId/bids');

      final List<dynamic> bidsJson = result.data['bids'] ?? [];
      final bids = bidsJson.map((json) => BidModel.fromJson(json)).toList();

      AppLogger.info(
          'Successfully fetched ${bids.length} bids for auction $auctionId');
      return bids;
    } catch (e) {
      AppLogger.error('Error fetching bids for auction $auctionId', error: e);
      rethrow;
    }
  }

  // Place a bid on an auction
  Future<ApiResult<BidModel>> placeBid(PlaceBidRequest request) async {
    try {
      AppLogger.info(
          'Placing bid of \$${request.amount.toStringAsFixed(2)} on auction ${request.auctionId}');

      // Backend expects just 'amount' field, not the full request object
      final data = <String, dynamic>{
        'amount': request.amount,
      };

      // Add optional auto-bid fields if present
      if (request.isAutoBid == true) {
        data['auto_bid'] = true;
        if (request.maxBidAmount != null) {
          data['auto_bid_amount'] = request.maxBidAmount;
        }
      }

      final result = await _apiClient.post(
        '/auctions/${request.auctionId}/bids',
        data: data,
      );

      if (result.statusCode == 200 || result.statusCode == 201) {
        // Backend now returns full bid object
        if (result.data['bid'] != null) {
          final bid = BidModel.fromJson(result.data['bid']);
          AppLogger.info('Successfully placed bid: ${bid.id}');
          return ApiResult.success(bid);
        } else {
          // Fallback: Create bid from response data if 'bid' key not present
          final bidId = result.data['bid_id'] ?? 0;
          final currentBid =
              result.data['current_bid']?.toDouble() ?? request.amount;

          final bid = BidModel(
            id: bidId is int ? bidId : int.tryParse(bidId.toString()) ?? 0,
            auctionId: int.tryParse(request.auctionId) ?? 0,
            userId: 0, // Will be filled by local user data
            amount: currentBid,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isWinning: true,
            isAutoBid: request.isAutoBid ?? false,
            maxBidAmount: request.maxBidAmount,
            username: 'You',
          );
          AppLogger.info(
              'Successfully placed bid: ${bid.id} (fallback parsing)');
          return ApiResult.success(bid);
        }
      } else {
        final errorMsg = result.data['error'] ?? 'Failed to place bid';
        return ApiResult.error(errorMsg);
      }
    } catch (e) {
      AppLogger.error('Error placing bid on auction ${request.auctionId}',
          error: e);
      // Extract error message from DioException if possible
      String errorMessage = 'Failed to place bid';

      // Try to extract meaningful error message
      final errorString = e.toString();
      if (errorString.contains('401')) {
        errorMessage = 'Please log in to place a bid';
      } else if (errorString.contains('400')) {
        // Try to get the specific error from response
        if (errorString.contains('must be at least')) {
          final match =
              RegExp(r'Bid must be at least \$[\d.]+').firstMatch(errorString);
          errorMessage = match?.group(0) ?? 'Bid amount too low';
        } else if (errorString.contains('not active')) {
          errorMessage = 'This auction is no longer active';
        } else if (errorString.contains('own auction')) {
          errorMessage = 'You cannot bid on your own auction';
        } else if (errorString.contains('ended')) {
          errorMessage = 'This auction has ended';
        } else {
          errorMessage = 'Invalid bid. Please try again.';
        }
      } else if (errorString.contains('429')) {
        errorMessage = 'Too many bids. Please wait a moment.';
      } else if (errorString.contains('connection') ||
          errorString.contains('network')) {
        errorMessage = 'Network error. Please check your connection.';
      }

      return ApiResult.error(errorMessage);
    }
  }

  // Place an auto bid with maximum amount
  Future<BidModel> placeAutoBid(
      String auctionId, double currentBid, double maxBid) async {
    try {
      AppLogger.info(
          'Placing auto bid on auction $auctionId: current=\$${currentBid.toStringAsFixed(2)}, max=\$${maxBid.toStringAsFixed(2)}');

      final request = PlaceBidRequest(
        auctionId: auctionId,
        amount: currentBid,
        isAutoBid: true,
        maxBidAmount: maxBid,
      );

      final result = await _apiClient.post(
        '/auctions/$auctionId/bids',
        data: request.toJson(),
      );

      final bid = BidModel.fromJson(result.data['bid']);
      AppLogger.info('Successfully placed auto bid: ${bid.id}');
      return bid;
    } catch (e) {
      AppLogger.error('Error placing auto bid on auction $auctionId', error: e);
      rethrow;
    }
  }

  // Buy now - instant purchase
  Future<ApiResult<void>> buyNow(BuyNowRequest request) async {
    try {
      AppLogger.info('Processing buy now for auction ${request.auctionId}');

      final result = await _apiClient.post(
        '/auctions/${request.auctionId}/buy-now',
        data: request.toJson(),
      );

      if (result.statusCode == 200 || result.statusCode == 201) {
        AppLogger.info(
            'Successfully processed buy now for auction ${request.auctionId}');
        return const ApiResult.success(null);
      } else {
        return const ApiResult.error('Failed to complete buy now');
      }
    } catch (e) {
      AppLogger.error(
          'Error processing buy now for auction ${request.auctionId}',
          error: e);
      return ApiResult.error('Network error: ${e.toString()}');
    }
  }

  // Get bid history for a user
  Future<List<BidModel>> getUserBids({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      AppLogger.info(
          'Fetching user bids: page=$page, limit=$limit, status=$status');

      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
      };

      final result =
          await _apiClient.get('/user/bids', queryParameters: queryParams);

      if (result.statusCode == 200) {
        final List<dynamic> bidsJson = result.data['bids'] ?? [];
        final bids = bidsJson.map((json) => BidModel.fromJson(json)).toList();

        AppLogger.info('Successfully fetched ${bids.length} user bids');
        return bids;
      } else {
        AppLogger.error('Failed to fetch user bids',
            error: 'Status code: ${result.statusCode}');
        throw Exception('Failed to load your bids');
      }
    } catch (e) {
      AppLogger.error('Error fetching user bids', error: e);
      rethrow;
    }
  }

  // Get winning bids for a user
  Future<List<BidModel>> getWinningBids() async {
    try {
      AppLogger.info('Fetching winning bids');

      final result = await _apiClient.get('/user/bids/winning');

      if (result.statusCode == 200) {
        final List<dynamic> bidsJson = result.data['bids'] ?? [];
        final bids = bidsJson.map((json) => BidModel.fromJson(json)).toList();

        AppLogger.info('Successfully fetched ${bids.length} winning bids');
        return bids;
      } else {
        AppLogger.error('Failed to fetch winning bids',
            error: 'Status code: ${result.statusCode}');
        throw Exception('Failed to load winning bids');
      }
    } catch (e) {
      AppLogger.error('Error fetching winning bids', error: e);
      rethrow;
    }
  }

  // Cancel a bid (if allowed)
  Future<void> cancelBid(int bidId) async {
    try {
      AppLogger.info('Cancelling bid: $bidId');

      final result = await _apiClient.delete('/bids/$bidId');

      if (result.statusCode == 200 || result.statusCode == 204) {
        AppLogger.info('Successfully cancelled bid: $bidId');
      } else {
        AppLogger.error('Failed to cancel bid: $bidId',
            error: 'Status code: ${result.statusCode}');
        throw Exception('Failed to cancel bid');
      }
    } catch (e) {
      AppLogger.error('Error cancelling bid: $bidId', error: e);
      rethrow;
    }
  }
}
