import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

import '../config/environment.dart';
import '../utils/logger.dart';
import 'storage_service.dart';

enum WebSocketConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

class WebSocketService {
  static WebSocketService? _instance;
  static WebSocketService get instance => _instance ??= WebSocketService._();

  WebSocketService._();

  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _heartbeatInterval = Duration(seconds: 30);
  static const Duration _reconnectDelay = Duration(seconds: 5);

  // Stream controllers for different event types
  final StreamController<Map<String, dynamic>> _auctionUpdatesController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _bidUpdatesController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<WebSocketConnectionState> _connectionStateController =
      StreamController<WebSocketConnectionState>.broadcast();

  // Public streams
  Stream<Map<String, dynamic>> get auctionUpdates =>
      _auctionUpdatesController.stream;
  Stream<Map<String, dynamic>> get bidUpdates => _bidUpdatesController.stream;
  Stream<Map<String, dynamic>> get notifications =>
      _notificationController.stream;
  Stream<WebSocketConnectionState> get connectionState =>
      _connectionStateController.stream;

  WebSocketConnectionState _currentState =
      WebSocketConnectionState.disconnected;
  WebSocketConnectionState get currentState => _currentState;

  /// Initialize WebSocket connection
  Future<void> connect() async {
    if (_currentState == WebSocketConnectionState.connected ||
        _currentState == WebSocketConnectionState.connecting) {
      return;
    }

    try {
      _updateConnectionState(WebSocketConnectionState.connecting);
      AppLogger.info(
          'Connecting to WebSocket: ${EnvironmentConfig.websocketUrl}');

      // Get auth token for authenticated connection
      final authToken = await StorageService.getAuthToken();
      final uri = Uri.parse('${EnvironmentConfig.websocketUrl}/ws');

      // Add auth token to headers if available
      final headers = <String, String>{};
      if (authToken != null) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      _channel = WebSocketChannel.connect(uri, protocols: ['echo-protocol']);

      // Listen to the WebSocket stream
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
      );

      _updateConnectionState(WebSocketConnectionState.connected);
      _startHeartbeat();
      _reconnectAttempts = 0;

      AppLogger.info('WebSocket connected successfully');

      // Send authentication message if token is available
      if (authToken != null) {
        _sendMessage({
          'type': 'auth',
          'token': authToken,
        });
      }
    } catch (e) {
      AppLogger.error('Failed to connect to WebSocket', error: e);
      _updateConnectionState(WebSocketConnectionState.error);
      _scheduleReconnect();
    }
  }

  /// Disconnect from WebSocket
  Future<void> disconnect() async {
    AppLogger.info('Disconnecting from WebSocket');

    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();

    if (_channel != null) {
      await _channel!.sink.close(status.goingAway);
      _channel = null;
    }

    _updateConnectionState(WebSocketConnectionState.disconnected);
  }

  /// Send message through WebSocket
  void _sendMessage(Map<String, dynamic> message) {
    if (_channel != null &&
        _currentState == WebSocketConnectionState.connected) {
      try {
        final jsonMessage = json.encode(message);
        _channel!.sink.add(jsonMessage);
        AppLogger.debug('WebSocket message sent: ${message['type']}');
      } catch (e) {
        AppLogger.error('Failed to send WebSocket message', error: e);
      }
    } else {
      AppLogger.warning('Cannot send message: WebSocket not connected');
    }
  }

  /// Subscribe to auction updates
  void subscribeToAuction(String auctionId) {
    _sendMessage({
      'type': 'subscribe_auction',
      'auction_id': auctionId,
    });
  }

  /// Unsubscribe from auction updates
  void unsubscribeFromAuction(String auctionId) {
    _sendMessage({
      'type': 'unsubscribe_auction',
      'auction_id': auctionId,
    });
  }

  /// Subscribe to user notifications
  void subscribeToNotifications() {
    _sendMessage({
      'type': 'subscribe_notifications',
    });
  }

  /// Place a bid through WebSocket
  void placeBid({
    required String auctionId,
    required double amount,
  }) {
    _sendMessage({
      'type': 'place_bid',
      'auction_id': auctionId,
      'amount': amount,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Handle incoming WebSocket messages
  void _handleMessage(dynamic message) {
    try {
      final Map<String, dynamic> data = json.decode(message);
      final messageType = data['type'] as String?;

      AppLogger.debug('WebSocket message received: $messageType');

      switch (messageType) {
        case 'auction_update':
          _auctionUpdatesController.add(data);
          break;
        case 'bid_update':
          _bidUpdatesController.add(data);
          break;
        case 'notification':
          _notificationController.add(data);
          break;
        case 'heartbeat':
          _handleHeartbeat(data);
          break;
        case 'error':
          _handleServerError(data);
          break;
        case 'auth_success':
          AppLogger.info('WebSocket authentication successful');
          break;
        case 'auth_failed':
          AppLogger.warning('WebSocket authentication failed');
          break;
        default:
          AppLogger.warning('Unknown WebSocket message type: $messageType');
      }
    } catch (e) {
      AppLogger.error('Failed to parse WebSocket message', error: e);
    }
  }

  /// Handle WebSocket errors
  void _handleError(dynamic error) {
    AppLogger.error('WebSocket error occurred', error: error);
    _updateConnectionState(WebSocketConnectionState.error);
    _scheduleReconnect();
  }

  /// Handle WebSocket disconnection
  void _handleDisconnection() {
    AppLogger.info('WebSocket disconnected');
    _heartbeatTimer?.cancel();

    if (_currentState != WebSocketConnectionState.disconnected) {
      _updateConnectionState(WebSocketConnectionState.disconnected);
      _scheduleReconnect();
    }
  }

  /// Handle heartbeat messages
  void _handleHeartbeat(Map<String, dynamic> data) {
    // Respond to server heartbeat
    _sendMessage({'type': 'heartbeat_response'});
  }

  /// Handle server errors
  void _handleServerError(Map<String, dynamic> data) {
    final errorMessage = data['message'] as String? ?? 'Unknown server error';
    AppLogger.error('WebSocket server error: $errorMessage');
  }

  /// Start heartbeat timer
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      if (_currentState == WebSocketConnectionState.connected) {
        _sendMessage({'type': 'ping'});
      }
    });
  }

  /// Schedule reconnection attempt
  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      AppLogger.warning('Max reconnection attempts reached');
      _updateConnectionState(WebSocketConnectionState.error);
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () {
      _reconnectAttempts++;
      AppLogger.info(
          'Attempting to reconnect ($_reconnectAttempts/$_maxReconnectAttempts)');
      _updateConnectionState(WebSocketConnectionState.reconnecting);
      connect();
    });
  }

  /// Update connection state and notify listeners
  void _updateConnectionState(WebSocketConnectionState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      _connectionStateController.add(newState);
      AppLogger.info('WebSocket state changed to: ${newState.name}');
    }
  }

  /// Dispose resources
  void dispose() {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();

    _auctionUpdatesController.close();
    _bidUpdatesController.close();
    _notificationController.close();
    _connectionStateController.close();
  }
}
