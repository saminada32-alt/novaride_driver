import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/services/directions_service.dart';
import '../../../../../core/services/route_navigation_service.dart';
import '../../../../../core/services/socket_service.dart';
import '../../../../../core/utils/currency_utils.dart';
import '../../../../../core/utils/map_icons.dart';
import '../../../../../core/widgets/fare_with_promo.dart';
import '../../../../../l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../model/ride_model.dart';
import '../service/rides_service.dart';
import '../../../chat/ride_chat_screen.dart';

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
  BitmapDescriptor? _carIcon;
  double _driverBearing = 0;
  StreamSubscription<LocationData>? _locSub;
  late AnimationController _btnCtrl;
  late Animation<double> _btnScale;

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

  LatLng get _routeDestination =>
      _navigatingToDropoff ? _dropoff : _pickup;

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
      if (switchedToTrip) _routeCoords = [];
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

  Future<void> _openInMaps() async {
    final t = AppLocalizations.of(context)!;
    final pickup = LatLng(_ride.pickupLat, _ride.pickupLng);
    final dropoff = LatLng(_ride.dropoffLat, _ride.dropoffLng);
    final dest = _navigatingToDropoff ? dropoff : pickup;
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${dest.latitude},${dest.longitude}'
      '&travelmode=driving',
    );
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
      if (toDropoff && _validCoord(_dropoff.latitude, _dropoff.longitude))
        Marker(
          markerId: const MarkerId('dropoff'),
          position: _dropoff,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Dropoff'),
        ),
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
                      _paymentOption(
                        Icons.money_rounded,
                        t.cash,
                        Colors.green,
                        payMethod == 'cash',
                        () => setDialogState(() => payMethod = 'cash'),
                      ),
                      const SizedBox(width: 8),
                      _paymentOption(
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
  // STATUS COLORS
  // ─────────────────────────────────────────────────────────────
  Color get _statusColor {
    switch (_ride.status) {
      case DriverRideStatus.driver_assigned:
        return Colors.blue;
      case DriverRideStatus.driver_arrived:
        return Colors.green;
      case DriverRideStatus.passenger_onboard:
        return Colors.teal;
      case DriverRideStatus.trip_started:
        return const Color(0xFF1a1a2e);
      default:
        return Colors.grey;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final passenger = _ride.passenger;
    final name =
        '${passenger?['firstName'] ?? ''} ${passenger?['lastName'] ?? ''}'
            .trim();
    final hasNext = _ride.nextStatus != null;

    return Scaffold(
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

          // ─── Compact top status chip ──────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(16),
              color: _statusColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    _statusIcon(),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _statusTitle(t),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Ride #${_ride.id}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(.75),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FareWithPromo(
                      ride: _ride,
                      compact: true,
                      alignment: CrossAxisAlignment.end,
                      fareStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Recenter ─────────────────────────────────────────
          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).size.height * 0.48,
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
              ],
            ),
          ),

          // ─── Bottom Sheet ─────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 4),
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Column(
                        children: [
                          // Passenger info
                          if (passenger != null)
                            Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    size: 28,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name.isNotEmpty ? name : t.ridePassengerLabel,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star_rounded,
                                            color: Colors.amber,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '5.0',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Call
                                _actionBtn(
                                  Icons.call_rounded,
                                  Colors.green,
                                  _callPassenger,
                                ),
                                const SizedBox(width: 8),
                                // Message
                                _actionBtn(
                                  Icons.chat_bubble_outline_rounded,
                                  Colors.blue,
                                  _messagePassenger,
                                ),
                              ],
                            ),

                          const SizedBox(height: 16),

                          // Route
                          _routeRow(
                            Colors.green,
                            Icons.radio_button_checked_rounded,
                            t.ridePickupLabel,
                            //'Lat: ${_ride.pickupLat.toStringAsFixed(4)}',
                            _ride.pickupAddress ??
                                '${_ride.pickupLat.toStringAsFixed(4)}, ${_ride.pickupLng.toStringAsFixed(4)}',
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 11),
                            width: 2,
                            height: 20,
                            color: Colors.grey.shade300,
                          ),
                          _routeRow(
                            Colors.red,
                            Icons.location_on_rounded,
                            t.rideDropoffLabel,
                            //'Lat: ${_ride.dropoffLat.toStringAsFixed(4)}',
                            _ride.dropoffAddress ??
                                '${_ride.dropoffLat.toStringAsFixed(4)}, ${_ride.dropoffLng.toStringAsFixed(4)}',
                          ),

                          const SizedBox(height: 16),

                          // Info chips
                          Row(
                            children: [
                              _chip(
                                Icons.straighten_rounded,
                                '${_ride.estimatedDistanceKm?.toStringAsFixed(1) ?? '-'} km',
                                Colors.orange,
                              ),
                              const SizedBox(width: 10),
                              if (_ride.etaMinutes != null)
                                _chip(
                                  Icons.schedule_rounded,
                                  '${_ride.etaMinutes} min',
                                  Colors.blue,
                                ),
                              const SizedBox(width: 10),
                              _chip(
                                Icons.attach_money_rounded,
                                CurrencyUtils.formatSyp(_ride.estimatedFare),
                                Colors.green,
                              ),
                            ],
                          ),
                          if (_ride.hasPromoDiscount) ...[
                            const SizedBox(height: 8),
                            Text(
                              '${_ride.promoCode} · −${CurrencyUtils.formatSyp(_ride.discountAmount)}',
                              style: const TextStyle(
                                color: Color(0xFF4ade80),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),

                          // Main Action Button
                          if (hasNext)
                            ScaleTransition(
                              scale: _btnScale,
                              child: GestureDetector(
                                onTap: _updating ? null : _updateStatus,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: 58,
                                  decoration: BoxDecoration(
                                    color: _updating
                                        ? Colors.grey.shade400
                                        : _statusColor,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _statusColor.withOpacity(.35),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: _updating
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons
                                                    .arrow_circle_right_rounded,
                                                color: Colors.white,
                                                size: 22,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                _nextButtonLabel(t),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 12),

                          // Cancel (فقط قبل البداية)
                          if (_ride.status == DriverRideStatus.driver_assigned)
                            TextButton(
                              onPressed: _updating
                                  ? null
                                  : () async {
                                      final ok = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: Text(t.rideCancelTitle),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: Text(t.no),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: Text(
                                                t.yes,
                                                style: const TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (ok != true) return;
                                      await DriverRidesService.instance
                                          .cancelRide(_ride.id);
                                      if (mounted) Navigator.pop(context);
                                    },
                              child: Text(
                                t.rideCancelRide,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),

                          SizedBox(
                            height: MediaQuery.of(context).padding.bottom + 8,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // UI HELPERS
  // ─────────────────────────────────────────────────────────────

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      );

  Widget _routeRow(Color c, IconData icon, String title, String sub) => Row(
    children: [
      Icon(icon, color: c, size: 22),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            Text(sub, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          ],
        ),
      ),
    ],
  );

  Widget _chip(IconData icon, String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(.08),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );

  Widget _statusIcon() {
    switch (_ride.status) {
      case DriverRideStatus.driver_assigned:
        return const Icon(
          Icons.directions_car_rounded,
          color: Colors.white,
          size: 20,
        );
      case DriverRideStatus.driver_arrived:
        return const Icon(
          Icons.location_on_rounded,
          color: Colors.white,
          size: 20,
        );
      case DriverRideStatus.passenger_onboard:
        return const Icon(
          Icons.airline_seat_recline_normal_rounded,
          color: Colors.white,
          size: 20,
        );
      case DriverRideStatus.trip_started:
        return const Icon(
          Icons.navigation_rounded,
          color: Colors.white,
          size: 20,
        );
      default:
        return const Icon(Icons.info_rounded, color: Colors.white, size: 20);
    }
  }

  String _statusTitle(AppLocalizations t) {
    switch (_ride.status) {
      case DriverRideStatus.driver_assigned:
        return t.rideHeadToPickup;
      case DriverRideStatus.driver_arrived:
        return t.rideWaitingPassenger;
      case DriverRideStatus.passenger_onboard:
        return t.ridePassengerOnBoard;
      case DriverRideStatus.trip_started:
        return t.rideInProgress;
      default:
        return _ride.status.name.replaceAll('_', ' ');
    }
  }

  String _nextButtonLabel(AppLocalizations t) {
    switch (_ride.status) {
      case DriverRideStatus.driver_assigned:
        return t.rideBtnArrived;
      case DriverRideStatus.driver_arrived:
        return t.rideBtnPassengerOnBoard;
      case DriverRideStatus.passenger_onboard:
        return t.rideBtnStartTrip;
      case DriverRideStatus.trip_started:
        return t.rideBtnCompleteTrip;
      default:
        return '';
    }
  }

  Widget _paymentOption(
    IconData icon,
    String label,
    Color color,
    bool selected,
    VoidCallback onTap,
  ) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: selected ? Border.all(color: color, width: 2) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? color : Colors.grey, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected ? color : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
