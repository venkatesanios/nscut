import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/models/layer.dart';

class StickerGeneratorEngine {
  static void renderStickerLayer(Canvas canvas, Size canvasSize, Layer layer, double currentTime) {
    final media = layer.media;
    final shape = media.stickerSvgShape ?? 'star';
    final opacity = layer.opacity;

    // Pulsing micro-animation
    final pulseScale = 1.0 + (math.sin(currentTime * 4.0) * 0.05);
    canvas.scale(pulseScale, pulseScale);

    final fillPaint = Paint()
      ..color = const Color(0xFFE84393).withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final glowPaint = Paint()
      ..color = const Color(0xFFFD79A8).withValues(alpha: 0.5 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);

    if (shape == 'star') {
      final starPath = _createStarPath(Offset.zero, 5, 45, 20);
      canvas.drawPath(starPath, glowPaint);
      canvas.drawPath(starPath, fillPaint);
      canvas.drawPath(starPath, borderPaint);
    } else if (shape == 'badge') {
      const rect = Rect.fromLTWH(-40, -25, 80, 50);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));
      canvas.drawRRect(rrect, glowPaint);
      canvas.drawRRect(rrect, fillPaint);
      canvas.drawRRect(rrect, borderPaint);
    } else {
      // Default Circle Badge
      canvas.drawCircle(Offset.zero, 35, glowPaint);
      canvas.drawCircle(Offset.zero, 35, fillPaint);
      canvas.drawCircle(Offset.zero, 35, borderPaint);
    }

    // Draw Icon in center if present
    if (media.stickerIcon != null) {
      TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
      textPainter.text = TextSpan(
        text: String.fromCharCode(media.stickerIcon!.codePoint),
        style: TextStyle(
          fontSize: 28,
          fontFamily: media.stickerIcon!.fontFamily,
          package: media.stickerIcon!.fontPackage,
          color: Colors.white.withValues(alpha: opacity),
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
    }
  }

  static Path _createStarPath(Offset center, int points, double outerRadius, double innerRadius) {
    final path = Path();
    final double angleStep = math.pi / points;
    double currentAngle = -math.pi / 2;

    for (int i = 0; i < points * 2; i++) {
      final radius = (i % 2 == 0) ? outerRadius : innerRadius;
      final x = center.dx + radius * math.cos(currentAngle);
      final y = center.dy + radius * math.sin(currentAngle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      currentAngle += angleStep;
    }
    path.close();
    return path;
  }
}
