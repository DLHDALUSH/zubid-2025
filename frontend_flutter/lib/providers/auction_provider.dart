import 'package:flutter/material.dart';
import '../models/auction.dart';
import '../models/bid.dart';
import '../services/api_service.dart';

class AuctionProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Auction> _auctions = [];
  List<Category> _categories = [];
  List<Auction> _wishlist = [];
  List<Bid> _myBids = [];
  List<Auction> _wonAuctions = [];
  
  bool _isLoading = false;
  String? _error;
  int? _selectedCategoryId;

  List<Auction> get auctions => _auctions;
  List<Category> get categories => _categories;
  List<Auction> get wishlist => _wishlist;
  List<Bid> get myBids => _myBids;
  List<Auction> get wonAuctions => _wonAuctions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get selectedCategoryId => _selectedCategoryId;

  Future<void> loadAuctions({String? search}) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('[PROVIDER] Loading auctions...');
      _auctions = await _apiService.getAuctions(
        categoryId: _selectedCategoryId,
        search: search,
      );
      print('[PROVIDER] Loaded ${_auctions.length} auctions');
      _error = null;
    } catch (e) {
      print('[PROVIDER] Error loading auctions: $e');
      _error = e.toString();
      _auctions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    try {
      print('[PROVIDER] Loading categories...');
      _categories = await _apiService.getCategories();
      print('[PROVIDER] Loaded ${_categories.length} categories');
      notifyListeners();
    } catch (e) {
      print('[PROVIDER] Error loading categories: $e');
      _categories = [];
      notifyListeners();
    }
  }

  void selectCategory(int? categoryId) {
    _selectedCategoryId = categoryId;
    loadAuctions();
  }

  Future<Auction?> getAuction(int id) async {
    try {
      return await _apiService.getAuction(id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> placeBid(int auctionId, double amount) async {
    try {
      final success = await _apiService.placeBid(auctionId, amount);
      if (success) {
        await loadAuctions();
        await loadMyBids();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> loadWishlist() async {
    try {
      _wishlist = await _apiService.getWishlist();
      notifyListeners();
    } catch (e) {
      // Ignore errors
    }
  }

  Future<bool> toggleWishlist(int auctionId) async {
    final isInWishlist = _wishlist.any((a) => a.id == auctionId);
    try {
      if (isInWishlist) {
        await _apiService.removeFromWishlist(auctionId);
        _wishlist.removeWhere((a) => a.id == auctionId);
      } else {
        await _apiService.addToWishlist(auctionId);
        await loadWishlist();
      }
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  bool isInWishlist(int auctionId) {
    return _wishlist.any((a) => a.id == auctionId);
  }

  Future<void> loadMyBids() async {
    try {
      _myBids = await _apiService.getMyBids();
      notifyListeners();
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> loadWonAuctions() async {
    try {
      _wonAuctions = await _apiService.getWonAuctions();
      notifyListeners();
    } catch (e) {
      // Ignore errors
    }
  }

  Future<List<Bid>> getAuctionBids(int auctionId) async {
    try {
      return await _apiService.getAuctionBids(auctionId);
    } catch (e) {
      return [];
    }
  }

  Future<bool> createAuction({
    required String itemName,
    required String description,
    required double startingBid,
    required DateTime endTime,
    int? categoryId,
    double? bidIncrement,
    double? marketPrice,
    double? realPrice,
    List<String>? images,
    String? itemCondition,
    String? videoUrl,
    String? featuredImageUrl,
    bool featured = false,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await _apiService.createAuction(
        itemName: itemName,
        description: description,
        startingBid: startingBid,
        endTime: endTime,
        categoryId: categoryId,
        bidIncrement: bidIncrement,
        marketPrice: marketPrice,
        realPrice: realPrice,
        images: images,
        itemCondition: itemCondition,
        videoUrl: videoUrl,
        featuredImageUrl: featuredImageUrl,
        featured: featured,
      );

      if (success) {
        _error = null;
        await loadAuctions(); // Refresh auctions list
      } else {
        _error = 'Failed to create auction';
      }

      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

