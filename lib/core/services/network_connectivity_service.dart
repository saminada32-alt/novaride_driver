import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';

enum AppNetworkStatus { online, offline, weak }

class NetworkConnectivityService extends ChangeNotifier {
  static const _weakThresholdMs = 2500;
  static const _probeTimeout = Duration(seconds: 5);
  static const _probeInterval = Duration(seconds: 12);

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;
  Timer? _probeTimer;
  bool _probing = false;

  AppNetworkStatus status = AppNetworkStatus.online;

  bool get isOnline => status == AppNetworkStatus.online;

  Future<void> start() async {
    await probe();
    _sub = _connectivity.onConnectivityChanged.listen((_) => probe());
    _probeTimer = Timer.periodic(_probeInterval, (_) => probe());
  }

  Future<void> probe() async {
    if (_probing) return;
    _probing = true;
    try {
      final results = await _connectivity.checkConnectivity();
      final hasLink = results.any((r) => r != ConnectivityResult.none);
      if (!hasLink) {
        _setStatus(AppNetworkStatus.offline);
        return;
      }

      final uri = Uri.parse('${AppConfig.apiBaseUrl}/health/live');
      final sw = Stopwatch()..start();
      final res = await http.get(uri).timeout(_probeTimeout);
      sw.stop();

      if (res.statusCode >= 200 && res.statusCode < 300) {
        _setStatus(
          sw.elapsedMilliseconds >= _weakThresholdMs
              ? AppNetworkStatus.weak
              : AppNetworkStatus.online,
        );
      } else {
        _setStatus(AppNetworkStatus.offline);
      }
    } catch (_) {
      _setStatus(AppNetworkStatus.offline);
    } finally {
      _probing = false;
    }
  }

  void _setStatus(AppNetworkStatus next) {
    if (status == next) return;
    status = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _probeTimer?.cancel();
    super.dispose();
  }
}
