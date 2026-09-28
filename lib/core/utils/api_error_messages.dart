import '../../l10n/app_localizations.dart';

String localizeApiError(String raw, AppLocalizations t) {
  final msg = raw.replaceFirst(RegExp(r'^Exception:\s*'), '');
  switch (msg) {
    case 'Wallet balance is not sufficient. Top up your wallet to go online.':
      return t.prepaidMustTopUp;
    case 'Cannot GET /drivers/me/preferences':
      return t.preferencesLoadFailed;
    default:
      return msg;
  }
}
