import 'dart:async';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../notif/not.dart';


class WebSocketService {
  WebSocketChannel? _channel;
  final StreamController<String> _streamController = StreamController.broadcast();

  final String ipAddress = "192.168.4.1"; // 🔹 ESP32 IP

  /// Stream of incoming WebSocket messages
  Stream<String> get messages => _streamController.stream;

  /// Whether the WebSocket is currently connected
  bool get isConnected => _channel != null;

  /// Connect to the ESP32 WebSocket server
  void connect() {
    final uri = Uri.parse('ws://$ipAddress:80/ws');

    try {
      _channel = IOWebSocketChannel.connect(uri);

      _channel!.stream.listen(
            (message) {
          final msg = message.toString().trim();
          _streamController.add(msg);

          // 🔹 Emergency alert
          if (msg == "E") {
            NotificationService.showEmergencyNotification();
          }

          // 🔹 Container event (no notification, just pass to stream)
          else if (msg == "C") {
            // Add C to stream so homescreen can handle incrementing container count
            _streamController.add("C");
          }

          // 🔹 Parse water levels (e.g., "H25", "H50", "H75", "H100")
          else if (msg.startsWith("H")) {
            final level = int.tryParse(msg.substring(1));
            if (level != null) {
              _streamController.add("H$level"); // pass along water info
            }
          }

          // 🔹 Parse waste levels (e.g., "W25", "W50", "W75", "W100")
          else if (msg.startsWith("W")) {
            final percent = int.tryParse(msg.substring(1));
            if (percent != null) {
              _streamController.add("W$percent"); // pass along waste info
            }
          }
        },
        onError: (error) {
          _streamController.addError("WebSocket error: $error");
          disconnect();
        },
        onDone: () {
          _streamController.add("WebSocket connection closed.");
          disconnect();
        },
      );
    } catch (e) {
      _streamController.addError("Connection failed: $e");
    }
  }

  /// Send a message to ESP32
  void sendMessage(String message) {
    if (isConnected) {
      try {
        _channel!.sink.add(message);
      } catch (e) {
        _streamController.addError("Send failed: $e");
      }
    } else {
      _streamController.addError("Not connected. Message not sent: $message");
    }
  }

  /// Close the WebSocket connection
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  /// Dispose the controller and connection
  void dispose() {
    disconnect();
    _streamController.close();
  }
}
