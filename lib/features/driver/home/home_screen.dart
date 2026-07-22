import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../../l10n/app_localizations.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/driver_background_location_service.dart';
import '../../../core/services/driver_fcm_service.dart';
import '../../../core/services/socket_service.dart';
import '../../../core/utils/api_error_messages.dart';
import '../../../core/widgets/a11y.dart';
import '../../../core/utils/resilient_http.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/welcome/welcome_screen.dart';
import 'account/account_screen.dart';
import 'account/provider/account_provider.dart';
import 'earnings/earning_screen.dart';
import 'earnings/provider/earning_provider.dart';
import 'rides/trips_screen.dart';
import 'rides/provider/rides_provider.dart';
import 'vehicle/provider/vehicle_provider.dart';
import 'rides/service/rides_service.dart';
import 'rides/model/ride_model.dart';
import 'rides/screens/active_ride_screen.dart';
import 'incoming_ride_dialog.dart';
import '../subscription/my_subscription_screen.dart';
import '../work_zones/work_zones_screen.dart';
import '../../../core/services/work_zones_service.dart';
import '../../../core/services/driver_location_guard.dart';
import 'widgets/driver_drawer.dart';
import 'widgets/driver_home_map.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  int _tab = 0;
  bool _isOnline = false;
  final bool _toggling = false;
  bool _resumingRide = false;

  GoogleMapController? _map;
  LatLng _pos = const LatLng(33.5138, 36.2765);
  DateTime? _lastGpsAt;
  bool _hasGpsFix = false;
  final _loc = Location();

  DriverRideModel? _activeRide;
  BuildContext? _offerDialogCtx;

  int? _driverId;

  Timer? _locationTimer;
  Timer? _heartbeatTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final auth = context.read<AuthProvider>();
    final driver = auth.driver;
    if (driver != null) {
      context.read<AccountProvider>().seedFromDriver(driver);
      _driverId = driver.id;
      if (mounted) setState(() => _isOnline = driver.status == 'online');
    }

    _bindSocket();
    unawaited(DriverSocketService.instance.connect(driverId: _driverId));
    unawaited(WorkZonesService.instance.prefetch());

    final token = auth.token;
    if (token != null) {
      if (_isOnline) unawaited(_startOnlineTracking(token));
      unawaited(_loadDeferredData(token));
    }

    unawaited(_initLoc());
    unawaited(_resumeActiveRideIfAny());
    _wireFcm();
  }

  void _bindSocket() {
    final socket = DriverSocketService.instance;
    socket.setDriverId(_driverId);
    socket.onNewRideOffer = _handleIncomingRideOffer;
    socket.onRideTaken = _handleRideTaken;
    socket.onDriverAcceptedRide = _openAcceptedRide;
  }

  void _wireFcm() {
    DriverFcmService.instance.onNewRide = _onFcmNewRide;
  }

  Future<void> _onFcmNewRide(int rideId) async {
    if (!mounted || _activeRide != null || !_isOnline) return;

    try {
      final pending = await DriverRidesService.instance.getPendingRides(
        lat: _pos.latitude,
        lng: _pos.longitude,
      );
      DriverRideModel? ride;
      for (final r in pending) {
        if (r.id == rideId) {
          ride = r;
          break;
        }
      }
      if (ride != null && mounted) {
        setState(() => _activeRide = ride);
        _showIncomingRide(ride);
      }
    } catch (e) {
      debugPrint('FCM ride fetch error: $e');
    }
  }

  void _handleIncomingRideOffer(Map<String, dynamic> data) {
    if (!mounted || _activeRide != null) return;
    try {
      final ride = DriverRideModel.fromJson(data);
      setState(() => _activeRide = ride);
      _showIncomingRide(ride);
    } catch (e) {
      debugPrint('Parse error: $e');
    }
  }

  Future<void> _loadDeferredData(String token) async {
    await context.read<AccountProvider>().loadAccount(token);
    if (!mounted) return;

    final account = context.read<AccountProvider>().account;
    _driverId = account?.id is int
        ? account!.id as int
        : int.tryParse(account?.id.toString() ?? '');
    DriverSocketService.instance.setDriverId(_driverId);

    final status = account != null && mounted
        ? await _fetchOnlineStatus(token)
        : null;
    if (status != null && mounted) {
      setState(() => _isOnline = status);
      if (status) await _startOnlineTracking(token);
    }

    unawaited(context.read<EarningProvider>().loadEarnings(token));
    unawaited(context.read<RidesProvider>().loadTrips());
    unawaited(context.read<VehicleProvider>().loadVehicle(token));
  }

  Future<bool?> _fetchOnlineStatus(String token) async {
    try {
      final res = await http.get(
        Uri.parse('${Api.base}${Api.driversMe}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return body['status']?.toString() == 'online';
    } catch (e) {
      debugPrint('Fetch online status error: $e');
      return null;
    }
  }

  Future<void> _resumeActiveRideIfAny() async {
    if (_resumingRide || !mounted) return;
    _resumingRide = true;
    try {
      final rides = await DriverRidesService.instance.getMyRides();
      DriverRideModel? active;
      for (final r in rides) {
        if (r.isActive) {
          active = r;
          break;
        }
      }
      if (active == null || !mounted) return;

      setState(() => _activeRide = active);
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ActiveRideScreen(
            initialRide: active!,
            initialDriverPosition: _pos,
          ),
        ),
      );
      if (mounted) setState(() => _activeRide = null);
    } catch (e) {
      debugPrint('Resume active ride error: $e');
    } finally {
      _resumingRide = false;
    }
  }

  Future<void> _openAcceptedRide(int rideId) async {
    if (!mounted || rideId <= 0) return;
    try {
      final rides = await DriverRidesService.instance.getMyRides();
      DriverRideModel? ride;
      for (final r in rides) {
        if (r.id == rideId) {
          ride = r;
          break;
        }
      }
      if (ride == null || !ride.isActive || !mounted) return;
      setState(() => _activeRide = ride);
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ActiveRideScreen(
            initialRide: ride!,
            initialDriverPosition: _pos,
          ),
        ),
      );
      if (mounted) setState(() => _activeRide = null);
    } catch (e) {
      debugPrint('Open accepted ride error: $e');
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (DriverSocketService.instance.isConnected && _isOnline) {
        DriverSocketService.instance.sendHeartbeat(
          _pos.latitude,
          _pos.longitude,
        );
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _heartbeatTimer?.cancel();
    DriverFcmService.instance.onNewRide = null;
    final socket = DriverSocketService.instance;
    socket.onNewRideOffer = null;
    socket.onRideTaken = null;
    socket.onDriverAcceptedRide = null;
    super.dispose();
  }

  void _handleRideTaken(int? rideId) {
    if (!mounted) return;
    if (_activeRide == null || (rideId != null && _activeRide!.id != rideId)) {
      return;
    }

    final ctx = _offerDialogCtx;
    if (ctx != null && Navigator.canPop(ctx)) {
      Navigator.pop(ctx);
    }
    _offerDialogCtx = null;
    setState(() => _activeRide = null);

    final l = AppLocalizations.of(context);
    if (l != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.rideTakenByAnother),
          backgroundColor: Colors.blueGrey,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showIncomingRide(DriverRideModel ride) {
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        _offerDialogCtx = dialogCtx;
        return IncomingRideDialog(
          ride: ride,
          onAccept: () async {
            Navigator.pop(context);

            try {
              final accepted = await DriverRidesService.instance.acceptRide(
                ride.id,
              );

              if (!mounted) return;

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ActiveRideScreen(
                    initialRide: accepted,
                    initialDriverPosition: _pos,
                  ),
                ),
              );
              if (mounted) setState(() => _activeRide = null);
            } catch (e) {
              if (!mounted) return;
              final t = AppLocalizations.of(context)!;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localizeApiError(e.toString(), t)),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          onReject: () async {
            Navigator.pop(context);
            try {
              await DriverRidesService.instance.rejectRideOffer(ride.id);
            } catch (_) {}
            if (mounted) setState(() => _activeRide = null);
          },
        );
      },
    ).then((_) => _offerDialogCtx = null);
  }

  Future<void> _initLoc() async {
    final p = await _loc.requestPermission();
    if (!mounted) return;
    if (p != PermissionStatus.granted) return;

    final token = context.read<AuthProvider>().token;

    DriverBackgroundLocationService.instance.onPosition = (lat, lng) {
      if (!mounted) return;
      setState(() {
        _pos = LatLng(lat, lng);
        _hasGpsFix = true;
        _lastGpsAt = DateTime.now();
      });
      _map?.animateCamera(CameraUpdate.newLatLng(_pos));

      if (token != null && _isOnline) {
        _pushLocation(token, lat, lng);
      }
    };

    _loc.onLocationChanged.listen(
      (l) async {
        if (!mounted || l.latitude == null) return;
        final lat = l.latitude!;
        final lng = l.longitude!;
        setState(() {
          _pos = LatLng(lat, lng);
          _hasGpsFix = true;
          _lastGpsAt = DateTime.now();
        });
        _map?.animateCamera(CameraUpdate.newLatLng(_pos));

        if (token != null && _isOnline) {
          await _pushLocation(token, lat, lng);
        }
      },
      onError: (e) => debugPrint('Driver location stream: $e'),
    );
  }

  Future<void> _pushLocation(String token, double lat, double lng) async {
    try {
      await http.patch(
        Uri.parse('${Api.base}/drivers/me/location'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'lat': lat, 'lng': lng}),
      );
    } catch (e) {
      debugPrint('Location REST error: $e');
    }

    if (DriverSocketService.instance.isConnected) {
      DriverSocketService.instance.sendLocation(lat, lng);
    }
  }

  Future<void> _startOnlineTracking(String token) async {
    unawaited(DriverBackgroundLocationService.instance.start());
    unawaited(_sendLocation(token));
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _sendLocation(token),
    );
    _startHeartbeat();
  }

  Future<void> _stopOnlineTracking() async {
    await DriverBackgroundLocationService.instance.stop();
    _locationTimer?.cancel();
    _locationTimer = null;
    _stopHeartbeat();
  }

  Future<void> _toggle() async {
    if (_toggling) return;

    final newOnline = !_isOnline;
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    if (!newOnline) {
      setState(() => _isOnline = false);
      unawaited(_stopOnlineTracking());
      unawaited(_patchStatus(token, false));
      return;
    }

    setState(() => _isOnline = true);
    unawaited(_startOnlineTracking(token));
    unawaited(_completeGoOnline(token));
  }

  Future<void> _completeGoOnline(String token) async {
    try {
      final t = AppLocalizations.of(context)!;
      final checks = await Future.wait([
        WorkZonesService.instance.isOnShift(),
        DriverLocationGuard.checkBeforeOnline(
          _loc,
          cachedPosition: _hasGpsFix ? _pos : null,
          cachedAt: _lastGpsAt,
        ),
      ]);
      final onShift = checks[0] as bool;
      final locResult = checks[1] as LocationGuardResult;

      if (!onShift && mounted) {
        setState(() => _isOnline = false);
        unawaited(_stopOnlineTracking());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.workZonesOffShiftOnline),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (!locResult.ok && mounted) {
        setState(() => _isOnline = false);
        unawaited(_stopOnlineTracking());
        final msg = switch (locResult.failure) {
          LocationGuardFailure.permissionDenied => t.gpsPermissionRequired,
          LocationGuardFailure.serviceDisabled => t.locationRequiredForOnline,
          LocationGuardFailure.outsideWorkZone => t.outsideWorkZoneOnline,
          _ => t.locationRequiredForOnline,
        };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.orange),
        );
        return;
      }

      if (locResult.position != null && mounted) {
        setState(() => _pos = locResult.position!);
        _map?.animateCamera(CameraUpdate.newLatLng(_pos));
      }

      final ok = await _patchStatus(token, true);
      if (!ok && mounted) {
        setState(() => _isOnline = false);
        unawaited(_stopOnlineTracking());
        return;
      }
    } catch (e) {
      debugPrint('Go online error: $e');
      if (mounted) {
        setState(() => _isOnline = false);
        unawaited(_stopOnlineTracking());
      }
    }
  }

  Future<bool> _patchStatus(String token, bool online) async {
    try {
      final res = await ResilientHttp.patch(
        Uri.parse('${Api.base}/drivers/me/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': online ? 'online' : 'offline'}),
      );

      if (res.statusCode == 200 || res.statusCode == 201) return true;

      if (mounted && online && (res.statusCode == 403 || res.statusCode == 400)) {
        final t = AppLocalizations.of(context)!;
        String msg = t.subscriptionPaymentRequired;
        try {
          final body = jsonDecode(res.body);
          final m = body['message'];
          final raw = m is List ? m.join(', ') : m?.toString() ?? msg;
          msg = localizeApiError(raw, t);
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.orange),
        );
      }
      return false;
    } catch (e) {
      debugPrint('Status patch error: $e');
      return false;
    }
  }

  Future<void> _sendLocation(String token) async {
    await _pushLocation(token, _pos.latitude, _pos.longitude);
  }

  Future<void> _logout() async {
    await _stopOnlineTracking();
    DriverSocketService.instance.disconnect();
    await context.read<AuthProvider>().logout();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final todayEarnings = context.watch<EarningProvider>().earning?.today ?? 0;

    return A11yScreen(
      label: t.home,
      child: Scaffold(
        drawer: DriverDrawer(
          onSelectTab: (i) => setState(() => _tab = i),
          onLogout: _logout,
        ),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.directions_car, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                t.appName,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: [
          DriverHomeMap(
            position: _pos,
            isOnline: _isOnline,
            toggling: _toggling,
            todayEarnings: todayEarnings,
            onMapCreated: (c) => _map = c,
            onRecenter: () =>
                _map?.animateCamera(CameraUpdate.newLatLngZoom(_pos, 17)),
            onToggleOnline: _toggle,
          ),
          const TripsPage(),
          const EarningsPage(),
          const AccountScreen(),
        ][_tab],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _tab,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          onTap: (i) => setState(() => _tab = i),
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.map), label: t.home),
            BottomNavigationBarItem(
              icon: const Icon(Icons.history),
              label: t.trips,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.monetization_on),
              label: t.earnings,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: t.account,
            ),
          ],
        ),
      ),
    );
  }
}
