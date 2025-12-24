import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../utils/logger.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final connectivityStatusProvider = StreamProvider<ConnectivityStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectivityStream;
});

enum ConnectivityStatus {
  connected,
  disconnected,
  checking,
}

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _internetChecker = InternetConnectionChecker();
  
  late final StreamController<ConnectivityStatus> _statusController;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _checkTimer;

  ConnectivityService() {
    _statusController = StreamController<ConnectivityStatus>.broadcast();
    _initializeConnectivity();
  }

  Stream<ConnectivityStatus> get connectivityStream => _statusController.stream;

  void _initializeConnectivity() {
    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
      onError: (error) {
        AppLogger.error('Connectivity subscription error', error: error);
        _statusController.add(ConnectivityStatus.disconnected);
      },
    );

    // Check initial connectivity
    _checkConnectivity();
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    AppLogger.info('Connectivity changed: $results');
    
    // Cancel any existing timer
    _checkTimer?.cancel();
    
    // If no connectivity, immediately report disconnected
    if (results.contains(ConnectivityResult.none)) {
      _statusController.add(ConnectivityStatus.disconnected);
      return;
    }
    
    // If we have some form of connectivity, check internet access
    _statusController.add(ConnectivityStatus.checking);
    _checkTimer = Timer(const Duration(seconds: 1), _checkInternetAccess);
  }

  Future<void> _checkConnectivity() async {
    try {
      _statusController.add(ConnectivityStatus.checking);
      final results = await _connectivity.checkConnectivity();
      _onConnectivityChanged(results);
    } catch (e) {
      AppLogger.error('Failed to check connectivity', error: e);
      _statusController.add(ConnectivityStatus.disconnected);
    }
  }

  Future<void> _checkInternetAccess() async {
    try {
      final hasInternet = await _internetChecker.hasConnection;
      _statusController.add(
        hasInternet ? ConnectivityStatus.connected : ConnectivityStatus.disconnected,
      );
      AppLogger.info('Internet access: $hasInternet');
    } catch (e) {
      AppLogger.error('Failed to check internet access', error: e);
      // Fallback: try a simple ping
      _fallbackConnectivityCheck();
    }
  }

  Future<void> _fallbackConnectivityCheck() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      final isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      _statusController.add(
        isConnected ? ConnectivityStatus.connected : ConnectivityStatus.disconnected,
      );
      AppLogger.info('Fallback connectivity check: $isConnected');
    } catch (e) {
      AppLogger.warning('Fallback connectivity check failed', error: e);
      _statusController.add(ConnectivityStatus.disconnected);
    }
  }

  Future<bool> isConnected() async {
    try {
      final results = await _connectivity.checkConnectivity();
      if (results.contains(ConnectivityResult.none)) {
        return false;
      }
      
      return await _internetChecker.hasConnection;
    } catch (e) {
      AppLogger.error('Error checking connection status', error: e);
      return false;
    }
  }

  Future<bool> canReachServer(String host) async {
    try {
      final result = await InternetAddress.lookup(host);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      AppLogger.warning('Cannot reach server $host', error: e);
      return false;
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _checkTimer?.cancel();
    _statusController.close();
  }
}
