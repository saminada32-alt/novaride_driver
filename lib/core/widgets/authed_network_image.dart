import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

/// Loads API-hosted images with Bearer auth; keeps [localPreviewPath] until loaded.
class AuthedNetworkImage extends StatefulWidget {
  const AuthedNetworkImage({
    super.key,
    required this.url,
    required this.fallback,
    this.fit = BoxFit.cover,
    this.tokenStorageKey = 'driver_token',
    this.localPreviewPath,
    this.onNetworkLoaded,
  });

  final String url;
  final Widget fallback;
  final BoxFit fit;
  final String tokenStorageKey;
  final String? localPreviewPath;
  final VoidCallback? onNetworkLoaded;

  @override
  State<AuthedNetworkImage> createState() => _AuthedNetworkImageState();
}

class _AuthedNetworkImageState extends State<AuthedNetworkImage> {
  static const _storage = FlutterSecureStorage();

  Map<String, String>? _headers;
  bool _authReady = false;

  bool get _isApiUpload =>
      widget.url.startsWith('http') &&
      widget.url.startsWith(Api.base) &&
      widget.url.contains('/uploads/');

  @override
  void initState() {
    super.initState();
    if (_isApiUpload) {
      _loadAuth();
    } else {
      _authReady = true;
    }
  }

  Future<void> _loadAuth() async {
    final token = await _storage.read(key: widget.tokenStorageKey);
    if (!mounted) return;
    setState(() {
      _headers = (token != null && token.isNotEmpty)
          ? {'Authorization': 'Bearer $token'}
          : null;
      _authReady = true;
    });
  }

  Widget _localOrFallback() {
    final path = widget.localPreviewPath;
    if (path != null && path.isNotEmpty) {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(file, fit: widget.fit);
      }
    }
    return widget.fallback;
  }

  @override
  Widget build(BuildContext context) {
    if (_isApiUpload && !_authReady) {
      return _localOrFallback();
    }

    return CachedNetworkImage(
      imageUrl: widget.url,
      cacheKey: widget.url.split('?').first,
      fit: widget.fit,
      httpHeaders: _isApiUpload ? _headers : null,
      placeholder: (_, __) => _localOrFallback(),
      imageBuilder: (context, imageProvider) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onNetworkLoaded?.call();
        });
        return Image(image: imageProvider, fit: widget.fit);
      },
      errorWidget: (_, __, ___) => _localOrFallback(),
    );
  }
}
