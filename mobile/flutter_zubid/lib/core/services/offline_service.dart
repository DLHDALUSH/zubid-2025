import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/logger.dart';
import '../../features/auctions/data/models/auction_model.dart';
import '../../features/auth/data/models/user_model.dart';

enum OfflineMode {
  online,
  offline,
  limited,
}

class OfflineService {
  static OfflineService? _instance;
  static OfflineService get instance => _instance ??= OfflineService._();

  OfflineService._();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Cache management
  static const String _cacheDirectory = 'offline_cache';
  static const Duration _cacheExpiry = Duration(hours: 24);
  static const int _maxCacheSize = 50 * 1024 * 1024; // 50MB

  // Offline state
  OfflineMode _currentMode = OfflineMode.online;
  final StreamController<OfflineMode> _modeController =
      StreamController<OfflineMode>.broadcast();

  // Sync queue
  final List<Map<String, dynamic>> _syncQueue = [];
  Timer? _syncTimer;

  // Public streams
  Stream<OfflineMode> get modeStream => _modeController.stream;
  OfflineMode get currentMode => _currentMode;
  bool get isOnline => _currentMode == OfflineMode.online;
  bool get isOffline => _currentMode == OfflineMode.offline;

  /// Initialize offline service
  Future<void> initialize() async {
    try {
      AppLogger.info('Initializing offline service...');

      // Check initial connectivity
      await _checkConnectivity();

      // Listen to connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _onConnectivityChanged,
        onError: (error) {
          AppLogger.error('Connectivity stream error', error: error);
        },
      );

      // Initialize cache directory
      await _initializeCacheDirectory();

      // Load sync queue from storage
      await _loadSyncQueue();

      // Start periodic sync
      _startPeriodicSync();

      AppLogger.info('Offline service initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize offline service', error: e);
    }
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
    _modeController.close();
  }

  /// Cache auction data for offline access
  Future<void> cacheAuctions(List<AuctionModel> auctions) async {
    try {
      final cacheData = {
        'auctions': auctions.map((auction) => auction.toJson()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.0',
      };

      await _writeCacheFile('auctions.json', cacheData);
      AppLogger.info('Cached ${auctions.length} auctions for offline access');
    } catch (e) {
      AppLogger.error('Failed to cache auctions', error: e);
    }
  }

  /// Get cached auctions
  Future<List<AuctionModel>> getCachedAuctions() async {
    try {
      final cacheData = await _readCacheFile('auctions.json');
      if (cacheData == null) return [];

      // Check cache expiry
      final timestamp = DateTime.parse(cacheData['timestamp']);
      if (DateTime.now().difference(timestamp) > _cacheExpiry) {
        AppLogger.info('Auction cache expired, returning empty list');
        return [];
      }

      final auctionsList = cacheData['auctions'] as List<dynamic>;
      final auctions =
          auctionsList.map((json) => AuctionModel.fromJson(json)).toList();

      AppLogger.info('Retrieved ${auctions.length} cached auctions');
      return auctions;
    } catch (e) {
      AppLogger.error('Failed to get cached auctions', error: e);
      return [];
    }
  }

  /// Cache user data
  Future<void> cacheUserData(UserModel user) async {
    try {
      final cacheData = {
        'user': user.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _writeCacheFile('user.json', cacheData);
      AppLogger.info('Cached user data for offline access');
    } catch (e) {
      AppLogger.error('Failed to cache user data', error: e);
    }
  }

  /// Get cached user data
  Future<UserModel?> getCachedUserData() async {
    try {
      final cacheData = await _readCacheFile('user.json');
      if (cacheData == null) return null;

      final user = UserModel.fromJson(cacheData['user']);
      AppLogger.info('Retrieved cached user data');
      return user;
    } catch (e) {
      AppLogger.error('Failed to get cached user data', error: e);
      return null;
    }
  }

  /// Add action to sync queue for when online
  Future<void> queueForSync(String action, Map<String, dynamic> data) async {
    try {
      final syncItem = {
        'action': action,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      _syncQueue.add(syncItem);
      await _saveSyncQueue();

      AppLogger.info('Action queued for sync: $action');

      // Try to sync immediately if online
      if (isOnline) {
        await _processSyncQueue();
      }
    } catch (e) {
      AppLogger.error('Failed to queue action for sync', error: e);
    }
  }

  /// Get sync queue status
  Map<String, dynamic> getSyncStatus() {
    return {
      'queueLength': _syncQueue.length,
      'isOnline': isOnline,
      'currentMode': _currentMode.toString(),
      'pendingActions': _syncQueue
          .map((item) => {
                'action': item['action'],
                'timestamp': item['timestamp'],
              })
          .toList(),
    };
  }

  /// Clear cache
  Future<void> clearCache() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        await _initializeCacheDirectory();
      }
      AppLogger.info('Cache cleared successfully');
    } catch (e) {
      AppLogger.error('Failed to clear cache', error: e);
    }
  }

  /// Get cache size
  Future<int> getCacheSize() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (!await cacheDir.exists()) return 0;

      int totalSize = 0;
      await for (final entity in cacheDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }

      return totalSize;
    } catch (e) {
      AppLogger.error('Failed to get cache size', error: e);
      return 0;
    }
  }

  // Private helper methods

  /// Check current connectivity status
  Future<void> _checkConnectivity() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      await _onConnectivityChanged(connectivityResults);
    } catch (e) {
      AppLogger.error('Failed to check connectivity', error: e);
      _updateMode(OfflineMode.offline);
    }
  }

  /// Handle connectivity changes
  Future<void> _onConnectivityChanged(List<ConnectivityResult> results) async {
    try {
      final hasConnection =
          results.any((result) => result != ConnectivityResult.none);

      if (hasConnection) {
        // Test actual internet connectivity
        final hasInternet = await _testInternetConnection();
        if (hasInternet) {
          _updateMode(OfflineMode.online);
          await _processSyncQueue();
        } else {
          _updateMode(OfflineMode.limited);
        }
      } else {
        _updateMode(OfflineMode.offline);
      }
    } catch (e) {
      AppLogger.error('Error handling connectivity change', error: e);
      _updateMode(OfflineMode.offline);
    }
  }

  /// Test actual internet connection
  Future<bool> _testInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Update offline mode
  void _updateMode(OfflineMode newMode) {
    if (_currentMode != newMode) {
      final oldMode = _currentMode;
      _currentMode = newMode;
      _modeController.add(newMode);

      AppLogger.userAction('Offline mode changed', parameters: {
        'from': oldMode.toString(),
        'to': newMode.toString(),
      });
    }
  }

  /// Initialize cache directory
  Future<void> _initializeCacheDirectory() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }
    } catch (e) {
      AppLogger.error('Failed to initialize cache directory', error: e);
    }
  }

  /// Get cache directory
  Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/$_cacheDirectory');
  }

  /// Write data to cache file
  Future<void> _writeCacheFile(
      String filename, Map<String, dynamic> data) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final file = File('${cacheDir.path}/$filename');

      final jsonString = json.encode(data);
      await file.writeAsString(jsonString);

      // Check cache size and cleanup if needed
      await _cleanupCacheIfNeeded();
    } catch (e) {
      AppLogger.error('Failed to write cache file: $filename', error: e);
    }
  }

  /// Read data from cache file
  Future<Map<String, dynamic>?> _readCacheFile(String filename) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final file = File('${cacheDir.path}/$filename');

      if (!await file.exists()) return null;

      final jsonString = await file.readAsString();
      return json.decode(jsonString);
    } catch (e) {
      AppLogger.error('Failed to read cache file: $filename', error: e);
      return null;
    }
  }

  /// Cleanup cache if it exceeds maximum size
  Future<void> _cleanupCacheIfNeeded() async {
    try {
      final cacheSize = await getCacheSize();
      if (cacheSize > _maxCacheSize) {
        AppLogger.info('Cache size exceeded limit, cleaning up...');

        final cacheDir = await _getCacheDirectory();
        final files = <FileSystemEntity>[];

        await for (final entity in cacheDir.list()) {
          if (entity is File) {
            files.add(entity);
          }
        }

        // Sort files by last modified date (oldest first)
        files.sort((a, b) {
          final aStat = a.statSync();
          final bStat = b.statSync();
          return aStat.modified.compareTo(bStat.modified);
        });

        // Delete oldest files until under limit
        int currentSize = cacheSize;
        for (final file in files) {
          if (currentSize <= _maxCacheSize * 0.8) break; // Keep 20% buffer

          final fileSize = await (file as File).length();
          await file.delete();
          currentSize -= fileSize;

          AppLogger.info('Deleted cache file: ${file.path}');
        }
      }
    } catch (e) {
      AppLogger.error('Failed to cleanup cache', error: e);
    }
  }

  /// Start periodic sync timer
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (isOnline && _syncQueue.isNotEmpty) {
        _processSyncQueue();
      }
    });
  }

  /// Process sync queue
  Future<void> _processSyncQueue() async {
    if (_syncQueue.isEmpty || !isOnline) return;

    try {
      AppLogger.info('Processing sync queue with ${_syncQueue.length} items');

      final itemsToProcess = List<Map<String, dynamic>>.from(_syncQueue);
      _syncQueue.clear();

      for (final item in itemsToProcess) {
        try {
          await _processSyncItem(item);
          AppLogger.info('Synced item: ${item['action']}');
        } catch (e) {
          AppLogger.error('Failed to sync item: ${item['action']}', error: e);
          // Re-queue failed items
          _syncQueue.add(item);
        }
      }

      await _saveSyncQueue();
    } catch (e) {
      AppLogger.error('Failed to process sync queue', error: e);
    }
  }

  /// Process individual sync item
  Future<void> _processSyncItem(Map<String, dynamic> item) async {
    final action = item['action'] as String;
    // final data = item['data'] as Map<String, dynamic>; // Will be used when implementing specific sync actions

    switch (action) {
      case 'place_bid':
        // Placeholder for bid sync implementation
        AppLogger.info('Syncing bid action');
        break;
      case 'add_to_watchlist':
        // Placeholder for watchlist sync implementation
        AppLogger.info('Syncing watchlist action');
        break;
      case 'update_profile':
        // Placeholder for profile sync implementation
        AppLogger.info('Syncing profile action');
        break;
      case 'create_auction':
        // Placeholder for auction creation sync implementation
        AppLogger.info('Syncing auction creation action');
        break;
      default:
        AppLogger.warning('Unknown sync action: $action');
    }
  }

  /// Save sync queue to persistent storage
  Future<void> _saveSyncQueue() async {
    try {
      final queueData = {
        'queue': _syncQueue,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _writeCacheFile('sync_queue.json', queueData);
    } catch (e) {
      AppLogger.error('Failed to save sync queue', error: e);
    }
  }

  /// Load sync queue from persistent storage
  Future<void> _loadSyncQueue() async {
    try {
      final queueData = await _readCacheFile('sync_queue.json');
      if (queueData != null) {
        final queue = queueData['queue'] as List<dynamic>;
        _syncQueue.clear();
        _syncQueue.addAll(queue.cast<Map<String, dynamic>>());

        AppLogger.info('Loaded ${_syncQueue.length} items from sync queue');
      }
    } catch (e) {
      AppLogger.error('Failed to load sync queue', error: e);
    }
  }
}
