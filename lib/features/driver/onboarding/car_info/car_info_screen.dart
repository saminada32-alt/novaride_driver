// ———————————————————————————————————————————————
//  CAR INFO SCREEN (MERGED + ENHANCED VERSION)
// ———————————————————————————————————————————————
// ملف: car_info_screen.dart (معدل)
import 'package:flutter/material.dart';
import 'package:novaride_driver/features/driver/onboarding/documents/documents_screen.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../../../core/services/app_controller.dart';
import '../../../../l10n/app_localizations.dart';
import '../car_info/provider/car_provider.dart';
import '../car_info/driver_vehicle_catalog.dart';
import '../../../../features/auth/providers/auth_provider.dart';

class CarInfoScreen extends StatefulWidget {
  const CarInfoScreen({super.key});

  @override
  State<CarInfoScreen> createState() => _CarInfoScreenState();
}

class _CarInfoScreenState extends State<CarInfoScreen> {
  final plateController = TextEditingController();
  final otherBrandController = TextEditingController();
  final otherModelController = TextEditingController();

  final Map<String, List<String>> carData = {
    "Toyota": ["Corolla", "Camry", "Yaris"],
    "Hyundai": ["Elantra", "Accent"],
    "Kia": ["Rio", "Cerato", "Picanto"],
    "Nissan": ["Sunny", "Altima"],
    "Honda": ["Civic"],
    "Chevrolet": ["Aveo", "Optra"],
    "Ford": ["Focus"],
    "BMW": ["3 Series"],
    "Mercedes": ["C-Class", "E-Class"],
    "Audi": ["A4"],
    "Other": [],
  };

  List<String> get brands => carData.keys.toList();
  List<String> get models =>
      carProvider.car.brand != null && carProvider.car.brand != "Other"
      ? carData[carProvider.car.brand]!
      : [];

  final List<String> years = List.generate(
    30,
    (i) => (DateTime.now().year - i).toString(),
  );

  Map<String, Color> colorMap = {};
  final List<String> passengerOptions = List.generate(
    20,
    (i) => (i + 2).toString(),
  );

  late CarProvider carProvider;
  List<DriverVehicleType> _vehicleTypes = DriverVehicleCatalog.fallback;

  @override
  void initState() {
    super.initState();
    DriverVehicleCatalog.ensureLoaded().then((_) {
      if (mounted) setState(() => _vehicleTypes = DriverVehicleCatalog.types);
    });
  }

  // إعادة تعيين الحقول عند تغيير نوع المركبة
  void resetFields(String type) {
    plateController.clear();
    otherBrandController.clear();
    otherModelController.clear();
    carProvider.reset();
    carProvider.setVehicleType(type);
  }

  Widget buildVehicleOption(String value, String label, IconData icon) {
    final selected = carProvider.car.vehicleType == value;
    return GestureDetector(
      onTap: () => resetFields(value),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.green : Colors.grey,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? Colors.green : Colors.black),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // نجمة حمراء للحقول المطلوبة
  Widget requiredLabel(String text) {
    return Row(
      children: [
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        const Text(' *', style: TextStyle(color: Colors.red)),
      ],
    );
  }

  InputDecoration inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontWeight: FontWeight.bold),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.green, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final controller = context.watch<AppController>();
    final isArabic = controller.isArabic;

    carProvider = context.watch<CarProvider>();

    colorMap = {
      local.white: Colors.white,
      local.black: Colors.black,
      local.green: Colors.green,
      local.blue: Colors.blue,
      local.red: Colors.red,
      local.yellow: Colors.yellow,
      local.grey: Colors.grey,
      local.orange: Colors.orange,
      local.purple: Colors.purple,
      local.brown: Colors.brown,
    };

