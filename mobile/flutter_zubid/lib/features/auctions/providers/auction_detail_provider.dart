import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../data/models/auction_model.dart';
import '../data/repositories/auction_repository.dart';

// State class for auction detail
class AuctionDetailState {
  final AuctionModel? auction;
  final bool isLoading;
  final String? error;
  final bool isWatchlisted;

  const AuctionDetailState({
    this.auction,
    this.isLoading = false,
    this.error,
    this.isWatchlisted = false,
  });

  AuctionDetailState copyWith({
    AuctionModel? auction,
    bool? isLoading,
    String? error,
    bool? isWatchlisted,
  }) {
    return AuctionDetailState(
      auction: auction ?? this.auction,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isWatchlisted: isWatchlisted ?? this.isWatchlisted,
    );
  }

  bool get hasAuction => auction != null;
  bool get hasError => error != null;
}

// Notifier for auction detail
class AuctionDetailNotifier extends StateNotifier<AuctionDetailState> {
  final AuctionRepository _repository;
  final String auctionId;

  AuctionDetailNotifier(this._repository, this.auctionId)
      : super(const AuctionDetailState()) {
    loadAuction();
  }

  // Load auction details
  Future<void> loadAuction() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      AppLogger.info('Loading auction details: $auctionId');

      final result = await _repository.getAuction(auctionId);

      result.when(
        success: (auction) {
          state = state.copyWith(
            auction: auction,
            isLoading: false,
            isWatchlisted: auction.isWatched,
          );
          AppLogger.info('Successfully loaded auction: ${auction.title}');
        },
        error: (errorMessage) {
          state = state.copyWith(
            isLoading: false,
            error: errorMessage,
          );
          AppLogger.warning('Failed to load auction: $errorMessage');
        },
      );
    } catch (e) {
      AppLogger.error('Failed to load auction $auctionId', error: e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Toggle watchlist status
  Future<void> toggleWatchlist() async {
    if (!state.hasAuction) return;

    final auction = state.auction!;
    final newWatchStatus = !state.isWatchlisted;

    try {
      AppLogger.info(
          'Toggling watchlist for auction ${auction.id}: $newWatchStatus');

      // Optimistically update UI
      state = state.copyWith(isWatchlisted: newWatchStatus);

      // Use add or remove based on new status
      if (newWatchStatus) {
        await _repository.addToWatchlist(auction.id);
      } else {
        await _repository.removeFromWatchlist(auction.id);
      }

      AppLogger.info(
          'Successfully toggled watchlist for auction ${auction.id}');
    } catch (e) {
      AppLogger.error('Failed to toggle watchlist for auction ${auction.id}',
          error: e);

      // Revert optimistic update
      state = state.copyWith(isWatchlisted: !newWatchStatus);

      // Could show error message here
      rethrow;
    }
  }

  // Refresh auction data
  Future<void> refresh() async {
    await loadAuction();
  }

  // Update auction in state (for real-time updates)
  void updateAuction(AuctionModel updatedAuction) {
    if (state.hasAuction && state.auction!.id == updatedAuction.id) {
      state = state.copyWith(
        auction: updatedAuction,
        isWatchlisted: updatedAuction.isWatched,
      );
    }
  }
}

// Provider for auction detail
final auctionDetailProvider = StateNotifierProvider.family<
    AuctionDetailNotifier, AuctionDetailState, String>(
  (ref, auctionId) {
    final repository = ref.watch(auctionRepositoryProvider);
    return AuctionDetailNotifier(repository, auctionId);
  },
);

// Provider for auction repository
final auctionRepositoryProvider = Provider<AuctionRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuctionRepository(apiClient);
});

// Convenience providers
final currentAuctionProvider =
    Provider.family<AuctionModel?, String>((ref, auctionId) {
  return ref.watch(auctionDetailProvider(auctionId)).auction;
});

final isAuctionWatchlistedProvider =
    Provider.family<bool, String>((ref, auctionId) {
  return ref.watch(auctionDetailProvider(auctionId)).isWatchlisted;
});

final auctionLoadingProvider = Provider.family<bool, String>((ref, auctionId) {
  return ref.watch(auctionDetailProvider(auctionId)).isLoading;
});

final auctionErrorProvider = Provider.family<String?, String>((ref, auctionId) {
  return ref.watch(auctionDetailProvider(auctionId)).error;
});
