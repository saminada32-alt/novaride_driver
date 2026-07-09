/// Normalize phone for auth API (E.164-style, dedupes country code).
String buildAuthPhone(String dialCode, String localInput) {
  final code = dialCode.replaceAll(RegExp(r'\D'), '');
  var local = localInput.replaceAll(RegExp(r'\D'), '');
  if (local.startsWith(code)) return '+$local';
  if (local.startsWith('0')) local = local.substring(1);
  return '+$code$local';
}
