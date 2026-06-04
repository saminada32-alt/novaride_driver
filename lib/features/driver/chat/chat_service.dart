import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import 'chat_message.dart';

class DriverChatService {
  DriverChatService._();
  static DriverChatService instance = DriverChatService._();

  static const _storage = FlutterSecureStorage();
  static const _h = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<String?> _token() => _storage.read(key: 'driver_token');
  Map<String, String> _auth(String t) => {..._h, 'Authorization': 'Bearer $t'};

  List<dynamic> _parseList(http.Response res) {
    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return data is List ? data : [];
    }
    final msg = data['message'];
    throw Exception(msg is List ? msg.join(', ') : msg?.toString() ?? 'Error');
  }

  Map<String, dynamic> _parseObj(http.Response res) {
    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return Map<String, dynamic>.from(data as Map);
    }
    final msg = data['message'];
    throw Exception(msg is List ? msg.join(', ') : msg?.toString() ?? 'Error');
  }

  Future<List<ChatMessage>> getRideMessages(int rideId) async {
    final tok = await _token();
    if (tok == null) throw Exception('Not authenticated');

    final res = await http.get(
      Uri.parse('${Api.base}/rides/$rideId/messages'),
      headers: _auth(tok),
    );
    return _parseList(res)
        .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<ChatMessage> sendRideMessage(int rideId, String body) async {
    final tok = await _token();
    if (tok == null) throw Exception('Not authenticated');

    final res = await http.post(
      Uri.parse('${Api.base}/rides/$rideId/messages'),
      headers: _auth(tok),
      body: jsonEncode({'body': body.trim()}),
    );
    return ChatMessage.fromJson(_parseObj(res));
  }

  Future<List<ChatMessage>> getSupportMessages() async {
    final tok = await _token();
    if (tok == null) throw Exception('Not authenticated');

    final res = await http.get(
      Uri.parse('${Api.base}/support/chat/messages'),
      headers: _auth(tok),
    );
    return _parseList(res)
        .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<ChatMessage> sendSupportMessage(String body) async {
    final tok = await _token();
    if (tok == null) throw Exception('Not authenticated');

    final res = await http.post(
      Uri.parse('${Api.base}/support/chat/messages'),
      headers: _auth(tok),
      body: jsonEncode({'body': body.trim()}),
    );
    return ChatMessage.fromJson(_parseObj(res));
  }
}
