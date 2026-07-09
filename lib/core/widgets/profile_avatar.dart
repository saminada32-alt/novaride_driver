import 'dart:io';

import 'package:flutter/material.dart';
import '../utils/media_url.dart';
import 'authed_network_image.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.imageUrl,
    required this.name,
    this.radius = 32,
    this.onTap,
    this.showCameraBadge = false,
    this.backgroundColor,
    this.initialColor,
    this.localPreviewPath,
    this.onNetworkImageLoaded,
  });

  final String? imageUrl;
  final String name;
  final double radius;
  final VoidCallback? onTap;
  final bool showCameraBadge;
  final Color? backgroundColor;
  final Color? initialColor;
  final String? localPreviewPath;
  final VoidCallback? onNetworkImageLoaded;

  String get _initial =>
      name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

  Widget _fallback() {
    return Container(
      color: backgroundColor ?? Colors.green.shade100,
      alignment: Alignment.center,
      child: Text(
        _initial,
        style: TextStyle(
          fontSize: radius * 0.72,
          fontWeight: FontWeight.bold,
          color: initialColor ?? Colors.green.shade700,
        ),
      ),
    );
  }

  Widget _image() {
    final url = imageUrl;
    if (url == null || url.isEmpty) return _fallback();

    final file = File(url);
    if (!url.startsWith('http') && file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover);
    }

    final resolved = resolveMediaUrl(url);
    if (resolved != null) {
      return AuthedNetworkImage(
        url: resolved,
        fallback: _fallback(),
        tokenStorageKey: 'driver_token',
        localPreviewPath: localPreviewPath,
        onNetworkLoaded: onNetworkImageLoaded,
      );
    }

    return _fallback();
  }

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.white,
      child: ClipOval(child: SizedBox.expand(child: _image())),
    );

    if (!showCameraBadge && onTap == null) return avatar;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          if (showCameraBadge)
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: radius * 0.28,
                backgroundColor: Colors.black54,
                child: Icon(
                  Icons.camera_alt,
                  size: radius * 0.32,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
