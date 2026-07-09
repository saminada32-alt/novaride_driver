import 'package:flutter/material.dart';
import '../utils/media_url.dart';
import 'authed_network_image.dart';

/// Resolves API upload paths and loads them with auth or signed-URL support.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    required this.fallback,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final String? url;
  final Widget fallback;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final resolved = resolveMediaUrl(url);
    if (resolved == null || resolved.isEmpty) {
      return SizedBox(width: width, height: height, child: fallback);
    }

    return SizedBox(
      width: width,
      height: height,
      child: AuthedNetworkImage(
        url: resolved,
        fallback: fallback,
        fit: fit,
      ),
    );
  }
}
