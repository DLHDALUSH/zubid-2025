import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class AppLogger {
  static const String _tag = 'ZUBID';

  // Log levels
  static const int _debugLevel = 0;
  static const int _infoLevel = 1;
  static const int _warningLevel = 2;
  static const int _errorLevel = 3;

  static int _currentLogLevel = kDebugMode ? _debugLevel : _infoLevel;

  // ANSI color codes for console output
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _magenta = '\x1B[35m';
  static const String _cyan = '\x1B[36m';
  static const String _white = '\x1B[37m';

  /// Set the minimum log level
  static void setLogLevel(int level) {
    _currentLogLevel = level;
  }

  /// Debug level logging - only shown in debug mode
  static void debug(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    if (_currentLogLevel <= _debugLevel) {
      _log(_debugLevel, message,
          tag: tag, error: error, stackTrace: stackTrace);
    }
  }

  /// Info level logging
  static void info(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    if (_currentLogLevel <= _infoLevel) {
      _log(_infoLevel, message, tag: tag, error: error, stackTrace: stackTrace);
    }
  }

  /// Warning level logging
  static void warning(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    if (_currentLogLevel <= _warningLevel) {
      _log(_warningLevel, message,
          tag: tag, error: error, stackTrace: stackTrace);
    }
  }

  /// Error level logging
  static void error(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    if (_currentLogLevel <= _errorLevel) {
      _log(_errorLevel, message,
          tag: tag, error: error, stackTrace: stackTrace);
    }
  }

  /// Network request logging
  static void network(String method, String url,
      {int? statusCode, String? response, String? tag}) {
    if (_currentLogLevel <= _debugLevel) {
      final color = _getStatusCodeColor(statusCode);
      final message =
          '$color🌐 $method $url${statusCode != null ? ' [$statusCode]' : ''}$_reset';
      developer.log(message, name: '${tag ?? _tag}_NETWORK');

      if (response != null && response.isNotEmpty) {
        developer.log('📄 Response: $response', name: '${tag ?? _tag}_NETWORK');
      }
    }
  }

  /// API error logging
  static void apiError(String endpoint, int statusCode, String error,
      {StackTrace? stackTrace}) {
    final message = '🚨 API Error: $endpoint [$statusCode] - $error';
    _log(_errorLevel, message, tag: 'API', stackTrace: stackTrace);
  }

  /// User action logging
  static void userAction(String action, {Map<String, dynamic>? parameters}) {
    if (_currentLogLevel <= _infoLevel) {
      String message = '👤 User Action: $action';
      if (parameters != null && parameters.isNotEmpty) {
        message += ' - ${parameters.toString()}';
      }
      developer.log('$_cyan$message$_reset', name: '${_tag}_USER');
    }
  }

  /// Performance logging
  static void performance(String operation, Duration duration,
      {String? details}) {
    if (_currentLogLevel <= _debugLevel) {
      String message =
          '⚡ Performance: $operation took ${duration.inMilliseconds}ms';
      if (details != null) {
        message += ' - $details';
      }
      developer.log('$_magenta$message$_reset', name: '${_tag}_PERF');
    }
  }

  /// Database operation logging
  static void database(String operation, {String? table, String? details}) {
    if (_currentLogLevel <= _debugLevel) {
      String message = '🗄️ DB: $operation';
      if (table != null) {
        message += ' on $table';
      }
      if (details != null) {
        message += ' - $details';
      }
      developer.log('$_blue$message$_reset', name: '${_tag}_DB');
    }
  }

  /// Authentication logging
  static void auth(String action, {String? userId, bool success = true}) {
    final icon = success ? '🔐' : '🚫';
    String message = '$icon Auth: $action';
    if (userId != null) {
      message += ' for user $userId';
    }
    message += success ? ' - Success' : ' - Failed';

    final level = success ? _infoLevel : _warningLevel;
    _log(level, message, tag: 'AUTH');
  }

  /// Payment logging
  static void payment(String action,
      {String? amount, String? method, bool success = true}) {
    final icon = success ? '💳' : '❌';
    String message = '$icon Payment: $action';
    if (amount != null) {
      message += ' amount: $amount';
    }
    if (method != null) {
      message += ' via $method';
    }
    message += success ? ' - Success' : ' - Failed';

    final level = success ? _infoLevel : _errorLevel;
    _log(level, message, tag: 'PAYMENT');
  }

  /// Auction logging
  static void auction(String action, {String? auctionId, String? details}) {
    String message = '🔨 Auction: $action';
    if (auctionId != null) {
      message += ' (ID: $auctionId)';
    }
    if (details != null) {
      message += ' - $details';
    }
    _log(_infoLevel, message, tag: 'AUCTION');
  }

  /// Bid logging
  static void bid(String action,
      {String? auctionId, String? amount, String? userId}) {
    String message = '💰 Bid: $action';
    if (auctionId != null) {
      message += ' on auction $auctionId';
    }
    if (amount != null) {
      message += ' amount: $amount';
    }
    if (userId != null) {
      message += ' by user $userId';
    }
    _log(_infoLevel, message, tag: 'BID');
  }

  /// Private method to handle actual logging
  static void _log(int level, String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    final logTag = tag ?? _tag;
    final levelName = _getLevelName(level);
    final color = _getLevelColor(level);
    final timestamp = DateTime.now().toIso8601String();

    final formattedMessage = '$color[$levelName] $message$_reset';

    developer.log(
      formattedMessage,
      name: logTag,
      time: DateTime.now(),
      level: level,
      error: error,
      stackTrace: stackTrace,
    );

    // In debug mode, also print to console for better visibility
    if (kDebugMode) {
      print('[$timestamp] [$logTag] $formattedMessage');
      if (error != null) {
        print('Error: $error');
      }
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
    }
  }

  /// Get level name string
  static String _getLevelName(int level) {
    switch (level) {
      case _debugLevel:
        return 'DEBUG';
      case _infoLevel:
        return 'INFO';
      case _warningLevel:
        return 'WARN';
      case _errorLevel:
        return 'ERROR';
      default:
        return 'UNKNOWN';
    }
  }

  /// Get color for log level
  static String _getLevelColor(int level) {
    switch (level) {
      case _debugLevel:
        return _white;
      case _infoLevel:
        return _green;
      case _warningLevel:
        return _yellow;
      case _errorLevel:
        return _red;
      default:
        return _reset;
    }
  }

  /// Get color for HTTP status code
  static String _getStatusCodeColor(int? statusCode) {
    if (statusCode == null) return _white;

    if (statusCode >= 200 && statusCode < 300) {
      return _green;
    } else if (statusCode >= 300 && statusCode < 400) {
      return _yellow;
    } else if (statusCode >= 400 && statusCode < 500) {
      return _red;
    } else if (statusCode >= 500) {
      return _magenta;
    } else {
      return _white;
    }
  }
}
