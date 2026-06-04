import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class AppNotificationItem {
  final int id;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic> data;
  final bool read;
  final DateTime? createdAt;

  AppNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.read,
    this.createdAt,
  });

  factory AppNotificationItem.fromJson(Map<String, dynamic> j) =>
      AppNotificationItem(
        id: j['id'] as int,
        title: j['title']?.toString() ?? '',
        body: j['body']?.toString() ?? '',
        type: j['type']?.toString() ?? 'GENERIC',
        data: j['data'] is Map
            ? Map<String, dynamic>.from(j['data'] as Map)
            : {},
        read: j['read'] == true,
        createdAt: j['createdAt'] != null
            ? DateTime.tryParse(j['createdAt'].toString())
            : null,
      );
}

class NotificationInboxService {
  NotificationInboxService._();
  static NotificationInboxService instance = NotificationInboxService._();

  static const _storage = FlutterSecureStorage();
  static const _cacheKey = 'driver_notification_cache_v1';

  final List<AppNotificationItem> _local = [];
  List<AppNotificationItem> get items => List.unmodifiable(_local);

  Future<void> loadFromApi() async {
    final tok = await _storage.read(key: 'driver_token');
    if (tok == null) return;

    try {
      final res = await http
          .get(
            Uri.parse('${Api.base}/notifications/me'),
            headers: {
              'Authorization': 'Bearer $tok',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 12));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        final list = data is List ? data : [];
        _local
          ..clear()
          ..addAll(
            list.map(
              (e) => AppNotificationItem.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            ),
          );
      }
    } catch (_) {}
  }

  Future<void> addFromPush({
    required String title,
    required String body,
    required String type,
    Map<String, dynamic> data = const {},
  }) async {
    _local.insert(
      0,
      AppNotificationItem(
        id: -DateTime.now().millisecondsSinceEpoch,
        title: title,
        body: body,
        type: type,
        data: data,
        read: false,
        createdAt: DateTime.now(),
      ),
    );
    if (_local.length > 100) _local.removeRange(100, _local.length);
    await loadFromApi();
  }

  Future<void> markRead(int id) async {
    final tok = await _storage.read(key: 'driver_token');
    if (tok != null && id > 0) {
      try {
        await http.patch(
          Uri.parse('${Api.base}/notifications/me/$id/read'),
          headers: {'Authorization': 'Bearer $tok'},
        );
      } catch (_) {}
    }
    await loadFromApi();
  }

  Future<void> markAllRead() async {
    final tok = await _storage.read(key: 'driver_token');
    if (tok != null) {
      try {
        await http.patch(
          Uri.parse('${Api.base}/notifications/me/read-all'),
          headers: {'Authorization': 'Bearer $tok'},
        );
      } catch (_) {}
    }
    await loadFromApi();
  }
}
