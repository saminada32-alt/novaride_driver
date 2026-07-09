import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../../core/widgets/app_network_image.dart';
import 'model/vehicle_model.dart';
import 'provider/vehicle_provider.dart';
import 'edit_vehicle_screen.dart';

class VehicleInfoScreen extends StatefulWidget {
  const VehicleInfoScreen({super.key});

  @override
  State<VehicleInfoScreen> createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends State<VehicleInfoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().token;
      if (token != null) context.read<VehicleProvider>().loadVehicle(token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final provider = context.watch<VehicleProvider>();

    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        title: Text(t.vehicleInfo),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : provider.vehicle == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.directions_car_outlined,
                    size: 60,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    t.noData ?? 'No vehicle found',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── Vehicle Image / Icon ─────────────────
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _vehicleImage(provider.vehicle!),
                  ),

                  const SizedBox(height: 20),

                  // ─── Name + Badge ─────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${provider.vehicle!.brand} ${provider.vehicle!.model}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: provider.vehicle!.isVerified
                              ? Colors.green.withOpacity(.1)
                              : Colors.orange.withOpacity(.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          provider.vehicle!.isVerified ? t.verified : t.pending,
                          style: TextStyle(
                            color: provider.vehicle!.isVerified
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ─── Info Cards ────────────────────────────
                  _card([
                    _row(t.yearLabel, provider.vehicle!.year),
                    _row(t.colorLabel, provider.vehicle!.color),
                    _row(t.plateLabel, provider.vehicle!.plateNumber),
                    _row(t.car, _vehicleTypeLabel(t, provider.vehicle!.type)),
                  ]),

                  const SizedBox(height: 28),

                  // ─── Edit Button ──────────────────────────
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditVehicleScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: Text(
                      t.editVehicle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _card(List<Widget> children) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
    ),
    child: Column(children: children),
  );

  Widget _vehicleImage(VehicleModel vehicle) {
    const fallback = Icon(
      Icons.directions_car_rounded,
      size: 80,
      color: Colors.grey,
    );
    return AppNetworkImage(
      url: vehicle.imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 180,
      fallback: fallback,
    );
  }

  String _vehicleTypeLabel(AppLocalizations t, String type) {
    switch (type) {
      case 'van':
        return t.van;
      case 'motorcycle':
        return t.motorcycle;
      case 'wheelchair_accessible':
        return t.wheelchairAccessible;
      default:
        return t.car;
    }
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
