import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Retries slow/mobile networks common in Syria (2G/3G, high latency).
class ResilientHttp {
  ResilientHttp._();

  static const _defaultTimeout = Duration(seconds: 20);
  static const _defaultMaxAttempts = 3;

  static Future<http.Response> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Duration timeout = _defaultTimeout,
    int maxAttempts = _defaultMaxAttempts,
  }) async {
    return _run(
      () => http.post(uri, headers: headers, body: body).timeout(timeout),
      maxAttempts: maxAttempts,
    );
  }

  /// OTP verify: one long attempt — Syria networks; retries cause duplicate submits.
  static Future<http.Response> authPost(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return post(
      uri,
      headers: headers,
      body: body,
      timeout: const Duration(seconds: 45),
      maxAttempts: 1,
    );
  }

  /// OTP send: API waits for Aman Gate accept (~12s max).
  static Future<http.Response> authSendPost(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return post(
      uri,
      headers: headers,
      body: body,
      timeout: const Duration(seconds: 18),
      maxAttempts: 2,
    );
  }

  static Future<http.Response> get(
    Uri uri, {
    Map<String, String>? headers,
    Duration timeout = _defaultTimeout,
    int maxAttempts = _defaultMaxAttempts,
  }) async {
    return _run(
      () => http.get(uri, headers: headers).timeout(timeout),
      maxAttempts: maxAttempts,
    );
  }

  static Future<http.Response> authGet(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    return get(
      uri,
      headers: headers,
      timeout: const Duration(seconds: 20),
      maxAttempts: 2,
    );
  }

  static Future<http.Response> patch(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Duration timeout = _defaultTimeout,
    int maxAttempts = _defaultMaxAttempts,
  }) async {
    return _run(
      () => http.patch(uri, headers: headers, body: body).timeout(timeout),
      maxAttempts: maxAttempts,
    );
  }

  static Future<http.Response> _run(
    Future<http.Response> Function() request, {
    required int maxAttempts,
  }) async {
    Object? lastError;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        return await request();
      } on SocketException catch (e) {
        lastError = e;
      } on TimeoutException catch (e) {
        lastError = e;
      } on HttpException catch (e) {
        lastError = e;
      }
      if (attempt < maxAttempts - 1) {
        await Future.delayed(Duration(milliseconds: 400 * (attempt + 1)));
      }
    }
    throw lastError ?? const SocketException('Network unavailable');
  }

  static Map<String, dynamic> decodeJson(http.Response res) =>
      jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
}
