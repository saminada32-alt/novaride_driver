import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/services/directions_service.dart';
import '../../../../../core/services/route_navigation_service.dart';
import '../../../../../core/services/socket_service.dart';
import '../../../../../core/utils/map_icons.dart';
import '../../../../../core/widgets/a11y.dart';
import '../../../../../core/widgets/fare_with_promo.dart';
import '../../../../../l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../model/ride_model.dart';
import '../service/rides_service.dart';
import '../../../chat/ride_chat_screen.dart';
import '../../../../../core/services/ride_safety_service.dart';
import 'active_ride_ui.dart';
import 'active_ride_bottom_sheet.dart';

class ActiveRideScreen extends StatefulWidget {
  final DriverRideModel initialRide;
  final LatLng? initialDriverPosition;

  const ActiveRideScreen({
    super.key,
    required this.initialRide,
    this.initialDriverPosition,
  });
  @override
  State<ActiveRideScreen> createState() => _ActiveRideScreenState();
}

class _ActiveRideScreenState extends State<ActiveRideScreen>
    with TickerProviderStateMixin {
  late DriverRideModel _ride;
  bool _updating = false;
  Timer? _pollTimer;
  GoogleMapController? _mapCtrl;

  final Location _location = Location();
  LatLng? _driverPos;

  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  List<LatLng> _routeCoords = [];
  Timer? _directionsTimer;
  DriverRideStatus? _lastCameraPhase;
  bool _fetchingDirections = false;
  bool _voiceNavEnabled = false;
  bool _sosSending = false;
  bool _audioRecording = false;
  int _legIndex = 0;
  final Set<int> _arrivedStops = {};
  bool _stopApiBusy = false;
  BitmapDescriptor? _carIcon;
  double _driverBearing = 0;
  StreamSubscription<LocationData>? _locSub;
  late AnimationController _btnCtrl;
  late Animation<double> _btnScale;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _ride = widget.initialRide;
    _lastCameraPhase = _ride.status;
    _driverPos = widget.initialDriverPosition;

    _btnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _btnScale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _btnCtrl, curve: Curves.easeIn));

    _loadMapIcons();
    DriverSocketService.instance.joinTrip(_ride.id);
    _setupSocketListeners();
    _startLocationTracking();
    _startPolling();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncOverlays();
      _scheduleDirectionsFetch(immediate: true);
    });
  }

  // ─────────────────────────────────────────────────────────────
  // SOCKET LISTENERS
  // ─────────────────────────────────────────────────────────────
  void _setupSocketListeners() {
    DriverSocketService.instance.onTripEvent = (data) {
      if (!mounted) return;

      final event = data['event']?.toString() ?? '';
      final statusRaw = data['status']?.toString() ?? '';

      if (event == 'ride_cancelled' ||
          statusRaw.toUpperCase() == 'CANCELLED') {
        _pollTimer?.cancel();
        final t = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.rideCancelledByPassenger),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context);
      }
    };
  }

  bool get _navigatingToDropoff =>
      _ride.status == DriverRideStatus.trip_started;

  bool _validCoord(double lat, double lng) =>
      lat.abs() > 0.01 && lng.abs() > 0.01;

  LatLng get _pickup => LatLng(_ride.pickupLat, _ride.pickupLng);
  LatLng get _dropoff => LatLng(_ride.dropoffLat, _ride.dropoffLng);

  List<LatLng> get _tripLegDestinations => [
        ..._ride.waypoints.map((w) => LatLng(w.lat, w.lng)),
        _dropoff,
      ];

  LatLng get _routeDestination {
    if (!_navigatingToDropoff) return _pickup;
    if (_ride.waypoints.isEmpty) return _dropoff;
    final legs = _tripLegDestinations;
    final idx = _legIndex.clamp(0, legs.length - 1);
    return legs[idx];
  }

  String? get _currentLegLabel {
    if (!_navigatingToDropoff || _ride.waypoints.isEmpty) return null;
    if (_legIndex < _ride.waypoints.length) {
      return _ride.waypoints[_legIndex].address;
    }
    return _ride.dropoffAddress;
  }

  double _distanceMeters(LatLng a, LatLng b) {
    const r = 6371000.0;
    final dLat = _toRad(b.latitude - a.latitude);
    final dLng = _toRad(b.longitude - a.longitude);
    final x = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(a.latitude)) *
            math.cos(_toRad(b.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return r * 2 * math.atan2(math.sqrt(x), math.sqrt(1 - x));
  }

  double _toRad(double d) => d * math.pi / 180;

  void _maybeAdvanceLeg(LatLng driverPos) {
    if (!_navigatingToDropoff || !_ride.hasMultiStop || _stopApiBusy) return;
    final legs = _tripLegDestinations;
    if (_legIndex >= legs.length - 1) return;
    final dist = _distanceMeters(driverPos, legs[_legIndex]);

    if (dist <= 200 && !_arrivedStops.contains(_legIndex)) {
      _arrivedStops.add(_legIndex);
      _stopApiBusy = true;
      DriverRidesService.instance
          .arriveAtStop(_ride.id, _legIndex)
          .then((updated) {
        if (mounted) _applyRideUpdate(updated);
      }).catchError((_) {}).whenComplete(() => _stopApiBusy = false);
    }

    if (dist > 45) return;

    _stopApiBusy = true;
    DriverRidesService.instance
        .completeStop(_ride.id, _legIndex)
        .then((updated) {
      if (!mounted) return;
      _applyRideUpdate(updated);
      setState(() => _legIndex++);
      _scheduleDirectionsFetch(immediate: true);
      final t = AppLocalizations.of(context)!;
      announceForAccessibility(context, t.multiStopReached);
    }).catchError((_) {
      if (!mounted) return;
      setState(() => _legIndex++);
      _scheduleDirectionsFetch(immediate: true);
    }).whenComplete(() => _stopApiBusy = false);
  }

  Future<void> _loadMapIcons() async {
    try {
      final icon = await MapIcons.car();
      if (mounted) {
        setState(() => _carIcon = icon);
        _syncOverlays();
      }
    } catch (_) {}
  }

  void _applyRideUpdate(DriverRideModel updated, {bool forceCamera = false}) {
    final phaseChanged = _lastCameraPhase != updated.status;
    final switchedToTrip = updated.status == DriverRideStatus.trip_started &&
        _lastCameraPhase != DriverRideStatus.trip_started;

    setState(() {
      _ride = updated;
      _lastCameraPhase = updated.status;
      if (switchedToTrip) {
        _routeCoords = [];
        _legIndex = 0;
      }
    });

    _syncOverlays();
    if (phaseChanged || forceCamera) {
      _focusMapForCurrentPhase();
    }
    _scheduleDirectionsFetch(immediate: phaseChanged || forceCamera);
  }

  void _scheduleDirectionsFetch({bool immediate = false}) {
    _directionsTimer?.cancel();
    _directionsTimer = Timer(
      immediate ? Duration.zero : const Duration(seconds: 2),
      _fetchDirections,
    );
  }

  Future<void> _fetchDirections() async {
    if (_fetchingDirections || !mounted) return;
    if (_driverPos == null) {
      _scheduleDirectionsFetch();
      return;
    }
    if (!_validCoord(_routeDestination.latitude, _routeDestination.longitude)) {
      return;
    }

    _fetchingDirections = true;
    try {
      List<LatLng> points;
      if (_voiceNavEnabled) {
        points = await RouteNavigationService.instance.loadRouteWithVoice(
          _driverPos!,
          _routeDestination,
        );
        if (points.length < 2) {
          points = await DirectionsService.instance.routeBetween(
            _driverPos!,
            _routeDestination,
          );
        }
      } else {
        points = await DirectionsService.instance.routeBetween(
          _driverPos!,
          _routeDestination,
        );
      }
      if (!mounted) return;
      setState(() => _routeCoords = points);
      _syncOverlays();
    } finally {
      _fetchingDirections = false;
    }
  }

  Future<void> _toggleVoiceNav() async {
    final next = !_voiceNavEnabled;
    await RouteNavigationService.instance.setEnabled(next);
    setState(() => _voiceNavEnabled = next);
    _scheduleDirectionsFetch(immediate: true);
    if (!mounted) return;
    final t = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(next ? t.voiceNavOn : t.voiceNavOff)),
    );
  }

  String? _normalizedPhone(String? raw) {
    if (raw == null) return null;
    final digits = raw.replaceAll(RegExp(r'[^\d+]'), '');
    if (digits.isEmpty) return null;
    if (digits.startsWith('+')) return digits;
    if (digits.startsWith('0')) return '+963${digits.substring(1)}';
    return '+$digits';
  }

  Future<void> _callPassenger() async {
    final t = AppLocalizations.of(context)!;
    final phone = _normalizedPhone(_ride.passengerPhone);
    if (phone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.rideNoPassengerPhone)),
      );
      return;
    }
    final ok = await launchUrl(
      Uri.parse('tel:$phone'),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.rideCallFailed)),
      );
    }
  }

  Future<void> _messagePassenger() async {
    final t = AppLocalizations.of(context)!;
    final name = [
      _ride.passenger?['firstName'],
      _ride.passenger?['lastName'],
    ].where((e) => e != null && e.toString().isNotEmpty).join(' ');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DriverRideChatScreen(
          mode: DriverChatMode.ride,
          rideId: _ride.id,
          title: name.isNotEmpty ? name : t.ridePassengerLabel,
        ),
      ),
    );
  }

  Future<void> _triggerSos() async {
    if (_sosSending) return;
    final t = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.sosButton),
        content: Text(t.sosConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              t.sosButton,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _sosSending = true);
    HapticFeedback.heavyImpact();
    final pos = await DriverRideSafetyService.instance.currentPosition();
    final ok = await DriverRideSafetyService.instance.triggerSos(
      _ride.id,
      lat: pos?.latitude ?? _driverPos?.latitude,
      lng: pos?.longitude ?? _driverPos?.longitude,
    );
    if (!mounted) return;
    setState(() => _sosSending = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? t.sosActivated : t.complaintError),
        backgroundColor: ok ? Colors.red.shade700 : Colors.grey.shade800,
      ),
    );
  }

  Future<void> _openInMaps() async {
    final t = AppLocalizations.of(context)!;
    final pickup = LatLng(_ride.pickupLat, _ride.pickupLng);
    final dropoff = LatLng(_ride.dropoffLat, _ride.dropoffLng);
    final dest = _routeDestination;
    var uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${dest.latitude},${dest.longitude}'
      '&travelmode=driving',
    );
    if (_navigatingToDropoff && _ride.hasMultiStop) {
      final remaining = _tripLegDestinations.sublist(_legIndex);
      if (remaining.length > 1) {
        final waypoints = remaining
            .sublist(0, remaining.length - 1)
            .map((p) => '${p.latitude},${p.longitude}')
            .join('|');
        final finalDest = remaining.last;
        uri = Uri.parse(
          'https://www.google.com/maps/dir/?api=1'
          '&destination=${finalDest.latitude},${finalDest.longitude}'
          '&waypoints=$waypoints'
          '&travelmode=driving',
        );
      }
    } else if (!_navigatingToDropoff) {
      uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1'
        '&destination=${pickup.latitude},${pickup.longitude}'
        '&travelmode=driving',
      );
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.rideCallFailed)),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────
  // LOCATION TRACKING
  // ─────────────────────────────────────────────────────────────
  void _startLocationTracking() async {
    var serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    final perm = await _location.requestPermission();
    if (perm != PermissionStatus.granted &&
        perm != PermissionStatus.grantedLimited) {
      return;
    }

    if (_driverPos == null) {
      await _refreshDriverPosition();
    } else {
      _syncOverlays();
      _scheduleDirectionsFetch(immediate: true);
    }

    _locSub?.cancel();
    _locSub = _location.onLocationChanged.listen((l) {
      if (!mounted || l.latitude == null || l.longitude == null) return;
      _onDriverPosition(LatLng(l.latitude!, l.longitude!));
    });
  }

  Future<void> _refreshDriverPosition() async {
    try {
      final l = await _location.getLocation();
      if (l.latitude == null || l.longitude == null) return;
      _onDriverPosition(
        LatLng(l.latitude!, l.longitude!),
        initial: true,
      );
    } catch (e) {
      debugPrint('GPS error: $e');
    }
  }

  void _onDriverPosition(LatLng next, {bool initial = false}) {
    if (!mounted) return;
    if (_driverPos != null) {
      _driverBearing = MapIcons.bearing(_driverPos!, next);
    }
    setState(() => _driverPos = next);
    RouteNavigationService.instance.onDriverPosition(next);
    _maybeAdvanceLeg(next);
    _syncOverlays();
    _scheduleDirectionsFetch(immediate: initial);
    DriverSocketService.instance.sendLocation(next.latitude, next.longitude);
    if (initial) _focusMapForCurrentPhase();
  }

  // ─────────────────────────────────────────────────────────────
  // POLLING
  // ─────────────────────────────────────────────────────────────
  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      if (!mounted) return;

      final rides = await DriverRidesService.instance.getMyRides();
      final updated = rides.where((r) => r.id == _ride.id).toList();

      if (updated.isNotEmpty && mounted) {
        _applyRideUpdate(updated.first);
      }
    });
  }

  // ─────────────────────────────────────────────────────────────
  // ROUTE DRAWING
  // ─────────────────────────────────────────────────────────────

  void _syncOverlays() {
    if (!mounted) return;

    final toDropoff = _navigatingToDropoff;
    final dest = _routeDestination;
    final carIcon = _carIcon ??
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);

    final markers = <Marker>{
      if (!toDropoff && _validCoord(_pickup.latitude, _pickup.longitude))
        Marker(
          markerId: const MarkerId('pickup'),
          position: _pickup,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: 'Pickup'),
        ),
      if (toDropoff) ...[
        for (var i = 0; i < _ride.waypoints.length; i++)
          if (_validCoord(_ride.waypoints[i].lat, _ride.waypoints[i].lng))
            Marker(
              markerId: MarkerId('stop_$i'),
              position: LatLng(_ride.waypoints[i].lat, _ride.waypoints[i].lng),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                i == _legIndex && _ride.hasMultiStop
                    ? BitmapDescriptor.hueOrange
                    : BitmapDescriptor.hueYellow,
              ),
              infoWindow: InfoWindow(title: 'Stop ${i + 1}'),
            ),
        if (_validCoord(_dropoff.latitude, _dropoff.longitude))
          Marker(
            markerId: const MarkerId('dropoff'),
            position: _dropoff,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: const InfoWindow(title: 'Dropoff'),
          ),
      ],
      if (_driverPos != null)
        Marker(
          markerId: const MarkerId('driver'),
          position: _driverPos!,
          icon: carIcon,
          anchor: const Offset(0.5, 0.5),
          flat: true,
          rotation: _driverBearing,
          zIndex: 3,
        ),
    };

    List<LatLng> routePoints = [];
    if (_routeCoords.length >= 2) {
      routePoints = _routeCoords;
    } else if (_driverPos != null &&
        _validCoord(dest.latitude, dest.longitude)) {
      routePoints = [_driverPos!, dest];
    }

    final polys = routePoints.length >= 2
        ? {
            Polyline(
              polylineId: PolylineId(
                toDropoff ? 'route_dropoff' : 'route_pickup',
              ),
              points: routePoints,
              color: const Color(0xFF4285F4),
              width: 8,
              geodesic: true,
              jointType: JointType.round,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
            ),
          }
        : <Polyline>{};

    setState(() {
      _markers = markers;
      _polylines = polys;
    });
  }

  LatLngBounds _boundsFor(Iterable<LatLng> points) {
    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;

    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  Future<void> _focusMapForCurrentPhase() async {
    if (_mapCtrl == null) return;

    final pickup = LatLng(_ride.pickupLat, _ride.pickupLng);
    final dropoff = LatLng(_ride.dropoffLat, _ride.dropoffLng);

    try {
      if (_navigatingToDropoff) {
        if (_driverPos != null) {
          await _mapCtrl!.animateCamera(
            CameraUpdate.newLatLngBounds(
              _boundsFor([_driverPos!, dropoff]),
              120,
            ),
          );
        } else {
          await _mapCtrl!.animateCamera(
            CameraUpdate.newLatLngZoom(dropoff, 16),
          );
        }
        return;
      }

      if (_driverPos != null) {
        await _mapCtrl!.animateCamera(
          CameraUpdate.newLatLngBounds(
            _boundsFor([_driverPos!, pickup]),
            120,
          ),
        );
      } else {
        await _mapCtrl!.animateCamera(
          CameraUpdate.newLatLngZoom(pickup, 15),
        );
      }
    } catch (_) {
      await _mapCtrl!.animateCamera(CameraUpdate.newLatLngZoom(pickup, 14));
    }
  }

  void _onMapCreated(GoogleMapController c) {
    _mapCtrl = c;
    _syncOverlays();
    _focusMapForCurrentPhase();
    if (_driverPos == null) {
      _refreshDriverPosition();
    }
    _scheduleDirectionsFetch(immediate: true);
  }

  void _recenter() {
    _focusMapForCurrentPhase();
  }

  // ─────────────────────────────────────────────────────────────
  // DISPOSE
  // ─────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _btnCtrl.dispose();
    _sheetController.dispose();
    _pollTimer?.cancel();
    _directionsTimer?.cancel();
    _locSub?.cancel();

    // تنظيف WebSocket
    DriverSocketService.instance.leaveTrip(_ride.id);
    DriverSocketService.instance.onTripEvent = null;
    RouteNavigationService.instance.setEnabled(false);

    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // UPDATE STATUS
  // ─────────────────────────────────────────────────────────────
  Future<void> _updateStatus() async {
    final next = _ride.nextStatus;
    if (next == null || _updating) return;

    HapticFeedback.mediumImpact();
    await _btnCtrl.forward();
    await _btnCtrl.reverse();

    setState(() => _updating = true);

    try {
      final updated = await DriverRidesService.instance.updateStatus(
        _ride.id,
        next,
      );

      if (!mounted) return;

      final wasStartTrip =
          _ride.status == DriverRideStatus.passenger_onboard &&
          updated.status == DriverRideStatus.trip_started;

      _applyRideUpdate(updated, forceCamera: wasStartTrip);

      if (wasStartTrip && mounted) {
        final t = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.rideNavigatingToDropoff),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      if (updated.status == DriverRideStatus.completed) {
        _pollTimer?.cancel();
        _showCompleted();
      }
    } catch (e) {
      // Status may have saved on server despite side-effect errors
      try {
        final rides = await DriverRidesService.instance.getMyRides();
        final done = rides.where(
          (r) =>
              r.id == _ride.id &&
              r.status == DriverRideStatus.completed,
        );
        if (done.isNotEmpty && mounted) {
          _applyRideUpdate(done.first);
          _pollTimer?.cancel();
          _showCompleted();
          return;
        }
      } catch (_) {}

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // COMPLETED DIALOG
  // ─────────────────────────────────────────────────────────────

  void _showCompleted() {
    final t = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        var payMethod = _ride.paymentMethod ?? 'cash';
        var saving = false;
        var passengerRating = 5.0;
        final refCtrl = TextEditingController(
          text: _ride.paymentReference ?? '',
        );
        final showRating = _ride.driverRating == null;

        return StatefulBuilder(
          builder: (ctx, setDialogState) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.green,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    t.rideCompletedTitle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_ride.estimatedFare != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          FareWithPromo(
                            ride: _ride,
                            fareStyle: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_ride.estimatedDistanceKm?.toStringAsFixed(1)} ${t.km}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (showRating) ...[
                    Text(
                      t.rateYourPassenger,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.howWasPassenger,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final filled = i < passengerRating.round();
                        return IconButton(
                          onPressed: saving
                              ? null
                              : () => setDialogState(
                                    () => passengerRating = (i + 1).toDouble(),
                                  ),
                          icon: Icon(
                            filled
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: Colors.amber,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    t.ridePaymentMethod,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ActiveRideUi.paymentOption(
                        Icons.money_rounded,
                        t.cash,
                        Colors.green,
                        payMethod == 'cash',
                        () => setDialogState(() => payMethod = 'cash'),
                      ),
                      const SizedBox(width: 8),
                      ActiveRideUi.paymentOption(
                        Icons.phone_android_rounded,
                        t.shamCash,
                        Colors.blue,
                        payMethod == 'sham_cash',
                        () => setDialogState(() => payMethod = 'sham_cash'),
                      ),
                    ],
                  ),
                  if (payMethod == 'sham_cash') ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: refCtrl,
                      decoration: InputDecoration(
                        labelText: t.shamCash,
                        hintText: 'رقم مرجع التحويل',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: saving
                          ? null
                          : () async {
                              setDialogState(() => saving = true);
                              try {
                                if (showRating) {
                                  await DriverRidesService.instance.rateRide(
                                    _ride.id,
                                    passengerRating.round(),
                                  );
                                }
                                await DriverRidesService.instance
                                    .setPaymentMethod(
                                  _ride.id,
                                  payMethod,
                                  paymentReference: payMethod == 'sham_cash'
                                      ? refCtrl.text.trim()
                                      : null,
                                );
                                if (ctx.mounted) Navigator.pop(ctx);
                                if (mounted) Navigator.pop(context);
                              } catch (e) {
                                setDialogState(() => saving = false);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(e.toString()),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              t.rideDone,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────
  String _passengerRatingText(Map<String, dynamic>? passenger) {
    final raw = passenger?['rating'];
    if (raw == null) return '—';
    final value = raw is num ? raw.toDouble() : double.tryParse(raw.toString());
    if (value == null || value <= 0) return '—';
    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final passenger = _ride.passenger;
    final name =
        '${passenger?['firstName'] ?? ''} ${passenger?['lastName'] ?? ''}'
            .trim();
    final passengerRatingText = _passengerRatingText(passenger);

    return A11yScreen(
      label: '${t.rideInProgress}. Ride ${_ride.id}',
      child: Scaffold(
      body: Stack(
        children: [
          // ─── Map (full screen under overlays) ─────────────────
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(_ride.pickupLat, _ride.pickupLng),
                zoom: 14,
              ),
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: true,
              polylines: _polylines,
              markers: _markers,
            ),
          ),

          // ─── Map overlays (Uber-style) ────────────────────────
          if (_ride.estimatedDistanceKm != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 16,
              child: ActiveRideUi.mapDistanceChip(
                t.distanceKmUnit(
                  _ride.estimatedDistanceKm!.toStringAsFixed(1),
                ),
              ),
            ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 3,
              child: IconButton(
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                tooltip: t.activeRideMoreOptions,
                onPressed: () {
                  _sheetController.animateTo(
                    0.32,
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOut,
                  );
                },
              ),
            ),
          ),

          // ─── Recenter & actions ───────────────────────────────
          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).size.height * 0.58,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'voice_nav_active_ride',
                  backgroundColor:
                      _voiceNavEnabled ? Colors.green.shade700 : Colors.white,
                  tooltip: t.voiceNavToggle,
                  onPressed: _toggleVoiceNav,
                  child: Icon(
                    _voiceNavEnabled
                        ? Icons.record_voice_over
                        : Icons.volume_off_outlined,
                    color: _voiceNavEnabled ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'navigate_active_ride',
                  backgroundColor: const Color(0xFF1a1a2e),
                  tooltip: t.rideOpenInMaps,
                  onPressed: _openInMaps,
                  child: const Icon(Icons.navigation, color: Colors.white),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'recenter_active_ride',
                  backgroundColor: Colors.white,
                  onPressed: _recenter,
                  child: const Icon(Icons.my_location, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                A11yButton(
                  label: t.sosButton,
                  hint: t.sosConfirm,
                  enabled: !_sosSending,
                  child: FloatingActionButton.small(
                    heroTag: 'sos_active_ride',
                    backgroundColor: Colors.red.shade700,
                    tooltip: t.sosButton,
                    onPressed: _sosSending ? null : _triggerSos,
                    child: _sosSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.sos, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // ─── Draggable Bottom Sheet ───────────────────────────
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.56,
            minChildSize: 0.32,
            maxChildSize: 0.9,
            snap: true,
            snapSizes: const [0.32, 0.56, 0.9],
            builder: (context, scrollController) => ActiveRideBottomSheet(
              scrollController: scrollController,
              ride: _ride,
              t: t,
              passengerName: name,
              passengerRatingText: passengerRatingText,
              passenger: passenger,
              audioRecording: _audioRecording,
              updating: _updating,
              navigatingToDropoff: _navigatingToDropoff,
              legIndex: _legIndex,
              currentLegLabel: _currentLegLabel,
              btnScale: _btnScale,
              onToggleAudio: () =>
                  setState(() => _audioRecording = !_audioRecording),
              onMessage: _messagePassenger,
              onCall: _callPassenger,
              onUpdateStatus: _updateStatus,
              onShowRoute: () {
                _sheetController.animateTo(
                  0.9,
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOut,
                );
              },
              onCancelRide: () async {
                await DriverRidesService.instance.cancelRide(_ride.id);
                if (mounted) Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    ),
    );
  }
}
