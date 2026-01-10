import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../utils/logger.dart';
import 'storage_service.dart';

class NetworkRequestMetrics {
  final String url;
  final String method;
  final int? statusCode;
  final Duration duration;
  final DateTime timestamp;
  final int bytesSent;
  final int bytesReceived;
  final String? error;

  const NetworkRequestMetrics({
    required this.url,
    required this.method,
    this.statusCode,
    required this.duration,
    required this.timestamp,
    this.bytesSent = 0,
    this.bytesReceived = 0,
    this.error,
  });

  Map<String, dynamic> toJson() => {
        'url': url,
        'method': method,
        'statusCode': statusCode,
        'duration_ms': duration.inMilliseconds,
        'timestamp': timestamp.toIso8601String(),
        'bytesSent': bytesSent,
        'bytesReceived': bytesReceived,
        'error': error,
      };

  factory NetworkRequestMetrics.fromJson(Map<String, dynamic> json) =>
      NetworkRequestMetrics(
        url: json['url'],
        method: json['method'],
        statusCode: json['statusCode'],
        duration: Duration(milliseconds: json['duration_ms']),
        timestamp: DateTime.parse(json['timestamp']),
        bytesSent: json['bytesSent'] ?? 0,
        bytesReceived: json['bytesReceived'] ?? 0,
        error: json['error'],
      );
}

class PerformanceAlert {
  final String type;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  const PerformanceAlert({
    required this.type,
    required this.message,
    required this.timestamp,
    this.data = const {},
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
        'data': data,
      };
}

class PerformanceMetrics {
  final String operation;
  final Duration duration;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  final String? error;

  const PerformanceMetrics({
    required this.operation,
    required this.duration,
    required this.timestamp,
    this.metadata = const {},
    this.error,
  });

  Map<String, dynamic> toJson() => {
        'operation': operation,
        'duration_ms': duration.inMilliseconds,
        'timestamp': timestamp.toIso8601String(),
        'metadata': metadata,
        'error': error,
      };

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) =>
      PerformanceMetrics(
        operation: json['operation'],
        duration: Duration(milliseconds: json['duration_ms']),
        timestamp: DateTime.parse(json['timestamp']),
        metadata: json['metadata'] ?? {},
        error: json['error'],
      );
}

class PerformanceService {
  static PerformanceService? _instance;
  static PerformanceService get instance =>
      _instance ??= PerformanceService._();

  PerformanceService._();

  static const String _metricsKey = 'performance_metrics';
  static const int _maxMetricsCount = 1000;
  static const Duration _metricsRetention = Duration(days: 7);

  final Map<String, Stopwatch> _activeTimers = {};
  final List<PerformanceMetrics> _metrics = [];
  final StreamController<PerformanceMetrics> _metricsController =
      StreamController<PerformanceMetrics>.broadcast();

  // Device info
  Map<String, dynamic>? _deviceInfo;

  // Memory tracking
  Timer? _memoryTimer;
  final List<int> _memoryUsage = [];

  // Network request tracking
  final List<NetworkRequestMetrics> _networkMetrics = [];
  final Map<String, Stopwatch> _activeNetworkRequests = {};

  // UI rendering tracking
  final List<PerformanceMetrics> _uiRenderMetrics = [];
  Timer? _uiRenderTimer;

  // Battery monitoring (simplified - would use battery_plus if available)
  Timer? _batteryTimer;
  final List<int> _batteryLevels = [];

  // Performance alerts
  final StreamController<PerformanceAlert> _alertsController =
      StreamController<PerformanceAlert>.broadcast();

  // Analytics integration
  final Map<String, dynamic> _analyticsData = {};

  // Public streams
  Stream<PerformanceMetrics> get metricsStream => _metricsController.stream;
  Stream<NetworkRequestMetrics> get networkMetricsStream =>
      Stream.fromIterable(_networkMetrics);
  Stream<PerformanceAlert> get alertsStream => _alertsController.stream;

  /// Initialize performance monitoring
  Future<void> initialize() async {
    try {
      AppLogger.info('Initializing performance service...');

      // Get device information
      await _getDeviceInfo();

      // Load existing metrics
      await _loadMetrics();

      // Start memory monitoring
      _startMemoryMonitoring();

      AppLogger.info('Performance service initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize performance service', error: e);
    }
  }

  /// Dispose resources
  void dispose() {
    _memoryTimer?.cancel();
    _uiRenderTimer?.cancel();
    _batteryTimer?.cancel();
    _metricsController.close();
    _alertsController.close();
    _activeTimers.clear();
    _activeNetworkRequests.clear();
  }

  /// Start timing an operation
  void startTimer(String operation) {
    _activeTimers[operation] = Stopwatch()..start();
  }

