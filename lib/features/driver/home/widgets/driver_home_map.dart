import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/a11y.dart';
import '../../../../l10n/app_localizations.dart';
import '../../incentives/incentives_home_banner.dart';

class DriverHomeMap extends StatelessWidget {
  final LatLng position;
  final bool isOnline;
  final bool toggling;
  final double todayEarnings;
  final void Function(GoogleMapController) onMapCreated;
  final VoidCallback onRecenter;
  final VoidCallback onToggleOnline;

  const DriverHomeMap({
    super.key,
    required this.position,
    required this.isOnline,
    required this.toggling,
    required this.todayEarnings,
    required this.onMapCreated,
    required this.onRecenter,
    required this.onToggleOnline,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: position, zoom: 15),
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: onMapCreated,
        ),
        Positioned(
          top: 20,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'driver_recenter',
            mini: true,
            backgroundColor: Colors.white,
            onPressed: onRecenter,
            child: const Icon(Icons.my_location, color: Colors.green),
          ),
        ),
        Positioned(
          top: 20,
          left: 16,
          child: A11yLiveStatus(
            message: isOnline ? t.onlineStatus : t.offlineStatus,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isOnline ? Colors.green : Colors.red,
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
                isOnline ? t.onlineStatus : t.offlineStatus,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        if (todayEarnings > 0)
          Positioned(
            top: 68,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8),
                ],
              ),
              child: Text(
                t.todayEarningsBar(CurrencyUtils.formatSyp(todayEarnings)),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a1a2e),
                ),
              ),
            ),
          ),
        if (isOnline)
          Positioned(
            top: todayEarnings > 0 ? 116 : 68,
            left: 16,
            right: 16,
            child: const IncentivesHomeBanner(),
          ),
        Positioned(
          bottom: 30,
          left: 20,
          right: 20,
          child: A11yButton(
            label: isOnline ? t.goOffline : t.goOnline,
            enabled: !toggling,
            child: GestureDetector(
              onTap: toggling ? null : onToggleOnline,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isOnline
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
                  child: toggling
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isOnline ? t.goOffline : t.goOnline,
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
        ),
      ],
    );
  }
}
