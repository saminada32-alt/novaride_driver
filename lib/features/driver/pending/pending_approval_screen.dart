import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/auth/welcome/welcome_screen.dart';
import '../home/home_screen.dart';

class PendingApprovalScreen extends StatefulWidget {
  const PendingApprovalScreen({super.key});
  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen> {
  Timer? _timer;
  bool _checking = false;
  GoogleMapController? _mapCtrl;
  LatLng _pos = const LatLng(33.5138, 36.2765);
  final Location _loc = Location();
  bool _rejected = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
    // فحص كل 30 ثانية تلقائياً
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _check());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    final p = await _loc.requestPermission();
    if (p != PermissionStatus.granted) return;
    _loc.onLocationChanged.listen((l) {
      if (l.latitude != null && l.longitude != null && mounted) {
        setState(() => _pos = LatLng(l.latitude!, l.longitude!));
        _mapCtrl?.animateCamera(CameraUpdate.newLatLng(_pos));
      }
    });
  }

  Future<void> _check() async {
    if (_checking || !mounted) return;
    setState(() => _checking = true);

    final status = await context.read<AuthProvider>().checkDriverStatus();
    if (!mounted) return;

    setState(() => _checking = false);

    switch (status) {
      case DriverStatus.approved:
        _timer?.cancel();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DriverHomeScreen()),
          (_) => false,
        );
        break;
      case DriverStatus.rejected:
        setState(() => _rejected = true);
        // انتظر 3 ثوان وبعدين سجّل خروج
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) _logout();
        break;
      default:
        break;
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
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          children: [
            // ─── الخريطة (الوحيدة الشغالة) ───────────────────
            GoogleMap(
              initialCameraPosition: CameraPosition(target: _pos, zoom: 15),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: (c) => _mapCtrl = c,
            ),

            // ─── زر إعادة التمركز ─────────────────────────────
            Positioned(
              top: 60,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'recenter',
                mini: true,
                backgroundColor: Colors.white,
                onPressed: () => _mapCtrl?.animateCamera(
                  CameraUpdate.newLatLngZoom(_pos, 17),
                ),
                child: const Icon(Icons.my_location, color: Colors.green),
              ),
            ),

            // ─── Overlay علوي: اسم التطبيق ────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 12,
                  bottom: 14,
                  left: 20,
                  right: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.directions_car,
                      color: Colors.green,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'NovaRide',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    if (_checking)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.green,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ─── Card سفلي: حالة الانتظار ──────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
                ),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
                child: _rejected ? _buildRejected(isAr) : _buildPending(isAr),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPending(bool isAr) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Handle
      Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      const SizedBox(height: 20),

      // Status Icon
      Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.hourglass_top_rounded,
          color: Colors.orange,
          size: 36,
        ),
      ),
      const SizedBox(height: 16),

      Text(
        isAr ? 'في انتظار الموافقة' : 'Awaiting Approval',
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Text(
        isAr
            ? 'حسابك قيد المراجعة من قبل فريقنا.\nسيتم إشعارك فور الموافقة وتفعيل التطبيق.'
            : 'Your account is under review.\nYou\'ll be notified once approved and the app is activated.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey[600], height: 1.6, fontSize: 13),
      ),
      const SizedBox(height: 20),

      // Auto check info
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.green.withOpacity(.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.autorenew, color: Colors.green, size: 16),
            const SizedBox(width: 8),
            Text(
              isAr
                  ? 'يتم التحقق تلقائياً كل 30 ثانية'
                  : 'Auto-checking every 30 seconds',
              style: const TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 14),

      // Manual check
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _checking ? null : _check,
          icon: _checking
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.refresh, color: Colors.white),
          label: Text(
            _checking
                ? (isAr ? 'جاري الفحص...' : 'Checking...')
                : (isAr ? 'فحص الحالة الآن' : 'Check Status Now'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),

      const SizedBox(height: 10),

      // Logout
      TextButton(
        onPressed: _logout,
        child: Text(
          isAr ? 'تسجيل الخروج' : 'Sign Out',
          style: TextStyle(color: Colors.grey[500], fontSize: 13),
        ),
      ),
    ],
  );

  Widget _buildRejected(bool isAr) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      const SizedBox(height: 20),

      Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.cancel_outlined, color: Colors.red, size: 36),
      ),
      const SizedBox(height: 16),

      Text(
        isAr ? 'تم رفض طلبك' : 'Application Rejected',
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Text(
        isAr
            ? 'نأسف، تم رفض طلبك.\nسيتم تسجيل خروجك تلقائياً.'
            : 'Sorry, your application was rejected.\nYou will be logged out automatically.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey[600], height: 1.6, fontSize: 13),
      ),
      const SizedBox(height: 20),

      const CircularProgressIndicator(color: Colors.red),
      const SizedBox(height: 10),
      Text(
        isAr ? 'جاري تسجيل الخروج...' : 'Logging out...',
        style: TextStyle(color: Colors.grey[500]),
      ),
    ],
  );
}
