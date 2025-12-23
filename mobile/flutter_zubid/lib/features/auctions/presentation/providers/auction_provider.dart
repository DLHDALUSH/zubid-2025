import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/auction_model.dart';
import '../../data/models/auction_search_filters.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/auction_repository.dart';
import '../../data/providers/auction_providers.dart';
import '../../../../core/utils/logger.dart';

// Auction State
class AuctionState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<AuctionModel> auctions;
  final List<CategoryModel> categories;
  final AuctionSearchFilters? currentFilters;
  final String? error;
  final bool hasMore;
  final int currentPage;

  const AuctionState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.auctions = const [],
    this.categories = const [],
    this.currentFilters,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
  });

  // Computed properties
  bool get hasAuctions => auctions.isNotEmpty;
  bool get hasError => error != null;

  AuctionState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<AuctionModel>? auctions,
    List<CategoryModel>? categories,
    AuctionSearchFilters? currentFilters,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return AuctionState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      auctions: auctions ?? this.auctions,
      categories: categories ?? this.categories,
      currentFilters: currentFilters ?? this.currentFilters,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  bool get hasCategories => categories.isNotEmpty;
  bool get hasFilters => currentFilters != null && !currentFilters!.isEmpty;
}

// Auction Provider
class AuctionNotifier extends StateNotifier<AuctionState> {
  final AuctionRepository _auctionRepository;

  AuctionNotifier(this._auctionRepository) : super(const AuctionState());

  Future<void> loadAuctions({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        currentPage: 1,
        hasMore: true,
      );
    } else if (state.isLoading || state.isLoadingMore) {
      return;
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final result = await _auctionRepository.getAuctions(
        page: refresh ? 1 : state.currentPage,
        filters: state.currentFilters,
      );

      result.when(
        success: (auctions) {
          if (refresh) {
            state = state.copyWith(
              isLoading: false,
              auctions: auctions,
              currentPage: 2,
              hasMore: auctions.length >= 20, // Assuming 20 items per page
            );
          } else {
            state = state.copyWith(
              isLoading: false,
              auctions: [...state.auctions, ...auctions],
              currentPage: state.currentPage + 1,
              hasMore: auctions.length >= 20,
            );
          }
          AppLogger.info('Loaded ${auctions.length} auctions');
        },
        error: (error) {
          state = state.copyWith(
            isLoading: false,
            error: error,
          );
          AppLogger.error('Failed to load auctions', error: error);
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

  Future<void> loadMoreAuctions() async {
    if (!state.hasMore || state.isLoadingMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final result = await _auctionRepository.getAuctions(
        page: state.currentPage,
        filters: state.currentFilters,
      );

      result.when(
        success: (auctions) {
          state = state.copyWith(
            isLoadingMore: false,
            auctions: [...state.auctions, ...auctions],
            currentPage: state.currentPage + 1,
            hasMore: auctions.length >= 20,
          );
          AppLogger.info('Loaded ${auctions.length} more auctions');
        },
        error: (error) {
          state = state.copyWith(
            isLoadingMore: false,
            error: error,
          );
          AppLogger.error('Failed to load more auctions', error: error);
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: 'An unexpected error occurred',
      );
      AppLogger.error('Load more auctions exception', error: e);
    }
  }

  Future<void> searchAuctions(String query) async {
    final filters = state.currentFilters?.copyWith(searchQuery: query) ??
        AuctionSearchFilters(searchQuery: query);
    
    state = state.copyWith(currentFilters: filters);
    await loadAuctions(refresh: true);
  }

  Future<void> applyFilters(AuctionSearchFilters filters) async {
    state = state.copyWith(currentFilters: filters);
    await loadAuctions(refresh: true);
  }

  Future<void> clearFilters() async {
    state = state.copyWith(currentFilters: null);
    await loadAuctions(refresh: true);
  }

  Future<void> refresh() async {
    await loadAuctions(refresh: true);
  }

  Future<bool> toggleWatchlist(AuctionModel auction) async {
    // Implementation for watchlist toggle
    AppLogger.info('Toggle watchlist for auction: ${auction.id}');
    return true;
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> loadCategories() async {
    try {
      state = state.copyWith(isLoading: true);
      final result = await _auctionRepository.getCategories();
      result.when(
        success: (categories) {
          state = state.copyWith(
            isLoading: false,
            categories: categories,
          );
          AppLogger.info('Categories loaded successfully: ${categories.length}');
        },
        error: (error) {
          state = state.copyWith(
            isLoading: false,
            error: error,
          );
          AppLogger.error('Failed to load categories: $error');
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load categories: $e',
      );
      AppLogger.error('Exception loading categories: $e');
    }
  }
}

// Provider instances
final auctionProvider = StateNotifierProvider<AuctionNotifier, AuctionState>((ref) {
  final auctionRepository = ref.read(auctionRepositoryProvider);
  return AuctionNotifier(auctionRepository);
});

final auctionsProvider = Provider<List<AuctionModel>>((ref) {
  return ref.watch(auctionProvider).auctions;
});

final categoriesProvider = Provider<List<CategoryModel>>((ref) {
  return ref.watch(auctionProvider).categories;
});

final auctionErrorProvider = Provider<String?>((ref) {
  return ref.watch(auctionProvider).error;
});
