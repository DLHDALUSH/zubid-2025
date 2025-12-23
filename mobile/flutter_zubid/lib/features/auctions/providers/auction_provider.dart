import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../data/models/auction_model.dart';
import '../data/models/category_model.dart';
import '../data/repositories/auction_repository.dart';

// Repository provider
final auctionRepositoryProvider = Provider<AuctionRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuctionRepository(apiClient);
});

// Auction state
class AuctionState {
  final List<AuctionModel> auctions;
  final List<AuctionModel> featuredAuctions;
  final List<AuctionModel> endingSoonAuctions;
  final List<CategoryModel> categories;
  final List<AuctionModel> watchlist;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final int currentPage;
  final String? currentSearch;
  final AuctionSearchFilters? currentFilters;

  const AuctionState({
    this.auctions = const [],
    this.featuredAuctions = const [],
    this.endingSoonAuctions = const [],
    this.categories = const [],
    this.watchlist = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.currentPage = 1,
    this.currentSearch,
    this.currentFilters,
  });

  bool get hasAuctions => auctions.isNotEmpty;
  bool get hasFeaturedAuctions => featuredAuctions.isNotEmpty;
  bool get hasEndingSoonAuctions => endingSoonAuctions.isNotEmpty;
  bool get hasCategories => categories.isNotEmpty;
  bool get hasWatchlist => watchlist.isNotEmpty;
  bool get hasError => error != null;
  bool get hasFilters => currentFilters?.hasFilters ?? false;

  AuctionState copyWith({
    List<AuctionModel>? auctions,
    List<AuctionModel>? featuredAuctions,
    List<AuctionModel>? endingSoonAuctions,
    List<CategoryModel>? categories,
    List<AuctionModel>? watchlist,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    int? currentPage,
    String? currentSearch,
    AuctionSearchFilters? currentFilters,
  }) {
    return AuctionState(
      auctions: auctions ?? this.auctions,
      featuredAuctions: featuredAuctions ?? this.featuredAuctions,
      endingSoonAuctions: endingSoonAuctions ?? this.endingSoonAuctions,
      categories: categories ?? this.categories,
      watchlist: watchlist ?? this.watchlist,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      currentSearch: currentSearch ?? this.currentSearch,
      currentFilters: currentFilters ?? this.currentFilters,
    );
  }
}

// Auction provider
class AuctionNotifier extends StateNotifier<AuctionState> {
  final AuctionRepository _repository;

  AuctionNotifier(this._repository) : super(const AuctionState());

  // Load initial auctions
  Future<void> loadAuctions({
    String? search,
    AuctionSearchFilters? filters,
    bool refresh = false,
  }) async {
    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        currentPage: 1,
        currentSearch: search,
        currentFilters: filters,
      );
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final result = await _repository.getAuctions(
        page: 1,
        search: search,
        filters: filters,
      );

