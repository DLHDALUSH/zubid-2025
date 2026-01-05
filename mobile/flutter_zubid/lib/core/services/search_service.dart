import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../utils/logger.dart';
import 'storage_service.dart';
import '../../features/auctions/data/models/auction_model.dart';
import '../../features/auctions/data/models/auction_search_filters.dart';

class SearchService {
  static SearchService? _instance;
  static SearchService get instance => _instance ??= SearchService._();

  SearchService._();

  static const String _searchHistoryKey = 'advanced_search_history';
  static const String _searchPreferencesKey = 'search_preferences';
  static const String _popularSearchesKey = 'popular_searches';
  static const int _maxHistoryItems = 50;
  static const int _maxSuggestions = 10;

  // Search analytics
  final Map<String, int> _searchFrequency = {};
  final Map<String, DateTime> _lastSearchTime = {};

  // AI-powered search weights
  final Map<String, double> _fieldWeights = {
    'title': 1.0,
    'description': 0.7,
    'category': 0.8,
    'seller': 0.6,
    'location': 0.5,
    'tags': 0.9,
  };

  /// Perform advanced search with AI-powered ranking
  Future<List<AuctionModel>> performAdvancedSearch({
    required String query,
    required List<AuctionModel> auctions,
    AuctionSearchFilters? filters,
    String sortBy = 'relevance',
    bool ascending = false,
  }) async {
    try {
      AppLogger.userAction('Advanced search performed', parameters: {
        'query': query,
        'sortBy': sortBy,
        'filtersApplied': filters != null,
      });

      // Save search to history
      await _saveSearchToHistory(query);

      // Apply text search with AI ranking
      List<AuctionModel> results = _performTextSearch(query, auctions);

      // Apply filters
      if (filters != null) {
        results = _applyFilters(results, filters);
      }

      // Sort results
      results = _sortResults(results, sortBy, ascending, query);

      // Update search analytics
      _updateSearchAnalytics(query, results.length);

      return results;
    } catch (e) {
      AppLogger.error('Advanced search failed', error: e);
      return [];
    }
  }

  /// Get search suggestions based on history and popular searches
  Future<List<String>> getSearchSuggestions(String query) async {
    try {
      final suggestions = <String>[];

      // Get from search history
      final history = await getSearchHistory();
      final historySuggestions = history
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .take(5)
          .toList();
      suggestions.addAll(historySuggestions);

      // Get popular searches
      final popularSearches = await _getPopularSearches();
      final popularSuggestions = popularSearches
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .where((item) => !suggestions.contains(item))
          .take(5)
          .toList();
      suggestions.addAll(popularSuggestions);

      // Generate smart suggestions based on query patterns
      final smartSuggestions = _generateSmartSuggestions(query);
      suggestions.addAll(smartSuggestions
          .where((item) => !suggestions.contains(item))
          .take(3));

      return suggestions.take(_maxSuggestions).toList();
    } catch (e) {
      AppLogger.error('Failed to get search suggestions', error: e);
      return [];
    }
  }

  /// Get search history
  Future<List<String>> getSearchHistory() async {
    try {
      final historyJson = StorageService.getString(_searchHistoryKey);
      if (historyJson != null) {
        final List<dynamic> historyList = json.decode(historyJson);
        return historyList.cast<String>();
      }
      return [];
    } catch (e) {
      AppLogger.error('Failed to get search history', error: e);
      return [];
    }
  }

  /// Clear search history
  Future<void> clearSearchHistory() async {
    try {
      await StorageService.setString(_searchHistoryKey, json.encode([]));
      _searchFrequency.clear();
      _lastSearchTime.clear();
      AppLogger.userAction('Search history cleared');
    } catch (e) {
      AppLogger.error('Failed to clear search history', error: e);
    }
  }

