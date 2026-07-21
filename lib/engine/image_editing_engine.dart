import 'package:flutter/material.dart';
import '../core/models/layer.dart';

class ImageEditingEngine {
  static void renderImageLayer(Canvas canvas, Size canvasSize, Layer layer, double currentTime) {
    const double width = 220.0;
    const double height = 150.0;
    final rect = Rect.fromCenter(center: Offset.zero, width: width, height: height);

    final paint = Paint()
      ..color = layer.media.color.withValues(alpha: layer.opacity)
      ..style = PaintingStyle.fill;

    // Draw Image Layer Frame (Card style preview)
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(10)), paint);

    // Decorative Graphic overlay inside image
    final accentPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8 * layer.opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(Offset.zero, 30.0, accentPaint);
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: 30, height: 30),
      accentPaint,
    );

    // Green Screen / Chroma Key Indicator
    if (layer.chromaKeyEnabled) {
      final keyPaint = Paint()
        ..color = Colors.greenAccent.withValues(alpha: 0.3 * layer.opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(Offset.zero, 45.0, keyPaint);
    }
  }
}
