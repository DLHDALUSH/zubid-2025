import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/logger.dart';
import '../data/models/bid_model.dart';
import '../data/repositories/bidding_repository.dart';

// Bidding State
class BiddingState {
  final bool isLoading;
  final String? error;
  final List<BidModel> bids;
  final BidModel? lastBid;

  const BiddingState({
    this.isLoading = false,
    this.error,
    this.bids = const [],
    this.lastBid,
  });

  BiddingState copyWith({
    bool? isLoading,
    String? error,
    List<BidModel>? bids,
    BidModel? lastBid,
  }) {
    return BiddingState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      bids: bids ?? this.bids,
      lastBid: lastBid ?? this.lastBid,
    );
  }

  bool get hasError => error != null;
  bool get hasBids => bids.isNotEmpty;
}

// Bidding Notifier
class BiddingNotifier extends StateNotifier<BiddingState> {
  final BiddingRepository _repository;
  final String auctionId;

  BiddingNotifier(this._repository, this.auctionId) : super(const BiddingState()) {
    loadBids();
  }

  Future<void> loadBids() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final bids = await _repository.getBids(auctionId);
      state = state.copyWith(
        isLoading: false,
        bids: bids,
        lastBid: bids.isNotEmpty ? bids.first : null,
      );
      
      AppLogger.info('Loaded ${bids.length} bids for auction $auctionId');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load bids: ${e.toString()}',
      );
      AppLogger.error('Failed to load bids for auction $auctionId', e);
    }
  }

  Future<bool> placeBid(double amount) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final bid = await _repository.placeBid(auctionId, amount);
      
      // Add the new bid to the list
      final updatedBids = [bid, ...state.bids];
      
      state = state.copyWith(
        isLoading: false,
        bids: updatedBids,
        lastBid: bid,
      );
      
      AppLogger.userAction('Bid placed successfully: \$${amount.toStringAsFixed(2)} on auction $auctionId');
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      AppLogger.error('Failed to place bid on auction $auctionId', e);
      return false;
    }
  }

  Future<bool> buyNow() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.buyNow(auctionId);
      
      state = state.copyWith(isLoading: false);
      
      AppLogger.userAction('Buy now successful for auction $auctionId');
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      AppLogger.error('Failed to buy now for auction $auctionId', e);
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void refresh() {
    loadBids();
  }
}

// Providers
final biddingRepositoryProvider = Provider<BiddingRepository>((ref) {
  return BiddingRepository();
});

final biddingProvider = StateNotifierProvider.family<BiddingNotifier, BiddingState, String>(
  (ref, auctionId) {
    final repository = ref.watch(biddingRepositoryProvider);
    return BiddingNotifier(repository, auctionId);
  },
);

// Convenience providers
final bidsProvider = Provider.family<List<BidModel>, String>((ref, auctionId) {
  return ref.watch(biddingProvider(auctionId)).bids;
});

final lastBidProvider = Provider.family<BidModel?, String>((ref, auctionId) {
  return ref.watch(biddingProvider(auctionId)).lastBid;
});

final biddingErrorProvider = Provider.family<String?, String>((ref, auctionId) {
  return ref.watch(biddingProvider(auctionId)).error;
});

final biddingLoadingProvider = Provider.family<bool, String>((ref, auctionId) {
  return ref.watch(biddingProvider(auctionId)).isLoading;
});