      result.when(
        success: (auctions) {
          state = state.copyWith(
            auctions: auctions,
            isLoading: false,
            hasMore: auctions.length >= 20,
            currentPage: 1,
            currentSearch: search,
            currentFilters: filters,
          );
        },
        error: (error) {
          state = state.copyWith(
            isLoading: false,
            error: error,
          );
        },
      );
    } catch (e) {
      AppLogger.error('Error loading auctions', error: e);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load auctions: ${e.toString()}',
      );
    }
  }

  // Load more auctions (pagination)
  Future<void> loadMoreAuctions() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final result = await _repository.getAuctions(
        page: nextPage,
        search: state.currentSearch,
        filters: state.currentFilters,
      );

      result.when(
        success: (newAuctions) {
          final allAuctions = [...state.auctions, ...newAuctions];
          state = state.copyWith(
            auctions: allAuctions,
            isLoadingMore: false,
            hasMore: newAuctions.length >= 20,
            currentPage: nextPage,
          );
        },
        error: (error) {
          state = state.copyWith(
            isLoadingMore: false,
            error: error,
          );
        },
      );
    } catch (e) {
      AppLogger.error('Error loading more auctions', error: e);
      state = state.copyWith(
        isLoadingMore: false,
        error: 'Failed to load more auctions: ${e.toString()}',
      );
    }
  }

  // Load featured auctions
  Future<void> loadFeaturedAuctions() async {
    try {
      final result = await _repository.getFeaturedAuctions();

      result.when(
        success: (auctions) {
          state = state.copyWith(featuredAuctions: auctions);
        },
        error: (error) {
          AppLogger.warning('Failed to load featured auctions: $error');
        },
      );
    } catch (e) {
      AppLogger.error('Error loading featured auctions', error: e);
    }
  }

  // Load ending soon auctions
  Future<void> loadEndingSoonAuctions() async {
    try {
      final result = await _repository.getEndingSoonAuctions();

      result.when(
        success: (auctions) {
          state = state.copyWith(endingSoonAuctions: auctions);
        },
        error: (error) {
          AppLogger.warning('Failed to load ending soon auctions: $error');
        },
      );
    } catch (e) {
      AppLogger.error('Error loading ending soon auctions', error: e);
    }
  }

  // Load categories
  Future<void> loadCategories() async {
    try {
      final result = await _repository.getCategories();

      result.when(
        success: (categories) {
          state = state.copyWith(categories: categories);
        },
        error: (error) {
          AppLogger.warning('Failed to load categories: $error');
        },
      );
    } catch (e) {
      AppLogger.error('Error loading categories', error: e);
    }
  }

  // Search auctions
  Future<void> searchAuctions(String query) async {
    await loadAuctions(search: query, refresh: true);
  }

  // Apply filters
  Future<void> applyFilters(AuctionSearchFilters filters) async {
    await loadAuctions(filters: filters, refresh: true);
  }

  // Clear filters
  Future<void> clearFilters() async {
    await loadAuctions(refresh: true);
  }

  // Refresh all data
  Future<void> refresh() async {
    await Future.wait([
      loadAuctions(
        search: state.currentSearch,
        filters: state.currentFilters,
        refresh: true,
      ),
      loadFeaturedAuctions(),
      loadEndingSoonAuctions(),
      loadCategories(),
    ]);
  }

  // Toggle watchlist
  Future<bool> toggleWatchlist(AuctionModel auction) async {
    try {
      final result = auction.isWatched
          ? await _repository.removeFromWatchlist(auction.id)
          : await _repository.addToWatchlist(auction.id);

      return result.when(
        success: (success) {
          if (success) {
            // Update auction in the list
            final updatedAuctions = state.auctions.map((a) {
              if (a.id == auction.id) {
                return a.copyWith(isWatched: !a.isWatched);
              }
              return a;
            }).toList();

            state = state.copyWith(auctions: updatedAuctions);
          }
          return success;
        },
        error: (error) {
          AppLogger.warning('Failed to toggle watchlist: $error');
          return false;
        },
      );
    } catch (e) {
      AppLogger.error('Error toggling watchlist', error: e);
      return false;
    }
  }

  // Load watchlist
  Future<void> loadWatchlist() async {
    try {
      final result = await _repository.getWatchlist();

      result.when(
        success: (auctions) {
          state = state.copyWith(watchlist: auctions);
        },
        error: (error) {
          AppLogger.warning('Failed to load watchlist: $error');
        },
      );
    } catch (e) {
      AppLogger.error('Error loading watchlist', error: e);
    }
  }
}

// Providers
final auctionProvider = StateNotifierProvider<AuctionNotifier, AuctionState>((ref) {
  final repository = ref.watch(auctionRepositoryProvider);
  return AuctionNotifier(repository);
});

// Individual auction provider
final auctionDetailProvider = FutureProvider.family<AuctionModel?, int>((ref, auctionId) async {
  final repository = ref.watch(auctionRepositoryProvider);
  final result = await repository.getAuctionById(auctionId);
  
  return result.when(
    success: (auction) => auction,
    error: (error) {
      AppLogger.warning('Failed to load auction details: $error');
      return null;
    },
  );
});

// Convenience providers
final auctionsProvider = Provider<List<AuctionModel>>((ref) {
  return ref.watch(auctionProvider).auctions;
});

final featuredAuctionsProvider = Provider<List<AuctionModel>>((ref) {
  return ref.watch(auctionProvider).featuredAuctions;
});

final endingSoonAuctionsProvider = Provider<List<AuctionModel>>((ref) {
  return ref.watch(auctionProvider).endingSoonAuctions;
});

final categoriesProvider = Provider<List<CategoryModel>>((ref) {
  return ref.watch(auctionProvider).categories;
});

final watchlistProvider = Provider<List<AuctionModel>>((ref) {
  return ref.watch(auctionProvider).watchlist;
});

final auctionErrorProvider = Provider<String?>((ref) {
  return ref.watch(auctionProvider).error;
});
