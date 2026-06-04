import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/providers/auth_provider.dart';
import 'provider/vehicle_provider.dart';

class EditVehicleScreen extends StatefulWidget {
  const EditVehicleScreen({super.key});

  @override
  State<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _brand;
  late TextEditingController _model;
  late TextEditingController _year;
  late TextEditingController _plate;
  late TextEditingController _color;

  @override
  void initState() {
    super.initState();
    final v = context.read<VehicleProvider>().vehicle;
    _brand = TextEditingController(text: v?.brand ?? '');
    _model = TextEditingController(text: v?.model ?? '');
    _year = TextEditingController(text: v?.year ?? '');
    _plate = TextEditingController(text: v?.plateNumber ?? '');
    _color = TextEditingController(text: v?.color ?? '');
  }

  @override
  void dispose() {
    _brand.dispose();
    _model.dispose();
    _year.dispose();
    _plate.dispose();
    _color.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final token = context.read<AuthProvider>().token;
    final provider = context.read<VehicleProvider>();
    if (token == null) return;

    final ok = await provider.updateVehicle(
      token: token,
      brand: _brand.text.trim(),
      model: _model.text.trim(),
      year: _year.text.trim(),
      plate: _plate.text.trim(),
      color: _color.text.trim(),
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vehicle updated!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update vehicle'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final provider = context.watch<VehicleProvider>();

    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        title: Text(t.editVehicle),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field(_brand, t.brandLabel ?? 'Brand', Icons.branding_watermark),
              const SizedBox(height: 14),
              _field(_model, t.modelLabel ?? 'Model', Icons.directions_car),
              const SizedBox(height: 14),
              _field(
                _year,
                t.yearLabel ?? 'Year',
                Icons.calendar_today,
                type: TextInputType.number,
              ),
              const SizedBox(height: 14),
              _field(_plate, t.plateLabel ?? 'Plate', Icons.numbers),
              const SizedBox(height: 14),
              _field(_color, t.colorLabel ?? 'Color', Icons.color_lens),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: provider.isSaving ? null : _save,
                  child: provider.isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          t.save ?? 'Save',
                          style: const TextStyle(
                            fontSize: 16,
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
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      validator: (v) => v!.trim().isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
      ),
    );
  }
}
