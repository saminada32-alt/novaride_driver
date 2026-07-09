import '../../l10n/app_localizations.dart';

String localizeApiError(String raw, AppLocalizations t) {
  final msg = raw.replaceFirst(RegExp(r'^Exception:\s*'), '');
  switch (msg) {
    case 'No subscription plan. Please choose a plan in the app.':
      return t.noSubscriptionPlanRequired;
    case 'Subscription payment required':
      return t.subscriptionPaymentRequired;
    case 'Subscription suspended. Please settle payment to go online.':
      return t.subscriptionSuspended;
    case 'Monthly subscription payment required before going online.':
      return t.monthlySubscriptionPaymentRequired;
    case 'Payment overdue. Please submit payment in Subscriptions.':
      return t.subscriptionPaymentOverdue;
    case 'Cannot GET /drivers/me/preferences':
      return t.preferencesLoadFailed;
    default:
      return msg;
  }
}
