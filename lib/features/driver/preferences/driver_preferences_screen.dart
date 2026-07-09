import 'package:flutter/material.dart';
import 'package:location/location.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/api_error_messages.dart';
import '../../../core/utils/currency_utils.dart';
import 'driver_preferences_service.dart';

class DriverPreferencesScreen extends StatefulWidget {
  const DriverPreferencesScreen({super.key});

  @override
  State<DriverPreferencesScreen> createState() =>
      _DriverPreferencesScreenState();
}

class _DriverPreferencesScreenState extends State<DriverPreferencesScreen> {
  bool _loading = true;
  bool _saving = false;

  bool _destEnabled = false;
  double? _destLat;
  double? _destLng;
  double _destRadius = 5;
  String? _destAddress;

  bool _autoAccept = false;
  double _maxPickupKm = 3;
  double _minFare = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final prefs = await DriverPreferencesService.instance.getPreferences();
      final dest = prefs['destinationFilter'] as Map<String, dynamic>? ?? {};
      final auto = prefs['autoAccept'] as Map<String, dynamic>? ?? {};
      if (mounted) {
        setState(() {
          _destEnabled = dest['enabled'] == true;
          _destLat = (dest['lat'] as num?)?.toDouble();
          _destLng = (dest['lng'] as num?)?.toDouble();
          _destRadius = (dest['radiusKm'] as num?)?.toDouble() ?? 5;
          _destAddress = dest['address']?.toString();
          _autoAccept = auto['enabled'] == true;
          _maxPickupKm = (auto['maxPickupKm'] as num?)?.toDouble() ?? 3;
          _minFare = (auto['minFare'] as num?)?.toDouble() ?? 0;
        });
      }
    } catch (e) {
      if (mounted) {
        final t = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizeApiError(e.toString(), t))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _useCurrentLocation() async {
    final loc = Location();
    final perm = await loc.requestPermission();
    if (perm != PermissionStatus.granted) return;
    final data = await loc.getLocation();
    if (data.latitude == null) return;
    setState(() {
      _destLat = data.latitude;
      _destLng = data.longitude;
      _destAddress =
          '${data.latitude!.toStringAsFixed(5)}, ${data.longitude!.toStringAsFixed(5)}';
    });
  }

  Future<void> _saveDestination() async {
    setState(() => _saving = true);
    try {
      await DriverPreferencesService.instance.setDestinationFilter(
        enabled: _destEnabled,
        lat: _destEnabled ? _destLat : null,
        lng: _destEnabled ? _destLng : null,
        radiusKm: _destRadius,
        address: _destAddress,
      );
      if (!mounted) return;
      final t = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.saved), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (mounted) {
        final t = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizeApiError(e.toString(), t)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveAutoAccept() async {
    setState(() => _saving = true);
    try {
      await DriverPreferencesService.instance.setAutoAccept(
        enabled: _autoAccept,
        maxPickupKm: _maxPickupKm,
        minFare: _minFare,
      );
      if (!mounted) return;
      final t = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.saved), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (mounted) {
        final t = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizeApiError(e.toString(), t)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.preferencesTitle),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  t.destinationFilterTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t.destinationFilterDesc,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                SwitchListTile(
                  value: _destEnabled,
                  onChanged: (v) => setState(() => _destEnabled = v),
                  title: Text(t.enableFilter),
                ),
                if (_destEnabled) ...[
                  ListTile(
                    title: Text(t.destinationLabel),
                    subtitle: Text(_destAddress ?? t.notSet),
                    trailing: IconButton(
                      icon: const Icon(Icons.my_location),
                      onPressed: _useCurrentLocation,
                    ),
                  ),
                  Text(t.acceptRadiusKm(_destRadius.toStringAsFixed(1))),
                  Slider(
                    value: _destRadius,
                    min: 1,
                    max: 15,
                    divisions: 14,
                    label: _destRadius.toStringAsFixed(1),
                    onChanged: (v) => setState(() => _destRadius = v),
                  ),
                  ElevatedButton(
                    onPressed: _saving ? null : _saveDestination,
                    child: Text(t.saveFilter),
                  ),
                ],
                const Divider(height: 40),
                Text(
                  t.autoAcceptTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t.autoAcceptDesc,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                SwitchListTile(
                  value: _autoAccept,
                  onChanged: (v) => setState(() => _autoAccept = v),
                  title: Text(t.enableAutoAccept),
                ),
                if (_autoAccept) ...[
                  Text(t.maxPickupKmLabel(_maxPickupKm.toStringAsFixed(1))),
                  Slider(
                    value: _maxPickupKm,
                    min: 0.5,
                    max: 10,
                    divisions: 19,
                    onChanged: (v) => setState(() => _maxPickupKm = v),
                  ),
                  Text(
                    t.minFareLabel(
                      CurrencyUtils.formatSypCompact(_minFare),
                    ),
                  ),
                  Slider(
                    value: _minFare,
                    min: 0,
                    max: 50000,
                    divisions: 20,
                    onChanged: (v) => setState(() => _minFare = v),
                  ),
                  ElevatedButton(
                    onPressed: _saving ? null : _saveAutoAccept,
                    child: Text(t.saveAutoAccept),
                  ),
                ],
              ],
            ),
    );
  }
}
