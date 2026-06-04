import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;

import '../../../l10n/app_localizations.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/driver_fcm_service.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/welcome/welcome_screen.dart';
import 'account/account_screen.dart';
import 'account/provider/account_provider.dart';
import 'earnings/earning_screen.dart';
import 'earnings/provider/earning_provider.dart';
import 'rides/trips_screen.dart';
import 'rides/provider/rides_provider.dart';
import '../notifications/notifications_screen.dart';
import 'vehicle/vehicle_info_screen.dart';
import 'vehicle/provider/vehicle_provider.dart';
import 'support/support_screen.dart';
import 'rides/service/rides_service.dart';
import 'rides/model/ride_model.dart';
import 'rides/screens/active_ride_screen.dart';
import 'incoming_ride_dialog.dart';
import '../subscription/my_subscription_screen.dart';
import '../wallet/wallet_screen.dart';
import '../work_zones/work_zones_screen.dart';
import '../../../core/services/work_zones_service.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  int _tab = 0;
  bool _isOnline = false;
  bool _toggling = false;

  GoogleMapController? _map;
  LatLng _pos = const LatLng(33.5138, 36.2765);
  final _loc = Location();

  // incoming ride
  DriverRideModel? _activeRide;

  // context of the currently shown offer dialog (so we can dismiss it
  // programmatically when another driver takes the ride).
  BuildContext? _offerDialogCtx;

  // socket
  IO.Socket? _socket;

  int? _driverId;

  Timer? _locationTimer; // ← للتجريب، راح نشيلها لاحقاً

  @override
  void initState() {
    super.initState();
    final account = context.read<AccountProvider>().account;
    _driverId = account?.id is int
        ? account!.id as int
        : int.tryParse(account?.id.toString() ?? '');

    debugPrint('Driver ID = $_driverId');
    _initLoc();
    _loadAll();
    _connectSocket();
    _wireFcm();
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

  Future<void> _loadAll() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    context.read<AccountProvider>().loadAccount(token);
    context.read<EarningProvider>().loadEarnings(token);
    context.read<RidesProvider>().loadTrips();
    context.read<VehicleProvider>().loadVehicle(token);
  }

  // ───────────────────────────────────────────────
  // SOCKET.IO — استقبال الرحلات الجديدة
  // ───────────────────────────────────────────────
  void _connectSocket() {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    // ← أضيفي /tracking
    _socket = IO.io(
      '${Api.base}/tracking',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token}) // ← auth مو header
          .disableAutoConnect()
          .enableReconnection()
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('🔌 Socket connected to /tracking');
      // أبلغ الباك اند إن السائق متصل
      if (_driverId != null) {
        _socket!.emit('driver:online', {'driverId': _driverId});
      }
    });

    _socket!.on('new_ride_offer', (data) {
      debugPrint('📥 new_ride_offer: $data');
      _handleIncomingRideOffer(Map<String, dynamic>.from(data as Map));
    });

    // Another driver accepted (or the wave expired) → clear our offer card.
    _socket!.on('ride_taken', (data) {
      debugPrint('🚫 ride_taken: $data');
      final rideId = data is Map ? data['rideId'] : null;
      _handleRideTaken(rideId is int ? rideId : int.tryParse('$rideId'));
    });

    _socket!.onConnectError((e) => debugPrint('❌ Connect error: $e'));
    _socket!.onDisconnect((e) => debugPrint('❌ Disconnected'));

    _socket!.connect(); // ← connect بعد setup
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    DriverFcmService.instance.onNewRide = null;
    _socket?.dispose();
    super.dispose();
  }

  // ───────────────────────────────────────────────
  // Dialog الرحلة الواردة
  // ───────────────────────────────────────────────
  /// Clear the offer card if another driver took this ride (or it expired).
  void _handleRideTaken(int? rideId) {
    if (!mounted) return;
    // Only react if it concerns the offer we're currently showing.
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

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ActiveRideScreen(
                  initialRide: accepted,
                  initialDriverPosition: _pos,
                ),
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
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

  // ───────────────────────────────────────────────
  // Location + رفع الموقع للباك إند
  // ───────────────────────────────────────────────
  Future<void> _initLoc() async {
    final p = await _loc.requestPermission();
    if (p != PermissionStatus.granted) return;

    final token = context.read<AuthProvider>().token;

    _loc.onLocationChanged.listen((l) async {
      if (!mounted || l.latitude == null) return;

      final lat = l.latitude!;
      final lng = l.longitude!;

      setState(() => _pos = LatLng(lat, lng));
      _map?.animateCamera(CameraUpdate.newLatLng(_pos));

      // ← REST API (only while online)
      if (token != null && _isOnline) {
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
      }

      // ← WebSocket (Redis Geo for dispatch)
      if (_socket?.connected == true && _isOnline) {
        _socket!.emit('driver:location', {'lat': lat, 'lng': lng});
        debugPrint('📡 Location sent via socket: $lat, $lng');
      }
    });
  }

  Future<void> _toggle() async {
    if (_toggling) return;
    setState(() => _toggling = true);

    final newOnline = !_isOnline;
    final token = context.read<AuthProvider>().token;
    if (token == null) {
      setState(() => _toggling = false);
      return;
    }

    try {
      if (newOnline) {
        final onShift = await WorkZonesService.instance.isOnShift();
        if (!onShift && mounted) {
          final t = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.workZonesOffShiftOnline),
              backgroundColor: Colors.orange,
              action: SnackBarAction(
                label: t.workZonesTitle,
                textColor: Colors.white,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WorkZonesScreen()),
                ),
              ),
            ),
          );
          setState(() => _toggling = false);
          return;
        }
      }

      final res = await http.patch(
        Uri.parse('${Api.base}/drivers/me/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': newOnline ? 'online' : 'offline'}),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        setState(() => _isOnline = newOnline);

        if (newOnline) {
          await _sendLocation(token);
          _locationTimer?.cancel();
          _locationTimer = Timer.periodic(
            const Duration(seconds: 20),
            (_) => _sendLocation(token),
          );
          debugPrint('🟢 Online + location timer started');
        } else {
          _locationTimer?.cancel();
          _locationTimer = null;
          debugPrint('🔴 Offline + location timer stopped');
        }
      } else {
        debugPrint('Toggle failed: ${res.statusCode} ${res.body}');
        if (mounted && newOnline && (res.statusCode == 403 || res.statusCode == 400)) {
          String msg = 'Subscription payment required';
          try {
            final body = jsonDecode(res.body);
            final m = body['message'];
            msg = m is List ? m.join(', ') : m?.toString() ?? msg;
          } catch (_) {}
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: Colors.orange,
              action: SnackBarAction(
                label: 'Pay',
                textColor: Colors.white,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MySubscriptionScreen()),
                ),
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Toggle error: $e');
    }

    setState(() => _toggling = false);
  }

  // ─── دالة منفصلة لإرسال الموقع ───────────────────────────
  Future<void> _sendLocation(String token) async {
    try {
      final res = await http.patch(
        Uri.parse('${Api.base}/drivers/me/location'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'lat': _pos.latitude, 'lng': _pos.longitude}),
      );
      debugPrint(
        '📍 Location sent: ${_pos.latitude},${_pos.longitude} → ${res.statusCode}',
      );

      if (_socket?.connected == true && _isOnline) {
        _socket!.emit('driver:location', {
          'lat': _pos.latitude,
          'lng': _pos.longitude,
        });
      }
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  Future<void> _logout() async {
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

    return Scaffold(
      drawer: _drawer(context, t),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.directions_car, color: Colors.green),
            SizedBox(width: 8),
            Text(
              'NovaRide',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: [
        _buildMap(t),
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
    );
  }

  // ───────────────────────────────────────────────
  // MAP UI
  // ───────────────────────────────────────────────
  Widget _buildMap(AppLocalizations t) => Stack(
    children: [
      GoogleMap(
        initialCameraPosition: CameraPosition(target: _pos, zoom: 15),
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        onMapCreated: (c) => _map = c,
      ),
      Positioned(
        top: 20,
        right: 16,
        child: FloatingActionButton(
          heroTag: 'rc',
          mini: true,
          backgroundColor: Colors.white,
          onPressed: () =>
              _map?.animateCamera(CameraUpdate.newLatLngZoom(_pos, 17)),
          child: const Icon(Icons.my_location, color: Colors.green),
        ),
      ),
      Positioned(
        top: 20,
        left: 16,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _isOnline ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            _isOnline ? 'ONLINE' : 'OFFLINE',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 30,
        left: 20,
        right: 20,
        child: GestureDetector(
          onTap: _toggling ? null : _toggle,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isOnline
                    ? [Colors.green.shade600, Colors.green.shade800]
                    : [Colors.grey.shade500, Colors.grey.shade700],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: _toggling
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _isOnline ? t.goOffline : t.goOnline,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
            ),
          ),
        ),
      ),
    ],
  );

  // ───────────────────────────────────────────────
  // Drawer
  // ───────────────────────────────────────────────
  Widget _drawer(BuildContext ctx, AppLocalizations t) {
    final driver = ctx.watch<AccountProvider>().account;

    return Drawer(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() => _tab = 3);
              Navigator.pop(ctx);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 80, bottom: 20),
              color: Colors.green,
              child: Column(
                children: [
                  ProfileAvatar(
                    imageUrl: driver?.profileImage,
                    name: driver?.name ?? 'Driver',
                    radius: 50,
                    backgroundColor: Colors.white,
                    initialColor: Colors.green,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    driver?.name ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    driver?.phone ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          _di(Icons.notifications_outlined, t.notificationsTitle, () {
            Navigator.pop(ctx);
            Navigator.push(
              ctx,
              MaterialPageRoute(
                builder: (_) => const DriverNotificationsScreen(),
              ),
            );
          }),
          _di(Icons.history, t.trips, () {
            setState(() => _tab = 1);
            Navigator.pop(ctx);
          }),
          _di(Icons.monetization_on, t.earnings, () {
            setState(() => _tab = 2);
            Navigator.pop(ctx);
          }),
          _di(Icons.account_balance_wallet_outlined, t.walletTitle, () {
            Navigator.pop(ctx);
            Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => const DriverWalletScreen()),
            );
          }),
          _di(Icons.map_outlined, t.workZonesTitle, () {
            Navigator.pop(ctx);
            Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => const WorkZonesScreen()),
            );
          }),
          _di(Icons.directions_car, t.vehicleInfo, () {
            Navigator.pop(ctx);
            Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => const VehicleInfoScreen()),
            );
          }),

          _di(Icons.subscriptions, t.subscriptions, () {
            Navigator.pop(ctx);
            Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => const MySubscriptionScreen()),
            );
          }),

          _di(Icons.support_agent, t.support, () {
            Navigator.pop(ctx);
            Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => const SupportScreen()),
            );
          }),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              t.logout,
              style: const TextStyle(color: Colors.red),
            ),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _di(IconData icon, String label, VoidCallback onTap) =>
      ListTile(leading: Icon(icon), title: Text(label), onTap: onTap);
}
