import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc_service;
import 'package:location/location.dart' show PermissionStatus;

class MapSelectionScreen extends StatefulWidget {
  const MapSelectionScreen({super.key});
  @override
  State<MapSelectionScreen> createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  GoogleMapController? _ctrl;
  LatLng? _selected;
  String? _address;
  bool _loading = false;

  // دمشق كموقع افتراضي
  static const _damascus = LatLng(33.5138, 36.2765);

  @override
  void initState() {
    super.initState();
    _goToCurrentLocation();
  }

  Future<void> _goToCurrentLocation() async {
    try {
      final loc = loc_service.Location();
      final perm = await loc.requestPermission();
      if (perm != PermissionStatus.granted) return;
      final data = await loc.getLocation();
      if (data.latitude == null || data.longitude == null) return;
      final pos = LatLng(data.latitude!, data.longitude!);
      _ctrl?.animateCamera(CameraUpdate.newLatLngZoom(pos, 14));
    } catch (_) {}
  }

  Future<void> _onTap(LatLng pos) async {
    setState(() {
      _selected = pos;
      _loading = true;
      _address = null;
    });
    try {
      final marks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      ).timeout(const Duration(seconds: 8));

      if (marks.isNotEmpty) {
        final p = marks.first;
        final parts = [
          p.street,
          p.subLocality,
          p.locality,
          p.administrativeArea,
        ].where((s) => s != null && s.isNotEmpty).toList();
        _address = parts.join(', ');
      }
    } catch (_) {
      _address =
          '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      body: Stack(
        children: [
          // ─── Map ──────────────────────────────────────────────
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _damascus,
              zoom: 12,
            ),
            onMapCreated: (c) => _ctrl = c,
            onTap: _onTap,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: _selected != null
                ? {
                    Marker(
                      markerId: const MarkerId('selected'),
                      position: _selected!,
                      infoWindow: InfoWindow(title: _address ?? '...'),
                    ),
                  }
                : {},
          ),

          // ─── AppBar ───────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 8,
                right: 16,
                bottom: 8,
              ),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    isAr ? 'اختر موقعك' : 'Select Location',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── My Location Button ────────────────────────────────
          Positioned(
            right: 16,
            bottom: 120,
            child: FloatingActionButton(
              heroTag: 'my_loc',
              mini: true,
              backgroundColor: Colors.white,
              onPressed: _goToCurrentLocation,
              child: const Icon(Icons.my_location, color: Colors.green),
            ),
          ),

          // ─── Bottom Card ───────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 16)],
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
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
                  const SizedBox(height: 16),

                  if (_selected == null) ...[
                    Row(
                      children: [
                        const Icon(Icons.touch_app, color: Colors.grey),
                        const SizedBox(width: 10),
                        Text(
                          isAr
                              ? 'اضغط على الخريطة لاختيار موقعك'
                              : 'Tap on the map to select your location',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ] else if (_loading) ...[
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Getting address...'),
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.green),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _address ?? 'Unknown location',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selected != null
                            ? Colors.black
                            : Colors.grey.shade400,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: (_selected != null && !_loading)
                          ? () => Navigator.pop(context, {
                              'lat': _selected!.latitude,
                              'lng': _selected!.longitude,
                              'address': _address ?? 'Selected Location',
                            })
                          : null,
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: Text(
                        isAr ? 'تأكيد الموقع' : 'Confirm Location',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
