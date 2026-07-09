import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/auth/welcome/welcome_screen.dart';
import '../navigation/driver_entry.dart';
import '../onboarding/documents/documents_screen.dart';
import '../onboarding/documents/provider/document_provider.dart';

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
  bool _loadingDocs = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _check());
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDocumentStatus());
  }

  Future<void> _loadDocumentStatus() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;
    setState(() => _loadingDocs = true);
    await context.read<DocumentsProvider>().loadRejectedFields(token);
    if (mounted) setState(() => _loadingDocs = false);
  }

  void _openResubmit() {
    final prov = context.read<DocumentsProvider>();
    if (!prov.hasRejectedFields) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DocumentsScreen(resubmitOnly: true),
      ),
    ).then((_) => _loadDocumentStatus());
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
        await DriverEntry.goAfterAuth(context);
        break;
      case DriverStatus.rejected:
        setState(() => _rejected = true);
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) _logout();
        break;
      default:
        await _loadDocumentStatus();
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
    final t = AppLocalizations.of(context)!;

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
                    Text(
                      t.appName,
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
                child: _rejected ? _buildRejected(t) : _buildPending(t),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPending(AppLocalizations t) {
    final docs = context.watch<DocumentsProvider>();
    final needsResubmit = docs.hasRejectedFields;

    return Column(
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
        needsResubmit ? t.documentsNeedResubmit : t.awaitingApproval,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Text(
        needsResubmit ? t.resubmitPendingMessage : t.pendingReviewMessage,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey[600], height: 1.6, fontSize: 13),
      ),
      if (needsResubmit) ...[
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _loadingDocs ? null : _openResubmit,
            icon: const Icon(Icons.upload_file, color: Colors.white),
            label: Text(
              t.reuploadDocuments,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
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
              t.autoChecking,
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
            _checking ? t.checking : t.checkStatusNow,
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
          t.signOut,
          style: TextStyle(color: Colors.grey[500], fontSize: 13),
        ),
      ),
    ],
  );
  }

  Widget _buildRejected(AppLocalizations t) => Column(
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
        t.applicationRejected,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Text(
        t.rejectedLogoutMessage,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey[600], height: 1.6, fontSize: 13),
      ),
      const SizedBox(height: 20),

      const CircularProgressIndicator(color: Colors.red),
      const SizedBox(height: 10),
      Text(
        t.loggingOut,
        style: TextStyle(color: Colors.grey[500]),
      ),
    ],
  );
}
