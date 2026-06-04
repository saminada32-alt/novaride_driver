import 'package:flutter/material.dart';
import '../utils/currency_utils.dart';
import '../../features/driver/home/rides/model/ride_model.dart';

/// Shows final fare with optional promo discount line.
class FareWithPromo extends StatelessWidget {
  final DriverRideModel ride;
  final TextStyle? fareStyle;
  final bool compact;
  final CrossAxisAlignment alignment;

  const FareWithPromo({
    super.key,
    required this.ride,
    this.fareStyle,
    this.compact = false,
    this.alignment = CrossAxisAlignment.start,
  });

  bool get _hasDiscount =>
      ride.promoCode != null &&
      ride.discountAmount != null &&
      ride.discountAmount! > 0;

  @override
  Widget build(BuildContext context) {
    if (ride.estimatedFare == null) return const SizedBox.shrink();

    final fareText = CurrencyUtils.formatSyp(ride.estimatedFare);

    if (!_hasDiscount) {
      return Text(fareText, style: fareStyle);
    }

    if (compact) {
      return Column(
        crossAxisAlignment: alignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(fareText, style: fareStyle),
          Text(
            '${ride.promoCode} −${CurrencyUtils.formatSyp(ride.discountAmount)}',
            style: TextStyle(
              fontSize: (fareStyle?.fontSize ?? 14) * 0.65,
              color: const Color(0xFF4ade80),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (ride.originalFare != null)
          Text(
            CurrencyUtils.formatSyp(ride.originalFare),
            style: TextStyle(
              fontSize: (fareStyle?.fontSize ?? 16) * 0.55,
              color: Colors.white54,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        Text(fareText, style: fareStyle),
        Text(
          '${ride.promoCode} · −${CurrencyUtils.formatSyp(ride.discountAmount)}',
          style: TextStyle(
            fontSize: (fareStyle?.fontSize ?? 16) * 0.55,
            color: const Color(0xFF4ade80),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
