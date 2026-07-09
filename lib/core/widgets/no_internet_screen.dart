import 'package:flutter/material.dart';

import '../services/network_connectivity_service.dart';

/// Top banner shown when the device is offline or on a weak network.
class NoInternetWidget extends StatelessWidget {
  final AppNetworkStatus status;
  final VoidCallback onRetry;
  final bool isArabic;

  const NoInternetWidget({
    super.key,
    required this.status,
    required this.onRetry,
    this.isArabic = true,
  });

  @override
  Widget build(BuildContext context) {
    final isWeak = status == AppNetworkStatus.weak;
    final bg = isWeak ? const Color(0xFFB45309) : const Color(0xFFB91C1C);
    final icon = isWeak ? Icons.signal_wifi_statusbar_connected_no_internet_4 : Icons.wifi_off_rounded;
    final title = isWeak
        ? (isArabic ? 'شبكة ضعيفة' : 'Weak connection')
        : (isArabic ? 'لا يوجد اتصال' : 'No internet');
    final subtitle = isWeak
        ? (isArabic ? 'قد تتأخر بعض العمليات' : 'Some actions may be slow')
        : (isArabic ? 'تحقق من الشبكة وحاول مجدداً' : 'Check your connection');

    return Material(
      color: bg,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                isArabic ? 'إعادة' : 'Retry',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
