import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/auction_model.dart';
import '../../data/models/bid_model.dart';
import '../../data/repositories/auction_repository.dart';
import '../../data/providers/auction_providers.dart';
import '../../../../core/utils/logger.dart';

// Auction Detail State
class AuctionDetailState {
  final bool isLoading;
  final AuctionModel? auction;
  final List<BidModel> bids;
  final String? error;

  const AuctionDetailState({
    this.isLoading = false,
    this.auction,
    this.bids = const [],
    this.error,
  });

  AuctionDetailState copyWith({
    bool? isLoading,
    AuctionModel? auction,
    List<BidModel>? bids,
    String? error,
  }) {
    return AuctionDetailState(
      isLoading: isLoading ?? this.isLoading,
      auction: auction ?? this.auction,
      bids: bids ?? this.bids,
      error: error,
    );
  }
}

// Auction Detail Provider (Riverpod 3.x)
class AuctionDetailNotifier extends Notifier<AuctionDetailState> {
  AuctionDetailNotifier(this.auctionId);

  final String auctionId;
  late final AuctionRepository _auctionRepository;

  @override
  AuctionDetailState build() {
    _auctionRepository = ref.read(auctionRepositoryProvider);
    return const AuctionDetailState();
  }

  Future<void> loadAuction() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _auctionRepository.getAuction(auctionId);

      result.when(
        success: (auction) {
          state = state.copyWith(
            isLoading: false,
            auction: auction,
          );
          AppLogger.info('Auction loaded successfully: $auctionId');

          // Load bids for this auction
          _loadBids();
        },
        error: (error) {
          state = state.copyWith(
            isLoading: false,
            error: error,
          );
          AppLogger.error('Failed to load auction: $auctionId', error: error);
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
      AppLogger.error('Auction loading exception', error: e);
    }
  }

  Future<void> _loadBids() async {
    try {
      final result = await _auctionRepository.getAuctionBids(auctionId);

      result.when(
        success: (bids) {
          state = state.copyWith(bids: bids);
          AppLogger.info('Loaded ${bids.length} bids for auction: $auctionId');
        },
        error: (error) {
          AppLogger.error('Failed to load bids for auction: $auctionId',
              error: error);
        },
      );
    } catch (e) {
      AppLogger.error('Bid loading exception', error: e);
    }
  }

  Future<bool> toggleWatchlist() async {
    if (state.auction == null) return false;

    try {
      // Implementation for watchlist toggle
      AppLogger.info('Toggle watchlist for auction: $auctionId');
      return true;
    } catch (e) {
      AppLogger.error('Failed to toggle watchlist', error: e);
      return false;
    }
  }

  Future<void> refresh() async {
    await loadAuction();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider factory
final auctionDetailProvider =
    NotifierProvider.family<AuctionDetailNotifier, AuctionDetailState, String>(
  (auctionId) => AuctionDetailNotifier(auctionId),
);
