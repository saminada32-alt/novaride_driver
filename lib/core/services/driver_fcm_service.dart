import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import 'notification_inbox_service.dart';

class DriverFcmService {
  DriverFcmService._();

  static final DriverFcmService instance = DriverFcmService._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<RemoteMessage>? _messageSub;
  StreamSubscription<RemoteMessage>? _openedSub;
  StreamSubscription<String>? _tokenSub;

  Function(int rideId)? _onNewRide;
  int? _pendingRideId;

  /// Set by the home screen. If a ride offer arrived (e.g. via a tapped
  /// notification) before the handler was wired, it is replayed immediately.
  set onNewRide(Function(int rideId)? cb) {
    _onNewRide = cb;
    final pending = _pendingRideId;
    if (cb != null && pending != null) {
      _pendingRideId = null;
      cb(pending);
    }
  }

  Function(int rideId)? get onNewRide => _onNewRide;

  void _emitNewRide(int rideId) {
    final cb = _onNewRide;
    if (cb != null) {
      cb(rideId);
    } else {
      _pendingRideId = rideId;
    }
  }

  bool _initialized = false;

  // ---------------- INIT ----------------
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await _initLocalNotifications();
      await _initFirebase();
    } catch (e, st) {
      debugPrint('DriverFcmService init failed: $e');
    }
  }

  // ---------------- LOCAL NOTIFICATIONS ----------------
  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    await _notifications.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      ),
    );

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'driver_channel',
        'Driver Notifications',
        importance: Importance.max,
        playSound: true,
      ),
    );
  }

  // ---------------- FCM ----------------
  Future<void> _initFirebase() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(alert: true, badge: true, sound: true);

    // initial token
    final token = await messaging.getToken();
    if (token != null) {
      await _syncToken(token);
    }

    // token refresh
    _tokenSub = messaging.onTokenRefresh.listen((token) {
      _syncToken(token);
    });

    // foreground messages
    _messageSub = FirebaseMessaging.onMessage.listen(_handleMessage);

    // notification tapped while app was in the background
    _openedSub =
        FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedApp);

    // app launched from terminated state by tapping a notification
    final initial = await messaging.getInitialMessage();
    if (initial != null) _handleOpenedApp(initial);
  }

  // ---------------- MESSAGE HANDLER ----------------
  Future<void> _handleMessage(RemoteMessage msg) async {
    try {
      final title = msg.notification?.title ?? 'NovaRide';
      final body = msg.notification?.body ?? '';

      await NotificationInboxService.instance.addFromPush(
        title: title,
        body: body,
        type: msg.data['type']?.toString() ?? 'GENERIC',
        data: Map<String, dynamic>.from(msg.data),
      );

      await _showNotification(title, body);

      final data = msg.data;

      final type = data['type'];
      final rideId = int.tryParse(data['rideId']?.toString() ?? '');

      if (type == 'NEW_RIDE' && rideId != null) {
        _emitNewRide(rideId);
      }
    } catch (_) {
      // avoid crash from malformed push
    }
  }

  /// Handles a notification tap while the app is in background or terminated.
  void _handleOpenedApp(RemoteMessage msg) {
    final type = msg.data['type'];
    final rideId = int.tryParse(msg.data['rideId']?.toString() ?? '');
    if (type == 'NEW_RIDE' && rideId != null) {
      _emitNewRide(rideId);
    }
  }

  // ---------------- TOKEN SYNC ----------------
  Future<void> _syncToken(String token) async {
    try {
      final driverToken = await _storage.read(key: 'driver_token');
      if (driverToken == null) return;

      await http
          .patch(
            Uri.parse('${Api.base}/drivers/me/fcm-token'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $driverToken',
            },
            body: jsonEncode({'fcmToken': token}),
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      // optionally log to crashlytics
    }
  }

  // ---------------- LOCAL NOTIFICATION ----------------
  Future<void> _showNotification(String title, String body) async {
    await _notifications.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'driver_channel',
          'Driver Notifications',
          channelDescription: 'Driver notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          fullScreenIntent: true,
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
      ),
    );
  }

  // ---------------- CLEANUP ----------------
  Future<void> dispose() async {
    await _messageSub?.cancel();
    await _openedSub?.cancel();
    await _tokenSub?.cancel();

    _messageSub = null;
    _openedSub = null;
    _tokenSub = null;
    _initialized = false;
  }
}
