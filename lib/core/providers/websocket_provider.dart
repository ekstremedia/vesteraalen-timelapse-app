import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vesteraalen_timelapse/core/config/env_config.dart';
import 'package:vesteraalen_timelapse/core/services/websocket_service.dart';

/// Provider for the WebSocket service singleton.
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Provider for WebSocket connection state.
/// Returns null if WebSocket is disabled, true if connected, false if disconnected.
final webSocketConnectionProvider = StreamProvider<bool?>((ref) {
  if (!EnvConfig.webSocketEnabled) {
    return Stream.value(null);
  }

  final service = ref.watch(webSocketServiceProvider);

  // Return a stream that starts with the current state and then listens for changes
  return Stream.multi((controller) {
    // Emit current state immediately
    controller.add(service.isConnected);

    // Listen for changes
    final subscription = service.connectionState.listen(controller.add);

    controller.onCancel = () {
      subscription.cancel();
    };
  });
});
