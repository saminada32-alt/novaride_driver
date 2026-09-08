import 'package:flutter/material.dart';
import '../home/home_screen.dart';

class DriverEntry {
  DriverEntry._();

  static Future<void> goAfterAuth(BuildContext context, {int? driverId}) async {
    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const DriverHomeScreen()),
      (_) => false,
    );
  }
}
