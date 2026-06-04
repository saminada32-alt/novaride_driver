import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// أيقونة سيارة من الأعلى — نمط Bolt (صغيرة، داكنة، تدور مع الاتجاه).
class MapIcons {
  MapIcons._();

  static final Map<int, BitmapDescriptor> _cache = {};

  static Future<BitmapDescriptor> car({double rotation = 0}) async {
    if (_cache.containsKey(0)) return _cache[0]!;
    final icon = await _drawTopDownCar();
    _cache[0] = icon;
    return icon;
  }

  static Future<BitmapDescriptor> _drawTopDownCar() async {
    const size = 64.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const cx = size / 2;
    const cy = size / 2;

    final shadow = Paint()
      ..color = const Color(0x35000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(cx, cy + 3), width: 24, height: 38),
      shadow,
    );

    final bodyPaint = Paint()..color = const Color(0xFF2E2E2E);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(cx, cy), width: 22, height: 40),
        const Radius.circular(8),
      ),
      bodyPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(cx, cy - 5), width: 17, height: 15),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF484848),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(cx, cy + 10), width: 15, height: 9),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF3A3A3A),
    );

    final light = Paint()..color = const Color(0xFFE8E8E8);
    canvas.drawCircle(const Offset(cx - 7, cy - 18), 2.2, light);
    canvas.drawCircle(const Offset(cx + 7, cy - 18), 2.2, light);

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      width: 28,
    );
  }

  static double bearing(LatLng from, LatLng to) {
    final lat1 = from.latitude * math.pi / 180;
    final lat2 = to.latitude * math.pi / 180;
    final dLng = (to.longitude - from.longitude) * math.pi / 180;
    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }
}
