import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> checkAuth() async {
    _isLoading = true;
    // Use post frame callback to avoid notifyListeners during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      print('[AUTH] Checking authentication...');
      _user = await _apiService.getCurrentUser().timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          print('[AUTH] Auth check timed out - assuming no user');
          return null;
        },
      );
      if (_user != null) {
        print('[AUTH] User authenticated: ${_user!.username}');
      } else {
        print('[AUTH] No authenticated user');
      }
      _error = null;
    } catch (e) {
      print('[AUTH] Error checking auth: $e');
      _user = null;
      // Don't set error for auth check failures - just continue without user
      _error = null;
    } finally {
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _apiService.login(username, password);
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String idNumber,
    required String birthDate,
    required String phone,
    required String address,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _apiService.register(
        username: username,
        email: email,
        password: password,
        idNumber: idNumber,
        birthDate: birthDate,
        phone: phone,
        address: address,
      );
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

