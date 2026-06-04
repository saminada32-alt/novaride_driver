import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/providers/auth_provider.dart';
import '../application_review/application_review_screen.dart';
import 'provider/location_provider.dart';
import 'map_selection_screen.dart';

class LocationInfoScreen extends StatelessWidget {
  const LocationInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LocationProvider(),
      child: const _Body(),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();
  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  // ─── controller منفصل للعنوان ──────────────────────────────
  final _addrCtrl = TextEditingController();

  final Map<String, List<String>> _cityAreas = {
    'damascus': [
      'barzeh',
      'mazzeh',
      'kafr_sousa',
      'abu_rummaneh',
      'midane',
      'rukn_al_din',
      'ash_al_warwar',
      'qadam',
    ],
    'rif_damascus': [
      'al_tal',
      'manin',
      'saydnaya',
      'maarraba',
      'qudsaya',
      'jaramana',
      'sahnaya',
      'daraya',
    ],
  };

  @override
  void dispose() {
    _addrCtrl.dispose();
    super.dispose();
  }

  List<String> _areas(String? city) => _cityAreas[city] ?? [];

  Map<String, String> _labels(AppLocalizations local) => {
    'barzeh': local.barzeh,
    'mazzeh': local.mazzeh,
    'kafr_sousa': local.kafr_sousa,
    'abu_rummaneh': local.abu_rummaneh,
    'midane': local.midane,
    'rukn_al_din': local.rukn_al_din,
    'ash_al_warwar': local.ash_al_warwar,
    'qadam': local.qadam,
    'al_tal': local.al_tal,
    'manin': local.manin,
    'saydnaya': local.saydnaya,
    'maarraba': local.maarraba,
    'qudsaya': local.qudsaya,
    'jaramana': local.jaramana,
    'sahnaya': local.sahnaya,
    'daraya': local.daraya,
  };

  InputDecoration _dec({IconData? icon, String? hint}) => InputDecoration(
    prefixIcon: icon != null ? Icon(icon, color: Colors.black87) : null,
    hintText: hint,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.black),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.black87),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.green, width: 2),
    ),
  );

  Widget _progress() => Row(
    children: List.generate(
      4,
      (i) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 6,
          decoration: BoxDecoration(
            color: i <= 3 ? Colors.green : Colors.green.withOpacity(.2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    ),
  );

  Future<void> _submit() async {
    final prov = context.read<LocationProvider>();
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    final ok = await prov.submit(token);
    if (!mounted) return;

    if (ok) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ApplicationReviewScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(prov.errorMessage ?? 'Error occurred'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final prov = context.watch<LocationProvider>();
    final lbl = _labels(local);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _progress(),
            const SizedBox(height: 28),

            Text(
              local.workLocationTitle,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 28),

            // ─── City ───────────────────────────────────────────
            Text(
              local.city,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: prov.selectedCity,
              decoration: _dec(icon: Icons.location_city),
              items: [
                DropdownMenuItem(
                  value: 'damascus',
                  child: Text(local.damascus),
                ),
                DropdownMenuItem(
                  value: 'rif_damascus',
                  child: Text(local.rifDamascus),
                ),
              ],
              onChanged: (v) => prov.updateCity(v!),
            ),
            const SizedBox(height: 20),

            // ─── Area ────────────────────────────────────────────
            Text(
              local.workArea,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: prov.selectedArea,
              decoration: _dec(icon: Icons.map),
              items: _areas(prov.selectedCity)
                  .map(
                    (a) => DropdownMenuItem(value: a, child: Text(lbl[a] ?? a)),
                  )
                  .toList(),
              onChanged: (v) => prov.updateArea(v!),
            ),
            const SizedBox(height: 20),

            // ─── Address — TextField بسيط بدل Autocomplete ───────
            Text(
              local.detailedAddress,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _addrCtrl,
              decoration: _dec(icon: Icons.home, hint: local.addressHint),
              onChanged: (v) => prov.updateAddress(v),
            ),
            const SizedBox(height: 12),

            // ─── Map Button ───────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push<Map<String, dynamic>>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MapSelectionScreen(),
                    ),
                  );
                  if (result != null && mounted) {
                    final addr = result['address']?.toString() ?? '';
                    // ─── تعبئة تلقائية فورية ───────────────────
                    _addrCtrl.text = addr;
                    prov.updateAddress(addr);
                  }
                },
                icon: const Icon(Icons.location_on, color: Colors.black),
                label: Text(
                  local.selectOnMap,
                  style: const TextStyle(color: Colors.black),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ─── Working Hours ────────────────────────────────────
            Text(
              local.workingHours,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.access_time, color: Colors.black),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (t != null) prov.updateStartTime(t);
                    },
                    label: Text(
                      prov.startTime?.format(context) ?? local.startTime,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(
                      Icons.access_time_filled,
                      color: Colors.black,
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (t != null) prov.updateEndTime(t);
                    },
                    label: Text(
                      prov.endTime?.format(context) ?? local.endTime,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ─── Error ───────────────────────────────────────────
            if (prov.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        prov.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            // ─── Buttons ─────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.black),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: prov.isLoading
                        ? null
                        : () => Navigator.pop(context),
                    label: Text(
                      local.back,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: prov.isValid
                          ? Colors.black
                          : Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: (prov.isValid && !prov.isLoading)
                        ? _submit
                        : null,
                    child: prov.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            local.finish,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
