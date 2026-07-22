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

  void _safe(String event, void Function() fn) {
    try {
      fn();
    } catch (e) {
      if (kDebugMode) debugPrint('Driver socket $event: $e');
    }
  }

  Map<String, dynamic>? _asMap(dynamic data) {
    if (data is! Map) return null;
    return Map<String, dynamic>.from(data);
  }

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
      _safe('new_ride_offer', () {
        final map = _asMap(data);
        if (map == null) return;
        onNewRideOffer?.call(map);
        onTripEvent?.call({'event': 'new_ride_offer', ...map});
      });
    });

    _socket!.on('ride_taken', (data) {
      _safe('ride_taken', () {
        final rideId = data is Map ? data['rideId'] : null;
        final id = rideId is int ? rideId : int.tryParse('$rideId');
        onRideTaken?.call(id);
      });
    });

    _socket!.on('driver_accepted_ride', (data) {
      _safe('driver_accepted_ride', () {
        final map = _asMap(data);
        if (map == null) return;
        final id = int.tryParse('${map['rideId']}');
        if (id != null && id > 0) onDriverAcceptedRide?.call(id);
      });
    });

    _socket!.on('ride_status_changed', (data) {
      _safe('ride_status_changed', () {
        final map = _asMap(data);
        if (map == null) return;
        onTripEvent?.call({'event': 'ride_status_changed', ...map});
      });
    });

    _socket!.on('ride_cancelled', (data) {
      _safe('ride_cancelled', () {
        final map = _asMap(data);
        if (map == null) return;
        onTripEvent?.call({'event': 'ride_cancelled', ...map});
      });
    });

    _socket!.on('driver:event', (data) {
      _safe('driver:event', () {
        final map = _asMap(data);
        if (map == null) return;
        onTripEvent?.call(map);
      });
    });

    _socket!.on('chat:message', (data) {
      _safe('chat:message', () {
        final map = _asMap(data);
        if (map == null) return;
        onChatMessage?.call(map);
      });
    });

    _socket!.on('support_chat:message', (data) {
      _safe('support_chat:message', () {
        final map = _asMap(data);
        if (map == null) return;
        onSupportChatMessage?.call(map);
      });
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
