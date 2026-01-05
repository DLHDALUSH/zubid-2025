import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../utils/logger.dart';
import 'storage_service.dart';

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

  // Public streams
  Stream<PerformanceMetrics> get metricsStream => _metricsController.stream;

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
    _metricsController.close();
    _activeTimers.clear();
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
      'deviceInfo': _deviceInfo,
      'exportTimestamp': DateTime.now().toIso8601String(),
    };

    return json.encode(data);
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
