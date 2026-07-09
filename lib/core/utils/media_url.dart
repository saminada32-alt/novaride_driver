import '../constants/api_constants.dart';

String? resolveMediaUrl(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  if (raw.startsWith('http')) return raw;
  if (raw.startsWith('/uploads/')) return '${Api.base}$raw';
  return raw;
}
