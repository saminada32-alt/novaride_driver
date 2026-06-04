import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

class DriverSocketService {
  DriverSocketService._();
  static DriverSocketService instance = DriverSocketService._();

  IO.Socket? _socket;
  static const _storage = FlutterSecureStorage();

  Function(Map<String, dynamic>)? onTripEvent;
  Function(double lat, double lng)? onPassengerLocation;
  Function(Map<String, dynamic>)? onChatMessage;
  Function(Map<String, dynamic>)? onSupportChatMessage;

  Future<void> connect() async {
    final tok = await _storage.read(key: 'driver_token');
    if (tok == null) return;

    _socket = IO.io(
      '${Api.base}/tracking',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': tok})
          .enableReconnection()
          .build(),
    );

    _socket!.onConnect((_) {
      print('Driver Socket Connected');
      _socket!.emit('driver:online');
    });

    _socket!.on('new_ride_offer', (data) {
      onTripEvent?.call({
        'event': 'new_ride_offer',
        ...Map<String, dynamic>.from(data as Map),
      });
    });

    _socket!.on('ride_status_changed', (data) {
      onTripEvent?.call({
        'event': 'ride_status_changed',
        ...Map<String, dynamic>.from(data as Map),
      });
    });

    _socket!.on('ride_cancelled', (data) {
      onTripEvent?.call({
        'event': 'ride_cancelled',
        ...Map<String, dynamic>.from(data as Map),
      });
    });

    _socket!.on('driver:event', (data) {
      onTripEvent?.call(Map<String, dynamic>.from(data as Map));
    });

    _socket!.on('chat:message', (data) {
      onChatMessage?.call(Map<String, dynamic>.from(data as Map));
    });

    _socket!.on('support_chat:message', (data) {
      onSupportChatMessage?.call(Map<String, dynamic>.from(data as Map));
    });

    _socket!.connect();
  }

  void sendLocation(double lat, double lng) {
    _socket?.emit('driver:location', {'lat': lat, 'lng': lng});
  }

  void joinTrip(int tripId) {
    _socket?.emit('trip:join', {'tripId': tripId});
  }

  void leaveTrip(int tripId) {
    _socket?.emit('trip:leave', {'tripId': tripId});
  }

  void disconnect() => _socket?.disconnect();
}
