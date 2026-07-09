import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_controller.dart';
import '../services/network_connectivity_service.dart';
import 'no_internet_screen.dart';

/// Global banner when offline or on a weak network.
class ConnectivityOverlay extends StatelessWidget {
  final Widget child;

  const ConnectivityOverlay({super.key, required this.child});

  static const double _bannerHeight = 52;

  @override
  Widget build(BuildContext context) {
    final net = context.watch<NetworkConnectivityService>();
    final showBanner = net.status != AppNetworkStatus.online;

    return Stack(
      children: [
        AnimatedPadding(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(top: showBanner ? _bannerHeight : 0),
          child: child,
        ),
        if (showBanner)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: NoInternetWidget(
                status: net.status,
                isArabic: context.watch<AppController>().isArabic,
                onRetry: net.probe,
              ),
            ),
          ),
      ],
    );
  }
}