    bool isValid() {
      final c = carProvider.car;
      if (c.vehicleType == null) return false;

      // فان
      if (c.vehicleType == "van") {
        return c.passengerCount != null &&
            (c.plateNumber?.isNotEmpty ?? false) &&
            c.year != null &&
            c.color != null;
      }

      // دراجة
      if (c.vehicleType == "motorcycle") {
        return (c.plateNumber?.isNotEmpty ?? false) &&
            c.brand != null &&
            ((c.brand == "Other" && (c.model?.isNotEmpty ?? false)) ||
                (c.brand != "Other" && c.model != null)) &&
            c.color != null &&
            c.passengerCount != null;
      }

      // صهريج ماء
      if (c.vehicleType == "water_tanker") {
        return (c.plateNumber?.isNotEmpty ?? false) &&
            c.year != null &&
            c.color != null &&
            (c.tankerCapacity != null && c.tankerCapacity! > 0);
      }

      // نقل عفش
      if (c.vehicleType == "moving_truck") {
        return (c.plateNumber?.isNotEmpty ?? false) &&
            c.year != null &&
            c.color != null &&
            (c.cargoVolume != null && c.cargoVolume! > 0);
      }

      // غسيل سيارات (خدمة) - نطلب فقط رقم اللوحة واللون والسنة أو حقل خدمة
      if (c.vehicleType == "car_wash") {
        return (c.plateNumber?.isNotEmpty ?? false) &&
            c.year != null &&
            c.color != null &&
            (c.hasPressureWasher != null);
      }

      // سيارات عادية
      return c.brand != null &&
          ((c.brand == "Other" &&
                  (c.brand?.isNotEmpty ?? false) &&
                  (c.model?.isNotEmpty ?? false)) ||
              (c.brand != "Other" && c.model != null)) &&
          (c.plateNumber?.isNotEmpty ?? false) &&
          c.year != null &&
          c.color != null;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.directions_car, color: Colors.green),
            SizedBox(width: 8),
            Text(
              "NovaRide",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.changeLanguage(isArabic ? 'en' : 'ar');
            },
            child: Text(
              isArabic ? "EN" : "AR",
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text(
              local.vehicleInfoTitle,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // أنواع المركبات من السيرفر (مع fallback محلي)
            ..._vehicleTypes.map((t) {
              final label = isArabic ? t.labelAr : t.labelEn;
              return buildVehicleOption(t.id, label, t.icon);
            }),

            const SizedBox(height: 30),

            if (carProvider.car.vehicleType != null) ...[
              // رقم اللوحة
              requiredLabel(
                carProvider.car.vehicleType == "motorcycle"
                    ? local.motorcyclePlateNumber
                    : local.licensePlate,
              ),
              const SizedBox(height: 6),
              TextField(
                controller: plateController,
                decoration: inputDecoration(
                  hint: carProvider.car.vehicleType == "motorcycle"
                      ? local.enterMotorPlate
                      : local.enterPlate,
                ),
                onChanged: (val) => carProvider.setPlateNumber(val),
              ),
              const SizedBox(height: 25),

              // السيارة (كما كانت)
              if (carProvider.car.vehicleType == "car" ||
                  carProvider.car.vehicleType == "wheelchair_accessible") ...[
                requiredLabel(local.manufacturer),
                const SizedBox(height: 6),
                DropdownSearch<String>(
                  items: brands,
                  selectedItem: carProvider.car.brand,
                  popupProps: PopupProps.dialog(showSearchBox: true),
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: inputDecoration(),
                  ),
                  onChanged: (val) {
                    carProvider.setBrand(val);
                    carProvider.setModel(null);
                  },
                ),
                const SizedBox(height: 15),
                if (carProvider.car.brand == "Other") ...[
                  requiredLabel(local.enterOtherBrand),
                  const SizedBox(height: 6),
                  TextField(
                    controller: otherBrandController,
                    decoration: inputDecoration(hint: local.enterOtherBrand),
                    onChanged: (val) => carProvider.setBrand(val),
                  ),
                  const SizedBox(height: 15),
                  requiredLabel(local.enterOtherModel),
                  const SizedBox(height: 6),
                  TextField(
                    controller: otherModelController,
                    decoration: inputDecoration(hint: local.enterOtherModel),
                    onChanged: (val) => carProvider.setModel(val),
                  ),
                  const SizedBox(height: 15),
                ],
                if (carProvider.car.brand != null &&
                    carProvider.car.brand != "Other") ...[
                  requiredLabel(local.modelLabel),
                  const SizedBox(height: 6),
                  DropdownSearch<String>(
                    items: models,
                    selectedItem: carProvider.car.model,
                    popupProps: PopupProps.dialog(showSearchBox: true),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: inputDecoration(),
                    ),
                    onChanged: (val) => carProvider.setModel(val),
                  ),
                  const SizedBox(height: 15),
                ],
              ],

              // اللون لجميع المركبات
              requiredLabel(local.vehicleColor),
              const SizedBox(height: 6),
              DropdownSearch<String>(
                items: colorMap.keys.toList(),
                selectedItem: carProvider.car.color,
                popupProps: const PopupProps.dialog(showSearchBox: true),
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: inputDecoration(),
                ),
                onChanged: (val) => carProvider.setColor(val),
              ),
              const SizedBox(height: 25),

