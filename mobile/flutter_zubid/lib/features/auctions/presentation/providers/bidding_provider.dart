import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/bid_model.dart';
import '../../data/models/bid_request_models.dart';
import '../../data/repositories/bidding_repository.dart';
import '../../data/providers/auction_providers.dart';
import '../../../../core/utils/logger.dart';

// Bidding State
class BiddingState {
  final bool isLoading;
  final bool isPlacingBid;
  final bool isBuyingNow;
  final List<BidModel> bids;
  final BidModel? latestBid;
  final String? error;

  const BiddingState({
    this.isLoading = false,
    this.isPlacingBid = false,
    this.isBuyingNow = false,
    this.bids = const [],
    this.latestBid,
    this.error,
  });

  // Computed properties
  bool get hasBids => bids.isNotEmpty;
  bool get hasError => error != null;

  BiddingState copyWith({
    bool? isLoading,
    bool? isPlacingBid,
    bool? isBuyingNow,
    List<BidModel>? bids,
    BidModel? latestBid,
    String? error,
  }) {
    return BiddingState(
      isLoading: isLoading ?? this.isLoading,
      isPlacingBid: isPlacingBid ?? this.isPlacingBid,
      isBuyingNow: isBuyingNow ?? this.isBuyingNow,
      bids: bids ?? this.bids,
      latestBid: latestBid ?? this.latestBid,
      error: error,
    );
  }
}

// Bidding Provider (Riverpod 3.x)
class BiddingNotifier extends Notifier<BiddingState> {
  BiddingNotifier(this.auctionId);

  final String auctionId;
  late final BiddingRepository _biddingRepository;

  @override
  BiddingState build() {
    _biddingRepository = ref.read(biddingRepositoryProvider);
    return const BiddingState();
  }

  Future<void> loadBids() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final bids = await _biddingRepository.getBids(auctionId);

      // Group bids by user_id and keep only the highest bid per user
      final Map<int, BidModel> bidsByUser = {};
      for (final bid in bids) {
        final userId = bid.userId;
        if (!bidsByUser.containsKey(userId) ||
            bid.amount > bidsByUser[userId]!.amount) {
          bidsByUser[userId] = bid;
        } else if (bid.amount == bidsByUser[userId]!.amount) {
          // If same amount, keep the most recent one
          if (bid.createdAt.isAfter(bidsByUser[userId]!.createdAt)) {
            bidsByUser[userId] = bid;
          }
        }
      }

      // Convert back to list and sort by amount (highest first)
      final sortedBids = bidsByUser.values.toList()
        ..sort((a, b) => b.amount.compareTo(a.amount));

      state = state.copyWith(
        isLoading: false,
        bids: sortedBids,
        latestBid: sortedBids.isNotEmpty ? sortedBids.first : null,
      );
      AppLogger.info(
          'Loaded ${bids.length} total bids, showing ${sortedBids.length} unique bidders for auction: $auctionId');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
      AppLogger.error('Bid loading exception', error: e);
    }
  }

  Future<bool> placeBid(double amount) async {
    state = state.copyWith(isPlacingBid: true, error: null);

    try {
      final request = PlaceBidRequest(
        auctionId: auctionId,
        amount: amount,
      );

      final result = await _biddingRepository.placeBid(request);

      return result.when(
        success: (bid) {
          // Add new bid to the list
          final updatedBids = [bid, ...state.bids];

          state = state.copyWith(
            isPlacingBid: false,
            bids: updatedBids,
            latestBid: bid,
          );
          AppLogger.info(
              'Bid placed successfully: \$${amount.toStringAsFixed(2)}');
          return true;
        },
        error: (error) {
          state = state.copyWith(
            isPlacingBid: false,
            error: error,
          );
          AppLogger.error('Failed to place bid', error: error);
          return false;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isPlacingBid: false,
        error: 'An unexpected error occurred',
      );
      AppLogger.error('Place bid exception', error: e);
      return false;
    }
  }

  Future<bool> buyNow(String paymentMethodId, {String? shippingAddress}) async {
    state = state.copyWith(isBuyingNow: true, error: null);

    try {
      final request = BuyNowRequest(
        auctionId: auctionId,
        paymentMethodId: paymentMethodId,
        shippingAddress: shippingAddress,
      );
      final result = await _biddingRepository.buyNow(request);

      return result.when(
        success: (success) {
          state = state.copyWith(isBuyingNow: false);
          AppLogger.info('Buy now successful for auction: $auctionId');
          return true;
        },
        error: (error) {
          state = state.copyWith(
            isBuyingNow: false,
            error: error,
          );
          AppLogger.error('Buy now failed', error: error);
          return false;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isBuyingNow: false,
        error: 'An unexpected error occurred',
      );
      AppLogger.error('Buy now exception', error: e);
      return false;
    }
  }

  Future<void> refresh() async {
    await loadBids();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider factory
final biddingProvider =
    NotifierProvider.family<BiddingNotifier, BiddingState, String>(
  (auctionId) => BiddingNotifier(auctionId),
);
