import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auction.dart';
import '../models/bid.dart';
import '../models/user.dart';
import '../models/notification.dart';

class ApiService {
  // Use localhost for development, external URL for production
  // For Android emulator: 10.0.2.2 is the host machine
  // For physical device: use the actual machine IP or domain
  static const String baseUrl = 'http://10.0.2.2:5000/api';
  // Fallback to external server if local is not available
  static const String fallbackUrl = 'https://zubidauction.duckdns.org/api';

  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String _currentBaseUrl = baseUrl;

  ApiService() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: _currentBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
      validateStatus: (status) => status != null && status < 500,
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        print('[API] ${options.method} ${options.path}');
        final cookies = await _storage.read(key: 'cookies');
        if (cookies != null) {
          options.headers['Cookie'] = cookies;
        }
        return handler.next(options);
      },
      onResponse: (response, handler) async {
        print('[API] Response: ${response.statusCode} ${response.requestOptions.path}');
        final setCookie = response.headers['set-cookie'];
        if (setCookie != null && setCookie.isNotEmpty) {
          await _storage.write(key: 'cookies', value: setCookie.join('; '));
        }
        return handler.next(response);
      },
      onError: (error, handler) async {
        print('[API ERROR] ${error.message}');
        print('[API ERROR] Type: ${error.type}');
        print('[API ERROR] Status: ${error.response?.statusCode}');

        // Try fallback URL if local server is not available
        if (_currentBaseUrl == baseUrl && error.type == DioExceptionType.connectionTimeout) {
          print('[API] Switching to fallback URL: $fallbackUrl');
          _currentBaseUrl = fallbackUrl;
          _initializeDio();
        }

        return handler.next(error);
      },
    ));
  }

  // Auth
  Future<User?> login(String username, String password) async {
    try {
      print('[LOGIN] Attempting login for user: $username');
      final response = await _dio.post('/login', data: {
        'username': username,
        'password': password,
      });
      print('[LOGIN] Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('[LOGIN] Login successful');
        return User.fromJson(response.data['user']);
      } else {
        print('[LOGIN] Login failed: ${response.data}');
        throw Exception(response.data['error'] ?? 'Login failed');
      }
    } catch (e) {
      print('[LOGIN] Error: $e');
      rethrow;
    }
  }

  Future<User?> register({
    required String username,
    required String email,
    required String password,
    required String idNumber,
    required String birthDate,
    required String phone,
    required String address,
  }) async {
    try {
      final response = await _dio.post('/register', data: {
        'username': username,
        'email': email,
        'password': password,
        'id_number': idNumber,
        'birth_date': birthDate,
        'phone': phone,
        'address': address,
      });
      if (response.statusCode == 201) {
        return User.fromJson(response.data['user']);
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<void> logout() async {
    try {
      await _dio.post('/logout');
      await _storage.delete(key: 'cookies');
    } catch (e) {
      await _storage.delete(key: 'cookies');
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final response = await _dio.get('/me');
      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  // Auctions
  Future<List<Auction>> getAuctions({int page = 1, int? categoryId, String? search}) async {
    try {
      print('[AUCTIONS] Loading auctions - page: $page, category: $categoryId, search: $search');
      final params = <String, dynamic>{'page': page};
      if (categoryId != null) params['category_id'] = categoryId;
      if (search != null) params['search'] = search;

      final response = await _dio.get('/auctions', queryParameters: params);
      print('[AUCTIONS] Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = response.data;
        final auctions = data['auctions'] as List? ?? data as List;
        print('[AUCTIONS] Loaded ${auctions.length} auctions');
        return auctions.map((json) => Auction.fromJson(json)).toList();
      } else {
        print('[AUCTIONS] Failed to load auctions: ${response.data}');
        return [];
      }
    } catch (e) {
      print('[AUCTIONS] Error: $e');
      rethrow;
    }
  }

  Future<Auction?> getAuction(int id) async {
    try {
      final response = await _dio.get('/auctions/$id');
      if (response.statusCode == 200) {
        return Auction.fromJson(response.data);
      }
    } catch (e) {
      rethrow;
    }
    return null;
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
      final data = {
        'item_name': itemName,
        'description': description,
        'starting_bid': startingBid,
        'end_time': endTime.toIso8601String(),
        'bid_increment': bidIncrement ?? 1.0,
        'featured': featured,
      };

      if (categoryId != null) data['category_id'] = categoryId;
      if (marketPrice != null) data['market_price'] = marketPrice;
      if (realPrice != null) data['real_price'] = realPrice;
      if (itemCondition != null) data['item_condition'] = itemCondition;
      if (videoUrl != null) data['video_url'] = videoUrl;
      if (featuredImageUrl != null) data['featured_image_url'] = featuredImageUrl;
      if (images != null && images.isNotEmpty) data['images'] = images;

      final response = await _dio.post('/auctions', data: data);
      return response.statusCode == 201;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      print('[CATEGORIES] Loading categories');
      final response = await _dio.get('/categories');
      print('[CATEGORIES] Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final categories = response.data as List;
        print('[CATEGORIES] Loaded ${categories.length} categories');
        return categories.map((json) => Category.fromJson(json)).toList();
      } else {
        print('[CATEGORIES] Failed to load categories: ${response.data}');
        return [];
      }
    } catch (e) {
      print('[CATEGORIES] Error: $e');
      return [];
    }
  }

  // Bids
  Future<bool> placeBid(int auctionId, double amount) async {
    try {
      final response = await _dio.post('/auctions/$auctionId/bids', 
        data: {'amount': amount});
      return response.statusCode == 201;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Bid>> getMyBids() async {
    try {
      final response = await _dio.get('/my-bids');
      if (response.statusCode == 200) {
        final bids = response.data as List;
        return bids.map((json) => Bid.fromJson(json)).toList();
      }
    } catch (e) {
      return [];
    }
    return [];
  }

  Future<List<Bid>> getAuctionBids(int auctionId) async {
    try {
      final response = await _dio.get('/auctions/$auctionId/bids');
      if (response.statusCode == 200) {
        final bids = response.data as List;
        return bids.map((json) => Bid.fromJson(json)).toList();
      }
    } catch (e) {
      return [];
    }
    return [];
  }

  // Wishlist
  Future<List<Auction>> getWishlist() async {
    try {
      final response = await _dio.get('/wishlist');
      if (response.statusCode == 200) {
        final auctions = response.data as List;
        return auctions.map((json) => Auction.fromJson(json)).toList();
      }
    } catch (e) {
      return [];
    }
    return [];
  }

  Future<bool> addToWishlist(int auctionId) async {
    try {
      final response = await _dio.post('/wishlist', data: {'auction_id': auctionId});
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFromWishlist(int auctionId) async {
    try {
      final response = await _dio.delete('/wishlist/$auctionId');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Notifications
  Future<List<AppNotification>> getNotifications() async {
    try {
      final response = await _dio.get('/notifications');
      if (response.statusCode == 200) {
        final notifications = response.data as List;
        return notifications.map((json) => AppNotification.fromJson(json)).toList();
      }
    } catch (e) {
      return [];
    }
    return [];
  }

  Future<bool> markNotificationRead(int id) async {
    try {
      final response = await _dio.put('/notifications/$id/read');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Won Auctions
  Future<List<Auction>> getWonAuctions() async {
    try {
      final response = await _dio.get('/my-auctions/won');
      if (response.statusCode == 200) {
        final auctions = response.data as List;
        return auctions.map((json) => Auction.fromJson(json)).toList();
      }
    } catch (e) {
      return [];
    }
    return [];
  }
}

