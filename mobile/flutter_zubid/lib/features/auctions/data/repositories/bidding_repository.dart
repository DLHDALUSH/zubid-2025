import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/utils/logger.dart';
import '../models/bid_model.dart';

class BiddingRepository {
  final ApiClient _apiClient = ApiClient();

  // Get bids for an auction
  Future<List<BidModel>> getBids(String auctionId) async {
    try {
      AppLogger.info('Fetching bids for auction: $auctionId');
      
      final result = await _apiClient.get('/auctions/$auctionId/bids');
      
      return result.when(
        success: (data) {
          final List<dynamic> bidsJson = data['bids'] ?? [];
          final bids = bidsJson.map((json) => BidModel.fromJson(json)).toList();
          
          AppLogger.info('Successfully fetched ${bids.length} bids for auction $auctionId');
          return bids;
        },
        failure: (error) {
          AppLogger.error('Failed to fetch bids for auction $auctionId', error);
          throw Exception('Failed to load bids: ${error.message}');
        },
      );
    } catch (e) {
      AppLogger.error('Error fetching bids for auction $auctionId', e);
      rethrow;
    }
  }

  // Place a bid on an auction
  Future<BidModel> placeBid(String auctionId, double amount) async {
    try {
      AppLogger.info('Placing bid of \$${amount.toStringAsFixed(2)} on auction $auctionId');
      
      final request = PlaceBidRequest(
        auctionId: auctionId,
        amount: amount,
      );
      
      final result = await _apiClient.post(
        '/auctions/$auctionId/bids',
        data: request.toJson(),
      );
      
      return result.when(
        success: (data) {
          final bid = BidModel.fromJson(data['bid']);
          AppLogger.info('Successfully placed bid: ${bid.id}');
          return bid;
        },
        failure: (error) {
          AppLogger.error('Failed to place bid on auction $auctionId', error);
          throw Exception(error.message);
        },
      );
    } catch (e) {
      AppLogger.error('Error placing bid on auction $auctionId', e);
      rethrow;
    }
  }

  // Place an auto bid with maximum amount
  Future<BidModel> placeAutoBid(String auctionId, double currentBid, double maxBid) async {
    try {
      AppLogger.info('Placing auto bid on auction $auctionId: current=\$${currentBid.toStringAsFixed(2)}, max=\$${maxBid.toStringAsFixed(2)}');
      
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
      
      return result.when(
        success: (data) {
          final bid = BidModel.fromJson(data['bid']);
          AppLogger.info('Successfully placed auto bid: ${bid.id}');
          return bid;
        },
        failure: (error) {
          AppLogger.error('Failed to place auto bid on auction $auctionId', error);
          throw Exception(error.message);
        },
      );
    } catch (e) {
      AppLogger.error('Error placing auto bid on auction $auctionId', e);
      rethrow;
    }
  }

  // Buy now - instant purchase
  Future<void> buyNow(String auctionId) async {
    try {
      AppLogger.info('Processing buy now for auction $auctionId');
      
      final request = BuyNowRequest(auctionId: auctionId);
      
      final result = await _apiClient.post(
        '/auctions/$auctionId/buy-now',
        data: request.toJson(),
      );
      
      result.when(
        success: (data) {
          AppLogger.info('Successfully processed buy now for auction $auctionId');
        },
        failure: (error) {
          AppLogger.error('Failed to process buy now for auction $auctionId', error);
          throw Exception(error.message);
        },
      );
    } catch (e) {
      AppLogger.error('Error processing buy now for auction $auctionId', e);
      rethrow;
    }
  }

  // Get bid history for a user
  Future<List<BidModel>> getUserBids({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      AppLogger.info('Fetching user bids: page=$page, limit=$limit, status=$status');
      
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
      };
      
      final result = await _apiClient.get('/user/bids', queryParameters: queryParams);
      
      return result.when(
        success: (data) {
          final List<dynamic> bidsJson = data['bids'] ?? [];
          final bids = bidsJson.map((json) => BidModel.fromJson(json)).toList();
          
          AppLogger.info('Successfully fetched ${bids.length} user bids');
          return bids;
        },
        failure: (error) {
          AppLogger.error('Failed to fetch user bids', error);
          throw Exception('Failed to load your bids: ${error.message}');
        },
      );
    } catch (e) {
      AppLogger.error('Error fetching user bids', e);
      rethrow;
    }
  }

  // Get winning bids for a user
  Future<List<BidModel>> getWinningBids() async {
    try {
      AppLogger.info('Fetching winning bids');
      
      final result = await _apiClient.get('/user/bids/winning');
      
      return result.when(
        success: (data) {
          final List<dynamic> bidsJson = data['bids'] ?? [];
          final bids = bidsJson.map((json) => BidModel.fromJson(json)).toList();
          
          AppLogger.info('Successfully fetched ${bids.length} winning bids');
          return bids;
        },
        failure: (error) {
          AppLogger.error('Failed to fetch winning bids', error);
          throw Exception('Failed to load winning bids: ${error.message}');
        },
      );
    } catch (e) {
      AppLogger.error('Error fetching winning bids', e);
      rethrow;
    }
  }

  // Cancel a bid (if allowed)
  Future<void> cancelBid(int bidId) async {
    try {
      AppLogger.info('Cancelling bid: $bidId');
      
      final result = await _apiClient.delete('/bids/$bidId');
      
      result.when(
        success: (data) {
          AppLogger.info('Successfully cancelled bid: $bidId');
        },
        failure: (error) {
          AppLogger.error('Failed to cancel bid: $bidId', error);
          throw Exception(error.message);
        },
      );
    } catch (e) {
      AppLogger.error('Error cancelling bid: $bidId', e);
      rethrow;
    }
  }
}