              // الفان
              if (carProvider.car.vehicleType == "van") ...[
                requiredLabel(local.passengerCount),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: carProvider.car.passengerCount,
                  items: passengerOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => carProvider.setPassengerCount(val),
                  decoration: inputDecoration(hint: local.selectPassengerHint),
                ),
                const SizedBox(height: 25),
              ],

              // الدراجة
              if (carProvider.car.vehicleType == "motorcycle") ...[
                requiredLabel(local.motorcycleBrand),
                const SizedBox(height: 6),
                DropdownSearch<String>(
                  items: ["Honda", "Yamaha", "Kawasaki", "Suzuki", "Other"],
                  selectedItem: carProvider.car.brand,
                  popupProps: PopupProps.dialog(showSearchBox: true),
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: inputDecoration(),
                  ),
                  onChanged: (val) {
                    carProvider.setBrand(val);
                    carProvider.setModel(null);
                  },
                ),
                const SizedBox(height: 15),
                if (carProvider.car.brand == "Other") ...[
                  requiredLabel(local.enterOtherModel),
                  const SizedBox(height: 6),
                  TextField(
                    controller: otherModelController,
                    decoration: inputDecoration(hint: local.enterOtherModel),
                    onChanged: (val) => carProvider.setModel(val),
                  ),
                  const SizedBox(height: 15),
                ],
                if (carProvider.car.brand != null &&
                    carProvider.car.brand != "Other") ...[
                  requiredLabel(local.motorcycleModel),
                  const SizedBox(height: 6),
                  DropdownSearch<String>(
                    items: carProvider.car.brand == "Honda"
                        ? ["CBR", "CB500", "CRF"]
                        : carProvider.car.brand == "Yamaha"
                        ? ["YZF", "MT-07", "FZ6"]
                        : carProvider.car.brand == "Kawasaki"
                        ? ["Ninja", "Z650", "Versys"]
                        : carProvider.car.brand == "Suzuki"
                        ? ["GSX-R", "V-Strom", "SV650"]
                        : [],
                    selectedItem: carProvider.car.model,
                    popupProps: PopupProps.dialog(showSearchBox: true),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: inputDecoration(),
                    ),
                    onChanged: (val) => carProvider.setModel(val),
                  ),
                  const SizedBox(height: 15),
                ],
                requiredLabel(local.motorcycleEngineSize),
                const SizedBox(height: 6),
                DropdownSearch<String>(
                  items: ["125", "150", "250", "500", "1000"],
                  selectedItem: carProvider.car.passengerCount,
                  popupProps: const PopupProps.dialog(showSearchBox: true),
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: inputDecoration(),
                  ),
                  onChanged: (val) => carProvider.setPassengerCount(val),
                ),
                const SizedBox(height: 25),
              ],

              // صهريج ماء
              if (carProvider.car.vehicleType == "water_tanker") ...[
                requiredLabel(local.tankerCapacity),
                const SizedBox(height: 6),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: inputDecoration(hint: local.enterTankerCapacity),
                  onChanged: (val) =>
                      carProvider.setTankerCapacity(int.tryParse(val)),
                ),
                const SizedBox(height: 15),
              ],

              // نقل عفش
              if (carProvider.car.vehicleType == "moving_truck") ...[
                requiredLabel(local.cargoVolume),
                const SizedBox(height: 6),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: inputDecoration(hint: local.enterCargoVolume),
                  onChanged: (val) =>
                      carProvider.setCargoVolume(int.tryParse(val)),
                ),
                const SizedBox(height: 15),
              ],

              // غسيل سيارات
              if (carProvider.car.vehicleType == "car_wash") ...[
                requiredLabel(local.carWashHasPressureWasher),
                const SizedBox(height: 6),
                DropdownSearch<String>(
                  items: [local.yes, local.no],
                  selectedItem: carProvider.car.hasPressureWasher == true
                      ? local.yes
                      : local.no,
                  popupProps: const PopupProps.dialog(showSearchBox: true),
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: inputDecoration(),
                  ),
                  onChanged: (val) =>
                      carProvider.setHasPressureWasher(val == local.yes),
                ),
                const SizedBox(height: 15),
              ],

              // السنة للسيارات والفان والصهريج ونقل العفش وغسيل السيارات
              if (carProvider.car.vehicleType != "motorcycle") ...[
                requiredLabel(local.vehicleYear),
                const SizedBox(height: 6),
                DropdownSearch<String>(
                  items: years,
                  selectedItem: carProvider.car.year,
                  popupProps: const PopupProps.menu(showSearchBox: true),
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: inputDecoration(),
                  ),
                  onChanged: (val) => carProvider.setYear(val),
                ),
                const SizedBox(height: 40),
              ],

              // أزرار العودة والتالي (كما كانت)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        local.back,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isValid()
                            ? Colors.black
                            : const Color.fromARGB(255, 1, 0, 0),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      onPressed: isValid()
                          ? () async {
                              final token = context.read<AuthProvider>().token;
                              if (token == null) return;

                              final ok = await carProvider.submitCarInfo(token);

                              if (!mounted) return;

                              if (ok) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const DocumentsScreen(),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      carProvider.errorMessage ?? 'حدث خطأ',
                                    ),
                                    backgroundColor: Colors.red.shade600,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                            }
                          : null,
                      child: carProvider.loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              local.next,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
