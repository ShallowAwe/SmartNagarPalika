import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_nagarpalika/Model/alert_model.dart';
import 'package:smart_nagarpalika/Services/alert_service.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class AlertsNotifier extends StateNotifier<AsyncValue<List<Alertmodel>>> {
  AlertsNotifier(this._service, this.username, this.password)
      : super(const AsyncValue.loading()) {
    _init();
  }

  final AlertService _service;
  final String username;
  final String password;
  WebSocketChannel? _channel;
  bool _disposed = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  Future<void> _init() async {
    if (_disposed) return;
    
    try {
      final alerts = await _service.fetchAlerts(username, password);
      if (!_disposed) {
        state = AsyncValue.data(alerts);
        _connectWebSocket();
      }
    } catch (e, st) {
      if (!_disposed) {
        state = AsyncValue.error(e, st);
        // Still try to connect WebSocket even if initial fetch fails
        _connectWebSocket();
      }
    }
  }

  void _connectWebSocket() {
    if (_disposed) return;
    
    try {
      final uri = Uri.parse('ws://192.168.1.33:8080/ws/alerts');
      final authHeader =
          'Basic ${base64Encode(utf8.encode('$username:$password'))}';

      _channel = IOWebSocketChannel.connect(
        uri,
        headers: {
          'Authorization': authHeader,
        },
      );

      print('WebSocket connecting...');
      
      _channel!.stream.listen(
        (message) {
          if (_disposed) return;
          
          try {
            print('WebSocket message received: $message');
            final decoded = jsonDecode(message);
            
            if (decoded['type'] == 'NEW_ALERT') {
              final newAlert = Alertmodel.fromJson(decoded['data']);
              
              // Update state by adding new alert to the beginning
              state = state.when(
                data: (currentAlerts) {
                  // Avoid duplicates by checking if alert already exists
                  final alertExists = currentAlerts.any((alert) => 
                    alert.id == newAlert.id);
                  
                  if (!alertExists) {
                    return AsyncValue.data([newAlert, ...currentAlerts]);
                  }
                  return AsyncValue.data(currentAlerts);
                },
                loading: () => AsyncValue.data([newAlert]),
                error: (_, __) => AsyncValue.data([newAlert]),
              );
              
              print('New alert added: ${newAlert.title}');
            } else if (decoded['type'] == 'ALERT_UPDATE') {
              final updatedAlert = Alertmodel.fromJson(decoded['data']);
              
              // Update existing alert
              state = state.whenData((currentAlerts) {
                final updatedAlerts = currentAlerts.map((alert) {
                  return alert.id == updatedAlert.id ? updatedAlert : alert;
                }).toList();
                return updatedAlerts;
              });
            } else if (decoded['type'] == 'ALERT_DELETE') {
              final alertId = decoded['data']['id'];
              
              // Remove alert from list
              state = state.whenData((currentAlerts) {
                return currentAlerts.where((alert) => alert.id != alertId).toList();
              });
            }
          } catch (e) {
            print('Error parsing WebSocket message: $e');
          }
        },
        onError: (err) {
          if (!_disposed) {
            print('WebSocket error: $err');
            _retryConnection();
          }
        },
        onDone: () {
          if (!_disposed) {
            print('WebSocket connection closed');
            _retryConnection();
          }
        },
      );
      
      // Reset reconnect attempts on successful connection
      _reconnectAttempts = 0;
      
    } catch (e) {
      print('Failed to connect WebSocket: $e');
      _retryConnection();
    }
  }

  void _retryConnection() {
    if (_disposed || _reconnectAttempts >= _maxReconnectAttempts) {
      if (_reconnectAttempts >= _maxReconnectAttempts) {
        print('Max reconnection attempts reached');
      }
      return;
    }
    
    _reconnectAttempts++;
    _channel?.sink.close();
    _channel = null;
    
    // Exponential backoff for reconnection
    final delay = Duration(seconds: 2 * _reconnectAttempts);
    print('Retrying WebSocket connection in ${delay.inSeconds} seconds (attempt $_reconnectAttempts)');
    
    Future.delayed(delay, () {
      if (!_disposed) {
        _connectWebSocket();
      }
    });
  }

  // Method to manually refresh alerts
  Future<void> refreshAlerts() async {
    if (_disposed) return;
    
    try {
      final alerts = await _service.fetchAlerts(username, password);
      if (!_disposed) {
        state = AsyncValue.data(alerts);
      }
    } catch (e, st) {
      if (!_disposed) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  // Method to force reconnect WebSocket
  void reconnectWebSocket() {
    if (_disposed) return;
    
    _channel?.sink.close();
    _channel = null;
    _reconnectAttempts = 0;
    _connectWebSocket();
  }

  @override
  void dispose() {
    print('AlertsNotifier disposing...');
    _disposed = true;
    _channel?.sink.close();
    super.dispose();
  }
}