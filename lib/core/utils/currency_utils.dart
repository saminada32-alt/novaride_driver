import 'package:intl/intl.dart';

/// تنسيق الأسعار بالليرة السورية الجديدة (ل.س)
class CurrencyUtils {
  CurrencyUtils._();

  static final NumberFormat _formatter = NumberFormat('#,##0', 'ar');

  static String formatSyp(num? amount, {String symbol = 'ل.س'}) {
    if (amount == null) return '--';
    return '${_formatter.format(amount.round())} $symbol';
  }

  static String formatSypCompact(num? amount) {
    if (amount == null) return '--';
    final n = amount.round();
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M ل.س';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K ل.س';
    return formatSyp(n);
  }
}
