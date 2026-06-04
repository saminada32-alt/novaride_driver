import 'package:flutter/material.dart';
import '../model/earning_model.dart';
import '../service/earning_service.dart';

enum EarningFilter { daily, weekly, monthly }

class EarningProvider extends ChangeNotifier {
  final EarningService _service = EarningService();

  EarningModel? _earning;
  bool _loading = false;
  String? _error;
  EarningFilter _filter = EarningFilter.weekly;

  EarningModel? get earning => _earning;
  bool get isLoading => _loading;
  String? get error => _error;
  EarningFilter get filter => _filter;

  double get selectedTotal {
    if (_earning == null) return 0;
    switch (_filter) {
      case EarningFilter.daily:
        return _earning!.today;
      case EarningFilter.weekly:
        return _earning!.week;
      case EarningFilter.monthly:
        return _earning!.month;
    }
  }

  List<DailyEarning> get chartData {
    if (_earning == null) return [];
    switch (_filter) {
      case EarningFilter.daily:
        return _earning!.daily;
      case EarningFilter.weekly:
        return _earning!.weekly;
      case EarningFilter.monthly:
        return _earning!.monthly;
    }
  }

  Future<void> loadEarnings(String token) async {
    if (_loading) return;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _earning = await _service.fetchEarnings(token);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void changeFilter(EarningFilter f) {
    _filter = f;
    notifyListeners();
  }
}
