import 'package:flutter/material.dart';
import '../../../core/services/socket_service.dart';
import '../home/home_screen.dart';
import '../subscription/subscription_plan_screen.dart';
import '../subscription/subscription_service.dart';

class DriverEntry {
  DriverEntry._();

  static Future<void> goAfterAuth(BuildContext context, {int? driverId}) async {
    if (!context.mounted) return;

    // Navigate immediately — do not block login on socket/subscription APIs.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const DriverHomeScreen()),
      (_) => false,
    );

    DriverSocketService.instance.connect(driverId: driverId);

    final sub = await DriverSubscriptionService.instance.getMySubscription();
    if (!context.mounted || sub != null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SubscriptionPlanScreen(fromOnboarding: true),
      ),
    );
  }
}
