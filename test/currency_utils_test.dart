import 'package:flutter_test/flutter_test.dart';
import 'package:novaride_driver/core/utils/currency_utils.dart';

void main() {
  group('CurrencyUtils.formatSyp', () {
    test('null amount shows a placeholder, not "null" or an exception', () {
      expect(CurrencyUtils.formatSyp(null), '--');
    });

    test('rounds to nearest integer and appends the currency symbol', () {
      expect(CurrencyUtils.formatSyp(15000), '15,000 ل.س');
      expect(CurrencyUtils.formatSyp(15000.4), '15,000 ل.س');
      expect(CurrencyUtils.formatSyp(15000.6), '15,001 ل.س');
    });

    test('zero is formatted, not treated as null', () {
      expect(CurrencyUtils.formatSyp(0), '0 ل.س');
    });

    test('custom symbol override is honored', () {
      expect(CurrencyUtils.formatSyp(100, symbol: 'SYP'), '100 SYP');
    });
  });

  group('CurrencyUtils.formatSypCompact', () {
    test('null amount shows a placeholder', () {
      expect(CurrencyUtils.formatSypCompact(null), '--');
    });

    test('values under 1,000 use the full formatter (no suffix)', () {
      expect(CurrencyUtils.formatSypCompact(999), '999 ل.س');
    });

    test('thousands are abbreviated with K', () {
      expect(CurrencyUtils.formatSypCompact(1000), '1.0K ل.س');
      expect(CurrencyUtils.formatSypCompact(15500), '15.5K ل.س');
    });

    test('millions are abbreviated with M', () {
      expect(CurrencyUtils.formatSypCompact(1000000), '1.0M ل.س');
      expect(CurrencyUtils.formatSypCompact(2500000), '2.5M ل.س');
    });

    test('boundary just under 1,000,000 still uses K, not M', () {
      expect(CurrencyUtils.formatSypCompact(999999), '1000.0K ل.س');
    });
  });
}
