import '../../l10n/app_localizations.dart';

String localizeApiError(String raw, AppLocalizations t) {
  final msg = raw.replaceFirst(RegExp(r'^Exception:\s*'), '');
  switch (msg) {
    case 'Wallet balance is not sufficient. Top up your wallet to go online.':
      return t.prepaidMustTopUp;
    case 'Your account is not approved yet.':
      return t.driverNotApprovedYet;
    case 'Finish your current ride before accepting another':
      return t.driverFinishCurrentRide;
    case 'Cannot GET /drivers/me/preferences':
      return t.preferencesLoadFailed;
    default:
      return msg;
  }
}
