import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/auction_model.dart';
import '../../data/repositories/auction_repository.dart';
import '../../data/providers/auction_providers.dart';
import '../../../../core/utils/logger.dart';

// Watchlist State
class WatchlistState {
  final List<AuctionModel> auctions;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasMoreData;

  const WatchlistState({
    this.auctions = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.hasMoreData = true,
  });

  // Computed properties
  bool get hasAuctions => auctions.isNotEmpty;
  bool get hasError => error != null;

  WatchlistState copyWith({
    List<AuctionModel>? auctions,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasMoreData,
  }) {
    return WatchlistState(
      auctions: auctions ?? this.auctions,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMoreData: hasMoreData ?? this.hasMoreData,
    );
  }
}

// Watchlist Notifier
class WatchlistNotifier extends Notifier<WatchlistState> {
  late final AuctionRepository _auctionRepository;

  @override
  WatchlistState build() {
    _auctionRepository = ref.read(auctionRepositoryProvider);
    return const WatchlistState();
  }

  // Load watchlist
  Future<void> loadWatchlist({bool refresh = false}) async {
    if (state.isLoading && !refresh) return;

    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        currentPage: 1,
        hasMoreData: true,
      );
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      AppLogger.info('Loading watchlist - page: ${state.currentPage}');

      final result = await _auctionRepository.getWatchList(
        page: refresh ? 1 : state.currentPage,
        limit: 20,
      );

      result.when(
        success: (auctions) {
          final updatedAuctions =
              refresh ? auctions : [...state.auctions, ...auctions];

          state = state.copyWith(
            auctions: updatedAuctions,
            isLoading: false,
            hasMoreData: auctions.length >= 20,
            currentPage: refresh ? 2 : state.currentPage + 1,
          );

          AppLogger.info(
              'Watchlist loaded successfully: ${auctions.length} items');
        },
        error: (error) {
          state = state.copyWith(
            isLoading: false,
            error: error,
          );
          AppLogger.error('Failed to load watchlist', error: error);
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
      AppLogger.error('Watchlist loading exception', error: e);
    }
  }

  // Load more watchlist items
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMoreData) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final result = await _auctionRepository.getWatchList(
        page: state.currentPage,
        limit: 20,
      );

      result.when(
        success: (auctions) {
          state = state.copyWith(
            auctions: [...state.auctions, ...auctions],
            isLoadingMore: false,
            hasMoreData: auctions.length >= 20,
            currentPage: state.currentPage + 1,
          );
        },
        error: (error) {
          state = state.copyWith(isLoadingMore: false);
          AppLogger.error('Failed to load more watchlist items', error: error);
        },
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
      AppLogger.error('Load more watchlist exception', error: e);
    }
  }

  // Refresh watchlist
  Future<void> refresh() async {
    await loadWatchlist(refresh: true);
  }

  // Remove from watchlist
  Future<bool> removeFromWatchlist(int auctionId) async {
    try {
      final result = await _auctionRepository.removeFromWatchList(auctionId);

      return result.when(
        success: (success) {
          // Remove from local state
          final updatedAuctions = state.auctions
              .where((auction) => auction.id != auctionId)
              .toList();
          state = state.copyWith(auctions: updatedAuctions);

          AppLogger.info('Removed auction $auctionId from watchlist');
          return true;
        },
        error: (error) {
          AppLogger.error('Failed to remove from watchlist', error: error);
          return false;
        },
      );
    } catch (e) {
      AppLogger.error('Remove from watchlist exception', error: e);
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final watchlistProvider = NotifierProvider<WatchlistNotifier, WatchlistState>(
  WatchlistNotifier.new,
);
