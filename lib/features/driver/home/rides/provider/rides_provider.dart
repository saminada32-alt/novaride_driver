import 'package:flutter/material.dart';
import '../model/ride_model.dart';
import '../service/rides_service.dart';

class RidesProvider extends ChangeNotifier {
  final _service = DriverRidesService.instance;

  List<DriverRideModel> _all = [];
  List<DriverRideModel> _filtered = [];
  bool _loading = false;
  String? _error;
  String _filter = 'all';

  List<DriverRideModel> get trips => _filtered;
  bool get isLoading => _loading;
  String? get error => _error;
  String get filter => _filter;

  Future<void> loadTrips() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _all = await _service.getMyRides();
      _applyFilter();
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  void applyFilter(String f) {
    _filter = f;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_filter == 'all') {
      _filtered = _all
          .where(
            (t) =>
                t.status == DriverRideStatus.completed ||
                t.status == DriverRideStatus.cancelled,
          )
          .toList();
    } else if (_filter == 'COMPLETED') {
      _filtered = _all
          .where((t) => t.status == DriverRideStatus.completed)
          .toList();
    } else if (_filter == 'CANCELLED') {
      _filtered = _all
          .where((t) => t.status == DriverRideStatus.cancelled)
          .toList();
    }
  }
}
