import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auction.dart';
import '../models/bid.dart';
import '../models/user.dart';
import '../models/notification.dart';

class ApiService {
  static const String baseUrl = 'https://zubidauction.duckdns.org/api';
  
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  ApiService() : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final cookies = await _storage.read(key: 'cookies');
        if (cookies != null) {
          options.headers['Cookie'] = cookies;
        }
        return handler.next(options);
      },
      onResponse: (response, handler) async {
        final setCookie = response.headers['set-cookie'];
        if (setCookie != null && setCookie.isNotEmpty) {
          await _storage.write(key: 'cookies', value: setCookie.join('; '));
        }
        return handler.next(response);
      },
    ));
  }

  // Auth
  Future<User?> login(String username, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'username': username,
        'password': password,
      });
      if (response.statusCode == 200) {
        return User.fromJson(response.data['user']);
      }
    } catch (e) {
      rethrow;
    }
    return null;
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
      final params = <String, dynamic>{'page': page};
      if (categoryId != null) params['category_id'] = categoryId;
      if (search != null) params['search'] = search;
      
      final response = await _dio.get('/auctions', queryParameters: params);
      if (response.statusCode == 200) {
        final data = response.data;
        final auctions = data['auctions'] as List? ?? data as List;
        return auctions.map((json) => Auction.fromJson(json)).toList();
      }
    } catch (e) {
      rethrow;
    }
    return [];
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

  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('/categories');
      if (response.statusCode == 200) {
        final categories = response.data as List;
        return categories.map((json) => Category.fromJson(json)).toList();
      }
    } catch (e) {
      return [];
    }
    return [];
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

