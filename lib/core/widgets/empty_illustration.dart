import 'package:flutter/material.dart';

/// Empty state matching rides/history pages: illustration + bold caption.
class EmptyIllustration extends StatelessWidget {
  const EmptyIllustration({
    super.key,
    required this.imageAsset,
    required this.message,
    this.imageHeight = 220,
  });

  final String imageAsset;
  final String message;
  final double imageHeight;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imageAsset,
              height: imageHeight,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Icon(
                Icons.image_not_supported_outlined,
                size: 72,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