  /// Get trending searches
  Future<List<String>> getTrendingSearches() async {
    try {
      // Sort searches by frequency and recency
      final trending = _searchFrequency.entries
          .where((entry) => _lastSearchTime[entry.key] != null)
          .map((entry) {
        final recencyScore =
            _calculateRecencyScore(_lastSearchTime[entry.key]!);
        final totalScore = entry.value * recencyScore;
        return MapEntry(entry.key, totalScore);
      }).toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return trending.take(10).map((e) => e.key).toList();
    } catch (e) {
      AppLogger.error('Failed to get trending searches', error: e);
      return [];
    }
  }

  /// Get search analytics
  Map<String, dynamic> getSearchAnalytics() {
    return {
      'totalSearches': _searchFrequency.values.fold(0, (a, b) => a + b),
      'uniqueQueries': _searchFrequency.length,
      'topQueries': _searchFrequency.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value))
        ..take(5)
        ..map((e) => {'query': e.key, 'count': e.value}).toList(),
      'lastSearchTime': _lastSearchTime.values.isNotEmpty
          ? _lastSearchTime.values.reduce((a, b) => a.isAfter(b) ? a : b)
          : null,
    };
  }

  // Private helper methods

  /// Perform text search with AI-powered ranking
  List<AuctionModel> _performTextSearch(
      String query, List<AuctionModel> auctions) {
    if (query.isEmpty) return auctions;

    final queryTerms = query
        .toLowerCase()
        .split(' ')
        .where((term) => term.isNotEmpty)
        .toList();
    final scoredResults = <MapEntry<AuctionModel, double>>[];

    for (final auction in auctions) {
      double score = 0.0;

      // Calculate relevance score for each field
      score += _calculateFieldScore(auction.title, queryTerms) *
          _fieldWeights['title']!;
      score += _calculateFieldScore(auction.description, queryTerms) *
          _fieldWeights['description']!;
      score += _calculateFieldScore(auction.categoryName, queryTerms) *
          _fieldWeights['category']!;
      score += _calculateFieldScore(auction.sellerUsername, queryTerms) *
          _fieldWeights['seller']!;

      if (auction.location != null) {
        score += _calculateFieldScore(auction.location!, queryTerms) *
            _fieldWeights['location']!;
      }

      // Boost score for exact matches
      if (auction.title.toLowerCase().contains(query.toLowerCase())) {
        score *= 1.5;
      }

      // Boost score for featured auctions
      if (auction.isFeatured) {
        score *= 1.2;
      }

      // Boost score for active auctions
      if (auction.status == 'active') {
        score *= 1.1;
      }

      if (score > 0) {
        scoredResults.add(MapEntry(auction, score));
      }
    }

    // Sort by relevance score
    scoredResults.sort((a, b) => b.value.compareTo(a.value));
    return scoredResults.map((entry) => entry.key).toList();
  }

  /// Calculate field score for search terms
  double _calculateFieldScore(String field, List<String> queryTerms) {
    if (field.isEmpty) return 0.0;

    final fieldLower = field.toLowerCase();
    double score = 0.0;

    for (final term in queryTerms) {
      if (fieldLower.contains(term)) {
        // Exact word match gets higher score
        if (fieldLower.split(' ').contains(term)) {
          score += 2.0;
        } else {
          score += 1.0;
        }

        // Boost score if term appears at the beginning
        if (fieldLower.startsWith(term)) {
          score += 0.5;
        }
      }
    }

    return score;
  }

  /// Apply filters to search results
  List<AuctionModel> _applyFilters(
      List<AuctionModel> auctions, AuctionSearchFilters filters) {
    return auctions.where((auction) {
      // Price range filter
      if (filters.minPrice != null &&
          auction.currentPrice < filters.minPrice!) {
        return false;
      }
      if (filters.maxPrice != null &&
          auction.currentPrice > filters.maxPrice!) {
        return false;
      }

      // Category filter
      if (filters.categoryId != null &&
          auction.categoryId != filters.categoryId) {
        return false;
      }

      // Location filter
      if (filters.location != null &&
          (auction.location == null ||
              !auction.location!
                  .toLowerCase()
                  .contains(filters.location!.toLowerCase()))) {
        return false;
      }

      // Condition filter
      if (filters.condition != null && auction.condition != filters.condition) {
        return false;
      }

      // Featured only filter
      if (filters.featuredOnly == true && !auction.isFeatured) {
        return false;
      }

      // Has buy now filter
      if (filters.hasBuyNow == true && auction.buyNowPrice == null) {
        return false;
      }

      // Ending soon filter (within 24 hours)
      if (filters.endingSoon == true) {
        final timeRemaining = auction.endTime.difference(DateTime.now());
        if (timeRemaining.inHours > 24) {
          return false;
        }
      }

      // Newly listed filter (within 7 days)
      if (filters.newlyListed == true) {
        final daysSinceCreated =
            DateTime.now().difference(auction.createdAt).inDays;
        if (daysSinceCreated > 7) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Sort search results
  List<AuctionModel> _sortResults(List<AuctionModel> auctions, String sortBy,
      bool ascending, String query) {
    auctions.sort((a, b) {
      int comparison = 0;

      switch (sortBy) {
        case 'relevance':
          // Already sorted by relevance in text search
          return 0;
        case 'price':
          comparison = a.currentPrice.compareTo(b.currentPrice);
          break;
        case 'time_remaining':
          comparison = a.endTime.compareTo(b.endTime);
          break;
        case 'bid_count':
          comparison = a.bidCount.compareTo(b.bidCount);
          break;
        case 'created_date':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case 'popularity':
          comparison = a.viewCount.compareTo(b.viewCount);
          break;
        default:
          comparison = a.title.compareTo(b.title);
      }

      return ascending ? comparison : -comparison;
    });

    return auctions;
  }

  /// Save search query to history
  Future<void> _saveSearchToHistory(String query) async {
    try {
      if (query.trim().isEmpty) return;

      final history = await getSearchHistory();

      // Remove if already exists to avoid duplicates
      history.remove(query);

      // Add to beginning
      history.insert(0, query);

      // Keep only max items
      if (history.length > _maxHistoryItems) {
        history.removeRange(_maxHistoryItems, history.length);
      }

      await StorageService.setString(_searchHistoryKey, json.encode(history));
    } catch (e) {
      AppLogger.error('Failed to save search to history', error: e);
    }
  }

  /// Get popular searches
  Future<List<String>> _getPopularSearches() async {
    try {
      final popularJson = StorageService.getString(_popularSearchesKey);
      if (popularJson != null) {
        final List<dynamic> popularList = json.decode(popularJson);
        return popularList.cast<String>();
      }
      return [];
    } catch (e) {
      AppLogger.error('Failed to get popular searches', error: e);
      return [];
    }
  }

  /// Generate smart suggestions based on query patterns
  List<String> _generateSmartSuggestions(String query) {
    final suggestions = <String>[];

    // Add category-based suggestions
    final categoryKeywords = [
      'electronics',
      'clothing',
      'books',
      'art',
      'jewelry',
      'cars',
      'furniture'
    ];
    for (final keyword in categoryKeywords) {
      if (keyword.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(keyword);
      }
    }

    // Add price-based suggestions
    if (query.toLowerCase().contains('cheap') ||
        query.toLowerCase().contains('budget')) {
      suggestions.add('under \$50');
      suggestions.add('under \$100');
    }

    if (query.toLowerCase().contains('expensive') ||
        query.toLowerCase().contains('luxury')) {
      suggestions.add('over \$500');
      suggestions.add('over \$1000');
    }

    return suggestions;
  }

  /// Update search analytics
  void _updateSearchAnalytics(String query, int resultCount) {
    _searchFrequency[query] = (_searchFrequency[query] ?? 0) + 1;
    _lastSearchTime[query] = DateTime.now();

    AppLogger.userAction('Search analytics updated', parameters: {
      'query': query,
      'resultCount': resultCount,
      'frequency': _searchFrequency[query],
    });
  }

  /// Calculate recency score for trending searches
  double _calculateRecencyScore(DateTime searchTime) {
    final now = DateTime.now();
    final hoursSinceSearch = now.difference(searchTime).inHours;

    // Score decreases exponentially with time
    return exp(-hoursSinceSearch / 24.0); // Half-life of 24 hours
  }
}