  /// Stop timing an operation and record metrics
  void stopTimer(String operation,
      {Map<String, dynamic>? metadata, String? error}) {
    final stopwatch = _activeTimers.remove(operation);
    if (stopwatch == null) {
      AppLogger.warning('No active timer found for operation: $operation');
      return;
    }

    stopwatch.stop();
    final metrics = PerformanceMetrics(
      operation: operation,
      duration: stopwatch.elapsed,
      timestamp: DateTime.now(),
      metadata: metadata ?? {},
      error: error,
    );

    _recordMetrics(metrics);
  }

  /// Time a function execution
  Future<T> timeFunction<T>(
    String operation,
    Future<T> Function() function, {
    Map<String, dynamic>? metadata,
  }) async {
    final stopwatch = Stopwatch()..start();
    String? error;

    try {
      final result = await function();
      return result;
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      stopwatch.stop();
      final metrics = PerformanceMetrics(
        operation: operation,
        duration: stopwatch.elapsed,
        timestamp: DateTime.now(),
        metadata: metadata ?? {},
        error: error,
      );

      _recordMetrics(metrics);
    }
  }

  /// Get performance statistics
  Map<String, dynamic> getPerformanceStats() {
    if (_metrics.isEmpty) {
      return {
        'totalOperations': 0,
        'averageResponseTime': 0,
        'errorRate': 0,
        'slowestOperations': [],
        'mostFrequentOperations': [],
      };
    }

    final operationCounts = <String, int>{};
    final operationTimes = <String, List<int>>{};
    int errorCount = 0;

    for (final metric in _metrics) {
      operationCounts[metric.operation] =
          (operationCounts[metric.operation] ?? 0) + 1;

      if (!operationTimes.containsKey(metric.operation)) {
        operationTimes[metric.operation] = [];
      }
      operationTimes[metric.operation]!.add(metric.duration.inMilliseconds);

      if (metric.error != null) {
        errorCount++;
      }
    }

    // Calculate averages
    final operationAverages = <String, double>{};
    for (final entry in operationTimes.entries) {
      final times = entry.value;
      operationAverages[entry.key] =
          times.reduce((a, b) => a + b) / times.length;
    }

    // Sort by average time (slowest first)
    final slowestOperations = operationAverages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Sort by frequency (most frequent first)
    final mostFrequentOperations = operationCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'totalOperations': _metrics.length,
      'averageResponseTime': _calculateOverallAverage(),
      'errorRate': errorCount / _metrics.length,
      'slowestOperations': slowestOperations
          .take(10)
          .map((e) => {
                'operation': e.key,
                'averageTime': e.value,
              })
          .toList(),
      'mostFrequentOperations': mostFrequentOperations
          .take(10)
          .map((e) => {
                'operation': e.key,
                'count': e.value,
              })
          .toList(),
      'deviceInfo': _deviceInfo,
      'memoryUsage': _getMemoryStats(),
    };
  }

  /// Get metrics for a specific operation
  List<PerformanceMetrics> getOperationMetrics(String operation) {
    return _metrics.where((metric) => metric.operation == operation).toList();
  }

  /// Clear all metrics
  Future<void> clearMetrics() async {
    try {
      _metrics.clear();
      await _saveMetrics();
      AppLogger.info('Performance metrics cleared');
    } catch (e) {
      AppLogger.error('Failed to clear metrics', error: e);
    }
  }

  /// Export metrics as JSON
  String exportMetrics() {
    final data = {
      'metrics': _metrics.map((m) => m.toJson()).toList(),
      'networkMetrics': _networkMetrics.map((m) => m.toJson()).toList(),
      'uiRenderMetrics': _uiRenderMetrics.map((m) => m.toJson()).toList(),
      'batteryLevels': _batteryLevels,
      'analyticsData': _analyticsData,
      'deviceInfo': _deviceInfo,
      'exportTimestamp': DateTime.now().toIso8601String(),
    };

    return json.encode(data);
  }

  /// Network request performance tracking
  void startNetworkRequest(String url, String method) {
    final requestId = '$method:$url:${DateTime.now().millisecondsSinceEpoch}';
    _activeNetworkRequests[requestId] = Stopwatch()..start();
  }

  void endNetworkRequest(String url, String method,
      {int? statusCode,
      int bytesSent = 0,
      int bytesReceived = 0,
      String? error}) {
    final requestId = '$method:$url:${DateTime.now().millisecondsSinceEpoch}';
    final stopwatch = _activeNetworkRequests.remove(requestId);
    if (stopwatch == null) return;

    stopwatch.stop();
    final metrics = NetworkRequestMetrics(
      url: url,
      method: method,
      statusCode: statusCode,
      duration: stopwatch.elapsed,
      timestamp: DateTime.now(),
      bytesSent: bytesSent,
      bytesReceived: bytesReceived,
      error: error,
    );

    _networkMetrics.add(metrics);

    // Check for slow network requests
    if (metrics.duration.inMilliseconds > 5000) {
      _triggerAlert('slow_network', 'Slow network request detected',
          {'url': url, 'duration': metrics.duration.inMilliseconds});
    }

    // Clean up old network metrics
    if (_networkMetrics.length > 1000) {
      _networkMetrics.removeRange(0, _networkMetrics.length - 1000);
    }
  }

  /// UI rendering performance tracking
  void startUIRenderTracking() {
    _uiRenderTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      // This is a simplified UI render tracking
      // In a real implementation, you might use FrameTiming from dart:ui
      final renderTime = DateTime.now().millisecondsSinceEpoch;
      final metrics = PerformanceMetrics(
        operation: 'ui_render',
        duration: const Duration(milliseconds: 16), // Approximate frame time
        timestamp: DateTime.now(),
        metadata: {'frameTime': renderTime},
      );

      _uiRenderMetrics.add(metrics);

      // Check for dropped frames (simplified)
      if (_uiRenderMetrics.length > 60) {
        // Check last second
        final recentRenders =
            _uiRenderMetrics.sublist(_uiRenderMetrics.length - 60);
        final avgRenderTime = recentRenders
                .map((m) => m.duration.inMilliseconds)
                .reduce((a, b) => a + b) /
            recentRenders.length;

        if (avgRenderTime > 16) {
          // More than 60fps
          _triggerAlert('ui_performance', 'UI rendering performance degraded',
              {'avgRenderTime': avgRenderTime});
        }

        // Keep only recent metrics
        if (_uiRenderMetrics.length > 3600) {
          // Keep last minute
          _uiRenderMetrics.removeRange(0, _uiRenderMetrics.length - 3600);
        }
      }
    });
  }

  void stopUIRenderTracking() {
    _uiRenderTimer?.cancel();
    _uiRenderTimer = null;
  }

  /// Battery usage monitoring
  Future<void> startBatteryMonitoring() async {
    try {
      _batteryTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
        // TODO: Implement battery monitoring with battery_plus package
        final level = 100; // Mock battery level for now
        _batteryLevels.add(level);

        // Keep only last 24 readings (2 hours)
        if (_batteryLevels.length > 24) {
          _batteryLevels.removeAt(0);
        }

        // Check for rapid battery drain
        if (_batteryLevels.length >= 2) {
          final current = _batteryLevels.last;
          final previous = _batteryLevels[_batteryLevels.length - 2];
          final drainRate = previous - current;

          if (drainRate > 10) {
            // More than 10% drain in 5 minutes
            _triggerAlert('battery_drain', 'Rapid battery drain detected',
                {'drainRate': drainRate, 'currentLevel': current});
          }
        }
      });
    } catch (e) {
      AppLogger.error('Failed to start battery monitoring', error: e);
    }
  }

  void stopBatteryMonitoring() {
    _batteryTimer?.cancel();
    _batteryTimer = null;
  }

  /// Analytics integration
  void trackAnalyticsEvent(String event, Map<String, dynamic> data) {
    _analyticsData[event] = {
      'count': (_analyticsData[event]?['count'] ?? 0) + 1,
      'lastOccurrence': DateTime.now().toIso8601String(),
      'data': data,
    };
  }

  /// Real-time performance alerts
  void _triggerAlert(String type, String message, Map<String, dynamic> data) {
    final alert = PerformanceAlert(
      type: type,
      message: message,
      timestamp: DateTime.now(),
      data: data,
    );

    _alertsController.add(alert);
    AppLogger.warning('Performance Alert: $message', tag: 'PERFORMANCE');
  }

  /// Get network performance statistics
  Map<String, dynamic> getNetworkStats() {
    if (_networkMetrics.isEmpty) {
      return {'totalRequests': 0, 'avgResponseTime': 0, 'errorRate': 0};
    }

    final totalRequests = _networkMetrics.length;
    final totalTime = _networkMetrics
        .map((m) => m.duration.inMilliseconds)
        .reduce((a, b) => a + b);
    final avgResponseTime = totalTime / totalRequests;
    final errorCount = _networkMetrics.where((m) => m.error != null).length;
    final errorRate = errorCount / totalRequests;

    return {
      'totalRequests': totalRequests,
      'avgResponseTime': avgResponseTime,
      'errorRate': errorRate,
      'slowRequests':
          _networkMetrics.where((m) => m.duration.inMilliseconds > 3000).length,
    };
  }

  /// Get UI performance statistics
  Map<String, dynamic> getUIPerformanceStats() {
    if (_uiRenderMetrics.isEmpty) {
      return {'avgRenderTime': 0, 'droppedFrames': 0};
    }

    final avgRenderTime = _uiRenderMetrics
            .map((m) => m.duration.inMilliseconds)
            .reduce((a, b) => a + b) /
        _uiRenderMetrics.length;

    final droppedFrames =
        _uiRenderMetrics.where((m) => m.duration.inMilliseconds > 16).length;

    return {
      'avgRenderTime': avgRenderTime,
      'droppedFrames': droppedFrames,
      'totalFrames': _uiRenderMetrics.length,
    };
  }

  // Private helper methods

  /// Record performance metrics
  void _recordMetrics(PerformanceMetrics metrics) {
    _metrics.add(metrics);
    _metricsController.add(metrics);

    // Clean up old metrics
    _cleanupOldMetrics();

    // Save to storage
    _saveMetrics();

    // Log slow operations
    if (metrics.duration.inMilliseconds > 1000) {
      AppLogger.warning(
          'Slow operation detected: ${metrics.operation} took ${metrics.duration.inMilliseconds}ms');
    }

    // Log errors
    if (metrics.error != null) {
      AppLogger.error('Operation failed: ${metrics.operation}',
          error: metrics.error);
    }
  }

  /// Get device information
  Future<void> _getDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _deviceInfo = {
          'platform': 'Android',
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'version': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
          'brand': androidInfo.brand,
          'device': androidInfo.device,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _deviceInfo = {
          'platform': 'iOS',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'systemVersion': iosInfo.systemVersion,
          'identifierForVendor': iosInfo.identifierForVendor,
        };
      }
    } catch (e) {
      AppLogger.error('Failed to get device info', error: e);
      _deviceInfo = {'platform': 'Unknown', 'error': e.toString()};
    }
  }

  /// Start memory monitoring
  void _startMemoryMonitoring() {
    _memoryTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _recordMemoryUsage();
    });
  }

  /// Record current memory usage
  void _recordMemoryUsage() {
    try {
      // This is a simplified memory tracking
      // In a real implementation, you might use platform-specific methods
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _memoryUsage.add(timestamp);

      // Keep only last 100 readings
      if (_memoryUsage.length > 100) {
        _memoryUsage.removeAt(0);
      }
    } catch (e) {
      AppLogger.error('Failed to record memory usage', error: e);
    }
  }

  /// Get memory statistics
  Map<String, dynamic> _getMemoryStats() {
    if (_memoryUsage.isEmpty) {
      return {'samples': 0, 'trend': 'unknown'};
    }

    return {
      'samples': _memoryUsage.length,
      'trend': _memoryUsage.length > 1
          ? (_memoryUsage.last > _memoryUsage.first
              ? 'increasing'
              : 'decreasing')
          : 'stable',
    };
  }

  /// Calculate overall average response time
  double _calculateOverallAverage() {
    if (_metrics.isEmpty) return 0.0;

    final totalMs =
        _metrics.map((m) => m.duration.inMilliseconds).reduce((a, b) => a + b);

    return totalMs / _metrics.length;
  }

  /// Clean up old metrics
  void _cleanupOldMetrics() {
    final cutoffTime = DateTime.now().subtract(_metricsRetention);
    _metrics.removeWhere((metric) => metric.timestamp.isBefore(cutoffTime));

    // Also limit by count
    if (_metrics.length > _maxMetricsCount) {
      _metrics.removeRange(0, _metrics.length - _maxMetricsCount);
    }
  }

  /// Save metrics to storage
  Future<void> _saveMetrics() async {
    try {
      final metricsData = {
        'metrics': _metrics.map((m) => m.toJson()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      await StorageService.setString(_metricsKey, json.encode(metricsData));
    } catch (e) {
      AppLogger.error('Failed to save metrics', error: e);
    }
  }

  /// Load metrics from storage
  Future<void> _loadMetrics() async {
    try {
      final metricsJson = StorageService.getString(_metricsKey);
      if (metricsJson != null) {
        final metricsData = json.decode(metricsJson);
        final metricsList = metricsData['metrics'] as List<dynamic>;

        _metrics.clear();
        _metrics.addAll(
            metricsList.map((json) => PerformanceMetrics.fromJson(json)));

        // Clean up old metrics after loading
        _cleanupOldMetrics();

        AppLogger.info('Loaded ${_metrics.length} performance metrics');
      }
    } catch (e) {
      AppLogger.error('Failed to load metrics', error: e);
    }
  }
}
