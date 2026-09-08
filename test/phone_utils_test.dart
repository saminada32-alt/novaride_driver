import 'package:flutter_test/flutter_test.dart';
import 'package:novaride_driver/core/utils/phone_utils.dart';

/// Mirrors the backend's Syrian phone validator:
/// `/^(\+?963|0)?9[0-9]{8}$/` (src/auth/dto/auth.dto.ts). If a normalized
/// phone can't satisfy this, real drivers get rejected by /auth/send-otp.
final backendPhoneRegex = RegExp(r'^(\+?963|0)?9[0-9]{8}$');

void main() {
  group('buildAuthPhone', () {
    test('local number typed with leading 0', () {
      expect(buildAuthPhone('+963', '0944123456'), '+963944123456');
    });

    test('local number typed without leading 0', () {
      expect(buildAuthPhone('+963', '944123456'), '+963944123456');
    });

    test('dedupes country code already present in the local input', () {
      expect(buildAuthPhone('+963', '963944123456'), '+963944123456');
    });

    test('strips non-digit characters (spaces, dashes)', () {
      expect(buildAuthPhone('+963', '094 412-3456'), '+963944123456');
    });

    test('result satisfies the backend phone validator', () {
      final phone = buildAuthPhone('+963', '0944123456');
      expect(backendPhoneRegex.hasMatch(phone), isTrue, reason: phone);
    });
  });
}
