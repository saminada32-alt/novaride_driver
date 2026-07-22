import 'package:flutter/material.dart';
import '../../core/utils/session_cache.dart';
import '../../auth/models/auth_model.dart';
import '../onboarding/application_review/application_review_screen.dart';
import '../onboarding/car_info/car_info_screen.dart';
import '../onboarding/documents/documents_screen.dart';
import '../onboarding/location/location_info_screen.dart';
import '../onboarding/personal_info/personal_info_screen.dart';
import '../pending/pending_approval_screen.dart';

enum DriverOnboardingStep {
  personalInfo,
  carInfo,
  documents,
  location,
  review,
  pendingApproval,
}

class DriverOnboardingRouter {
  DriverOnboardingRouter._();

  static Future<void> saveStep(DriverOnboardingStep step) =>
      SessionCache.saveDriverOnboardingStep(step.name);

  static Future<DriverOnboardingStep?> _loadStep() async {
    final raw = await SessionCache.loadDriverOnboardingStep();
    if (raw == null) return null;
    for (final step in DriverOnboardingStep.values) {
      if (step.name == raw) return step;
    }
    return null;
  }

  static Widget screenFor(DriverOnboardingStep step) {
    switch (step) {
      case DriverOnboardingStep.personalInfo:
        return const PersonalInfoScreen();
      case DriverOnboardingStep.carInfo:
        return const CarInfoScreen();
      case DriverOnboardingStep.documents:
        return const DocumentsScreen();
      case DriverOnboardingStep.location:
        return const LocationInfoScreen();
      case DriverOnboardingStep.review:
        return const ApplicationReviewScreen();
      case DriverOnboardingStep.pendingApproval:
        return const PendingApprovalScreen();
    }
  }

  /// Resume driver onboarding after OTP or cold start (pending, not approved yet).
  static Future<void> resumePending(
    BuildContext context, {
    DriverModel? driver,
  }) async {
    if (driver?.applicationSubmitted == true) {
      await saveStep(DriverOnboardingStep.pendingApproval);
      _replace(context, const PendingApprovalScreen());
      return;
    }

    final step = await _loadStep() ?? DriverOnboardingStep.personalInfo;
    if (step == DriverOnboardingStep.pendingApproval) {
      _replace(context, const PendingApprovalScreen());
      return;
    }

    _replace(context, screenFor(step));
  }

  static void _replace(BuildContext context, Widget screen) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => screen),
      (_) => false,
    );
  }
}
