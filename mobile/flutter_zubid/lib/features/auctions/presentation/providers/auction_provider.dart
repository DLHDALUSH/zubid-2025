import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:convert';

import '../../data/models/auction_model.dart';
import '../../data/models/auction_search_filters.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/auction_repository.dart';
import '../../data/providers/auction_providers.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/services/storage_service.dart';

// Enhanced Auction State with caching and performance optimizations
class AuctionState {
  final bool isLoading;
  final bool isLoadingMore;
  final bool isRefreshing;
  final List<AuctionModel> auctions;
  final List<CategoryModel> categories;
  final AuctionSearchFilters? currentFilters;
  final String? error;
  final bool hasMore;
  final int currentPage;
  final DateTime? lastUpdated;
  final Map<String, List<AuctionModel>> cachedResults;
  final Set<int> watchlistedAuctions;
  final Map<int, int> auctionViewCounts;
  final bool isOfflineMode;

  const AuctionState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.auctions = const [],
    this.categories = const [],
    this.currentFilters,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
    this.lastUpdated,
    this.cachedResults = const {},
    this.watchlistedAuctions = const {},
    this.auctionViewCounts = const {},
    this.isOfflineMode = false,
  });

  // Enhanced computed properties
  bool get hasAuctions => auctions.isNotEmpty;
  bool get hasError => error != null;
  bool get hasCategories => categories.isNotEmpty;
  bool get hasFilters => currentFilters != null && !currentFilters!.isEmpty;
  bool get isCacheValid =>
      lastUpdated != null &&
      DateTime.now().difference(lastUpdated!).inMinutes < 5;
  bool get hasWatchlistedAuctions => watchlistedAuctions.isNotEmpty;

  // Get cached results for a specific query
  List<AuctionModel> getCachedResults(String cacheKey) {
    return cachedResults[cacheKey] ?? [];
  }

  // Check if auction is watchlisted
  bool isAuctionWatchlisted(int auctionId) {
    return watchlistedAuctions.contains(auctionId);
  }

  AuctionState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? isRefreshing,
    List<AuctionModel>? auctions,
    List<CategoryModel>? categories,
    AuctionSearchFilters? currentFilters,
    String? error,
    bool? hasMore,
    int? currentPage,
    DateTime? lastUpdated,
    Map<String, List<AuctionModel>>? cachedResults,
    Set<int>? watchlistedAuctions,
    Map<int, int>? auctionViewCounts,
    bool? isOfflineMode,
  }) {
    return AuctionState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      auctions: auctions ?? this.auctions,
      categories: categories ?? this.categories,
      currentFilters: currentFilters ?? this.currentFilters,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      cachedResults: cachedResults ?? this.cachedResults,
      watchlistedAuctions: watchlistedAuctions ?? this.watchlistedAuctions,
      auctionViewCounts: auctionViewCounts ?? this.auctionViewCounts,
      isOfflineMode: isOfflineMode ?? this.isOfflineMode,
    );
  }
}

// Enhanced Auction Provider (Riverpod 3.x) with caching and performance optimizations
class AuctionNotifier extends Notifier<AuctionState> {
  late final AuctionRepository _auctionRepository;
  Timer? _refreshTimer;
  static const Duration _autoRefreshInterval = Duration(minutes: 10);

  @override
  AuctionState build() {
    _auctionRepository = ref.read(auctionRepositoryProvider);
    _startAutoRefresh();
    return const AuctionState();
  }

  // Start automatic refresh timer
  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_autoRefreshInterval, (_) {
      if (!state.isLoading && !state.isLoadingMore) {
        _refreshAuctionsInBackground();
      }
    });
  }

  // Cache results for better performance
  void _cacheResults(String cacheKey, List<AuctionModel> auctions) {
    final updatedCache =
        Map<String, List<AuctionModel>>.from(state.cachedResults);
    updatedCache[cacheKey] = auctions;
    state = state.copyWith(cachedResults: updatedCache);

    // Persist to local storage for offline access
    _persistCacheToStorage(cacheKey, auctions);
  }

  // Persist cache to local storage
  Future<void> _persistCacheToStorage(
      String cacheKey, List<AuctionModel> auctions) async {
    try {
      final jsonData = auctions.map((auction) => auction.toJson()).toList();
      await StorageService.setString(
          'auction_cache_$cacheKey', json.encode(jsonData));
    } catch (e) {
      AppLogger.warning('Failed to persist cache: $e');
    }
  }

  // Background refresh without showing loading state
  Future<void> _refreshAuctionsInBackground() async {
    try {
      final result = await _auctionRepository.getAuctions(
        page: 1,
        filters: state.currentFilters,
      );

      result.when(
        success: (auctions) {
          state = state.copyWith(
            auctions: auctions,
            lastUpdated: DateTime.now(),
            error: null,
          );
          _cacheResults('latest', auctions);
        },
        error: (error) {
          AppLogger.warning('Background refresh failed: $error');
        },
      );
    } catch (e) {
      AppLogger.warning('Background refresh exception: $e');
    }
  }

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

  Future<bool> toggleWatchList(AuctionModel auction) async {
    // Implementation for Watch List toggle
    AppLogger.info('Toggle Watch List for auction: ${auction.id}');
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
          AppLogger.info(
              'Categories loaded successfully: ${categories.length}');
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
final auctionProvider = NotifierProvider<AuctionNotifier, AuctionState>(
  AuctionNotifier.new,
);

final auctionsProvider = Provider<List<AuctionModel>>((ref) {
  return ref.watch(auctionProvider).auctions;
});

final categoriesProvider = Provider<List<CategoryModel>>((ref) {
  return ref.watch(auctionProvider).categories;
});

final auctionErrorProvider = Provider<String?>((ref) {
  return ref.watch(auctionProvider).error;
});
