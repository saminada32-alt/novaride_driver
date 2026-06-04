import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novaride_driver/features/auth/providers/auth_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../car_info/car_info_screen.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/app_controller.dart';
import '../personal_info/provider/driver_provider.dart';
import '../personal_info/model/driver_info_model.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  String? joinType;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController(); // ✅ جديد
  final officeNameController = TextEditingController();
  final officeLocationController = TextEditingController();
  final idController = TextEditingController();

  DateTime? selectedBirthDate;

  String? nameError;
  String? lastNameError; // ✅ جديد
  String? officeNameError;
  String? idError;
  String? ageError;

  int get age {
    if (selectedBirthDate == null) return 0;
    final today = DateTime.now();
    int age = today.year - selectedBirthDate!.year;
    if (today.month < selectedBirthDate!.month ||
        (today.month == selectedBirthDate!.month &&
            today.day < selectedBirthDate!.day)) {
      age--;
    }
    return age;
  }

  bool get isUnderAge => selectedBirthDate != null && age < 18;

  bool get isValid {
    if (joinType == null) return false;
    if (selectedBirthDate == null) return false;
    if (isUnderAge) return false;

    if (firstNameController.text.trim().length < 3) return false;
    if (lastNameController.text.trim().length < 3) return false; // ✅ جديد
    if (idController.text.trim().length < 6) return false;

    if (joinType == "office") {
      if (officeNameController.text.trim().length < 3) return false;
      if (officeLocationController.text.trim().length < 3) return false;
    }

    return true;
  }

  Widget buildProgressBar() {
    return Row(
      children: List.generate(4, (index) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 6,
            decoration: BoxDecoration(
              color: index == 0 ? Colors.green : Colors.green.withOpacity(.2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }),
    );
  }

  Widget buildRadioTile(String value, String title, IconData icon) {
    return RadioListTile<String>(
      value: value,
      groupValue: joinType,
      activeColor: Colors.green,
      secondary: Icon(icon, color: Colors.green),
      title: Text(title),
      onChanged: (val) => setState(() => joinType = val),
    );
  }

  Widget requiredLabel(String text, bool isArabic) {
    return Align(
      alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 4),
          const Text("*", style: TextStyle(color: Colors.red, fontSize: 16)),
        ],
      ),
    );
  }

  InputDecoration inputDecoration({required IconData icon, String? hint}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.green),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.green, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Future<void> pickDate(AppLocalizations local) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedBirthDate = picked;
        ageError = age < 18 ? local.ageError : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final controller = context.watch<AppController>();
    final provider = context.watch<DriverProvider>();
    final isArabic = controller.isArabic;

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
              final newLang = controller.isArabic ? 'en' : 'ar';
              controller.changeLanguage(newLang);
            },
            child: Text(
              controller.isArabic ? "EN" : "AR",
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                if (provider.errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Text(
                      provider.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                buildProgressBar(),
                const SizedBox(height: 30),

                Text(
                  local.personalInfoTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                ),

                const SizedBox(height: 20),

                Text(
                  local.personalInfoSubtitle,
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                ),

                const SizedBox(height: 30),

                Text(
                  local.joinAsDriver,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                buildRadioTile("person", local.person, Icons.person),
                buildRadioTile("office", local.office, Icons.business),

                const SizedBox(height: 20),

                if (joinType != null) ...[
                  Text(
                    local.explain,
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  ),

                  const SizedBox(height: 20),

                  /// FIRST NAME
                  requiredLabel(local.firstName, isArabic),
                  const SizedBox(height: 6),
                  TextField(
                    controller: firstNameController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-Z\u0600-\u06FF\s]'),
                      ),
                    ],
                    decoration: inputDecoration(
                      icon: Icons.person_outline,
                      hint: local.firstNameHint,
                    ),
                    onChanged: (_) {
                      setState(() {
                        nameError = firstNameController.text.trim().length < 3
                            ? local.nameError
                            : null;
                      });
                    },
                  ),
                  if (nameError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        nameError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  const SizedBox(height: 20),

                  /// LAST NAME (جديد)
                  requiredLabel(local.lastName, isArabic),
                  const SizedBox(height: 6),
                  TextField(
                    controller: lastNameController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-Z\u0600-\u06FF\s]'),
                      ),
                    ],
                    decoration: inputDecoration(
                      icon: Icons.person_outline,
                      hint: local.lastNameHint,
                    ),
                    onChanged: (_) {
                      setState(() {
                        lastNameError =
                            lastNameController.text.trim().length < 3
                            ? local.nameError
                            : null;
                      });
                    },
                  ),
                  if (lastNameError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        lastNameError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  requiredLabel(local.birthDate, isArabic),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => pickDate(local),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: const Border.fromBorderSide(
                          BorderSide(color: Colors.black),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_rounded,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            selectedBirthDate == null
                                ? local.selectBirthDate
                                : "${selectedBirthDate!.day}/${selectedBirthDate!.month}/${selectedBirthDate!.year}",
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (ageError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        ageError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  if (joinType == "office") ...[
                    const SizedBox(height: 20),

                    requiredLabel(local.officeN, isArabic),
                    const SizedBox(height: 6),
                    TextField(
                      controller: officeNameController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z\u0600-\u06FF\s]'),
                        ),
                      ],
                      decoration: inputDecoration(
                        icon: Icons.business,
                        hint: local.officeN,
                      ),
                      onChanged: (_) {
                        setState(() {
                          officeNameError =
                              officeNameController.text.trim().length < 3
                              ? local.nameError
                              : null;
                        });
                      },
                    ),
                    if (officeNameError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          officeNameError!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    const SizedBox(height: 20),

                    requiredLabel(local.location, isArabic),
                    const SizedBox(height: 6),
                    TextField(
                      controller: officeLocationController,
                      decoration: inputDecoration(
                        icon: Icons.location_on_outlined,
                        hint: local.location,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ],

                  const SizedBox(height: 20),

                  requiredLabel(local.idNumber, isArabic),
                  const SizedBox(height: 6),
                  TextField(
                    controller: idController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: inputDecoration(
                      icon: Icons.credit_card_outlined,
                      hint: local.idHint,
                    ),
                    onChanged: (_) {
                      setState(() {
                        idError = idController.text.trim().length < 6
                            ? local.idError
                            : null;
                      });
                    },
                  ),
                  if (idError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        idError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  const SizedBox(height: 40),

                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isValid ? Colors.black : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      onPressed: isValid && !provider.isLoading
                          ? () async {
                              final token = context.read<AuthProvider>().token;
                              if (token == null) return;

                              final driver = DriverInfoModel(
                                joinType: joinType!,
                                firstName: firstNameController.text.trim(),
                                lastName: lastNameController.text.trim(),
                                idNumber: idController.text.trim(),
                                birthDate: selectedBirthDate!,
                                officeName: joinType == 'office'
                                    ? officeNameController.text.trim()
                                    : null,
                                officeLocation: joinType == 'office'
                                    ? officeLocationController.text.trim()
                                    : null,
                              );

                              final ok = await provider.registerDriver(
                                driver,
                                token,
                              );

                              if (ok && mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CarInfoScreen(),
                                  ),
                                );
                              }
                            }
                          : null,

                      child: Text(
                        provider.isLoading ? "Loading..." : local.next,

                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (provider.isLoading)
            Container(
              color: Colors.black.withOpacity(.2),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.green),
              ),
            ),
        ],
      ),
    );
  }
}
