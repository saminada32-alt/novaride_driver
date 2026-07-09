import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

class DriverSocketService {
  DriverSocketService._();
  static DriverSocketService instance = DriverSocketService._();

  IO.Socket? _socket;
  static const _storage = FlutterSecureStorage();
  int? _driverId;

  Function(Map<String, dynamic>)? onTripEvent;
  Function(double lat, double lng)? onPassengerLocation;
  Function(Map<String, dynamic>)? onChatMessage;
  Function(Map<String, dynamic>)? onSupportChatMessage;

  Function(Map<String, dynamic>)? onNewRideOffer;
  Function(int? rideId)? onRideTaken;
  Function(int rideId)? onDriverAcceptedRide;

  bool get isConnected => _socket?.connected == true;

  void setDriverId(int? id) => _driverId = id;

  Future<void> connect({int? driverId}) async {
    if (driverId != null) _driverId = driverId;

    final tok = await _storage.read(key: 'driver_token');
    if (tok == null) return;

    if (_socket?.connected == true) {
      _emitOnline();
      return;
    }

    _socket?.dispose();
    _socket = IO.io(
      '${Api.base}/tracking',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': tok})
          .enableReconnection()
          .build(),
    );

    _socket!.onConnect((_) {
      if (kDebugMode) debugPrint('Driver Socket Connected');
      _emitOnline();
    });

    _socket!.on('new_ride_offer', (data) {
      final map = Map<String, dynamic>.from(data as Map);
      onNewRideOffer?.call(map);
      onTripEvent?.call({'event': 'new_ride_offer', ...map});
    });

    _socket!.on('ride_taken', (data) {
      final rideId = data is Map ? data['rideId'] : null;
      final id = rideId is int ? rideId : int.tryParse('$rideId');
      onRideTaken?.call(id);
    });

    _socket!.on('driver_accepted_ride', (data) {
      if (data is! Map) return;
      final rideId = data['rideId'];
      final id = int.tryParse('$rideId');
      if (id != null && id > 0) onDriverAcceptedRide?.call(id);
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

  void _emitOnline() {
    if (_driverId != null) {
      _socket?.emit('driver:online', {'driverId': _driverId});
    } else {
      _socket?.emit('driver:online');
    }
  }

  void sendLocation(double lat, double lng) {
    _socket?.emit('driver:location', {'lat': lat, 'lng': lng});
  }

  void sendHeartbeat(double lat, double lng) {
    _socket?.emit('driver:heartbeat', {'lat': lat, 'lng': lng});
  }

  void joinTrip(int tripId) {
    _socket?.emit('trip:join', {'tripId': tripId});
  }

  void leaveTrip(int tripId) {
    _socket?.emit('trip:leave', {'tripId': tripId});
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
