import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:vesteraalen_timelapse/core/config/env_config.dart';

/// Event data from a camera image update.
class CameraImageUpdateEvent {
  final String cameraId;
  final String cameraName;
  final String imageUrl;
  final String updatedAt;

  CameraImageUpdateEvent({
    required this.cameraId,
    required this.cameraName,
    required this.imageUrl,
    required this.updatedAt,
  });

  factory CameraImageUpdateEvent.fromJson(Map<String, dynamic> json) {
    return CameraImageUpdateEvent(
      cameraId: json['camera_id'] as String,
      cameraName: json['camera_name'] as String,
      imageUrl: json['image_url'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }
}

/// Service for connecting to Laravel Reverb WebSocket server.
/// Uses the Pusher protocol for channel subscriptions.
class WebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  bool _isConnected = false;
  bool _shouldReconnect = true;
  int _reconnectAttempts = 0;
  static const _maxReconnectAttempts = 5;
  static const _reconnectDelay = Duration(seconds: 5);
  static const _pingInterval = Duration(seconds: 30);

  final _cameraImageUpdates =
      StreamController<CameraImageUpdateEvent>.broadcast();
  final _connectionState = StreamController<bool>.broadcast();

  /// Stream of camera image update events.
  Stream<CameraImageUpdateEvent> get cameraImageUpdates =>
      _cameraImageUpdates.stream;

  /// Stream of connection state changes.
  Stream<bool> get connectionState => _connectionState.stream;

  /// Whether WebSocket is currently connected.
  bool get isConnected => _isConnected;

  /// Connect to the WebSocket server.
  Future<void> connect() async {
    if (!EnvConfig.webSocketEnabled) {
      debugPrint('WebSocket: Disabled in configuration');
      return;
    }

    if (_isConnected) {
      debugPrint('WebSocket: Already connected');
      return;
    }

    _shouldReconnect = true;
    await _connect();
  }

  Future<void> _connect() async {
    try {
      final url = EnvConfig.webSocketUrl;
      debugPrint('WebSocket: Connecting to $url');

      _channel = WebSocketChannel.connect(Uri.parse(url));

      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );

      // Wait for connection to establish
      await _channel!.ready;
      _isConnected = true;
      _connectionState.add(true);
      _reconnectAttempts = 0;
      debugPrint('WebSocket: Connected');

      // Start ping timer to keep connection alive
      _startPingTimer();
    } catch (e) {
      debugPrint('WebSocket: Connection failed - $e');
      _isConnected = false;
      _connectionState.add(false);
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final event = data['event'] as String?;

      debugPrint('WebSocket: Received event: $event');

      switch (event) {
        case 'pusher:connection_established':
          _onConnectionEstablished(data);
          break;
        case 'pusher:ping':
          _sendPong();
          break;
        case 'pusher:pong':
          // Server acknowledged our ping
          break;
        case 'pusher_internal:subscription_succeeded':
          debugPrint('WebSocket: Subscribed to ${data['channel']}');
          break;
        case '.image.updated':
          // Laravel events with broadcastAs() are prefixed with '.'
          _onImageUpdated(data);
          break;
      }
    } catch (e) {
      debugPrint('WebSocket: Error parsing message - $e');
    }
  }

  void _onConnectionEstablished(Map<String, dynamic> data) {
    debugPrint('WebSocket: Connection established');

    // Subscribe to the cameras channel
    _subscribe('cameras');
  }

  void _subscribe(String channel) {
    final subscribeMessage = jsonEncode({
      'event': 'pusher:subscribe',
      'data': {'channel': channel},
    });

    _channel?.sink.add(subscribeMessage);
    debugPrint('WebSocket: Subscribing to $channel');
  }

  void _onImageUpdated(Map<String, dynamic> data) {
    try {
      final channel = data['channel'] as String?;
      if (channel != 'cameras') return;

      // Data is a JSON string that needs to be parsed
      final eventDataStr = data['data'] as String;
      final eventData = jsonDecode(eventDataStr) as Map<String, dynamic>;

      final event = CameraImageUpdateEvent.fromJson(eventData);
      debugPrint('WebSocket: Camera ${event.cameraId} image updated');

      _cameraImageUpdates.add(event);
    } catch (e) {
      debugPrint('WebSocket: Error parsing image update - $e');
    }
  }

  void _onError(Object error) {
    debugPrint('WebSocket: Error - $error');
    _isConnected = false;
    _connectionState.add(false);
    _scheduleReconnect();
  }

  void _onDone() {
    debugPrint('WebSocket: Connection closed');
    _isConnected = false;
    _connectionState.add(false);
    _stopPingTimer();
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (!_shouldReconnect) return;
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('WebSocket: Max reconnect attempts reached');
      return;
    }

    _reconnectAttempts++;
    final delay = _reconnectDelay * _reconnectAttempts;
    debugPrint(
      'WebSocket: Reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempts)',
    );

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, _connect);
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(_pingInterval, (_) {
      _sendPing();
    });
  }

  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  void _sendPing() {
    if (!_isConnected) return;

    final pingMessage = jsonEncode({'event': 'pusher:ping', 'data': {}});
    _channel?.sink.add(pingMessage);
  }

  void _sendPong() {
    final pongMessage = jsonEncode({'event': 'pusher:pong', 'data': {}});
    _channel?.sink.add(pongMessage);
  }

  /// Disconnect from the WebSocket server.
  void disconnect() {
    debugPrint('WebSocket: Disconnecting');
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _stopPingTimer();
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    _connectionState.add(false);
  }

  /// Dispose of resources.
  void dispose() {
    disconnect();
    _cameraImageUpdates.close();
    _connectionState.close();
  }
}
