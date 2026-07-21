import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/models/layer.dart';

class AIEffectsEngine {
  static void renderAIEffectLayer(Canvas canvas, Size canvasSize, Layer layer, double currentTime) {
    final media = layer.media;
    final effectType = media.aiEffectType;
    final intensity = media.aiIntensity;
    final opacity = layer.opacity;

    if (effectType == 'cyberpunk_anime') {
      _renderCyberpunkAnime(canvas, canvasSize, currentTime, intensity * opacity);
    } else if (effectType == 'bg_remove') {
      _renderBackgroundMattingOverlay(canvas, canvasSize, currentTime, intensity * opacity);
    } else if (effectType == 'motion_blur') {
      _renderMotionParticleGrid(canvas, canvasSize, currentTime, intensity * opacity);
    } else if (effectType == 'vhs_glitch') {
      _renderVHSScanlines(canvas, canvasSize, currentTime, intensity * opacity);
    } else {
      _renderGenericAIPowerGlow(canvas, canvasSize, currentTime, intensity * opacity);
    }
  }

  static void _renderCyberpunkAnime(Canvas canvas, Size canvasSize, double time, double intensity) {
    final rect = Rect.fromLTWH(-canvasSize.width / 2, -canvasSize.height / 2, canvasSize.width, canvasSize.height);

    final cyanPaint = Paint()
      ..color = const Color(0xFF00CEC9).withValues(alpha: 0.15 * intensity)
      ..blendMode = BlendMode.screen;

    final pinkPaint = Paint()
      ..color = const Color(0xFFFF7675).withValues(alpha: 0.15 * intensity)
      ..blendMode = BlendMode.colorDodge;

    canvas.drawRect(rect, cyanPaint);

    // Dynamic AI Neural Grid Lines
    final pathPaint = Paint()
      ..color = const Color(0xFFA29BFE).withValues(alpha: 0.3 * intensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final step = 40.0;
    final offset = (time * 60) % step;
    final path = Path();
    for (double x = -canvasSize.width / 2; x < canvasSize.width / 2; x += step) {
      path.moveTo(x + offset, -canvasSize.height / 2);
      path.lineTo(x + offset, canvasSize.height / 2);
    }
    canvas.drawPath(path, pathPaint);
    canvas.drawRect(rect, pinkPaint);
  }

  static void _renderBackgroundMattingOverlay(Canvas canvas, Size canvasSize, double time, double intensity) {
    // Holographic Matting Outline around subject
    final outlinePaint = Paint()
      ..color = const Color(0xFF55E6C1).withValues(alpha: 0.7 * intensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4.0);

    final path = Path();
    final center = Offset.zero;
    path.addOval(Rect.fromCenter(center: center, width: 160, height: 220));
    canvas.drawPath(path, outlinePaint);

    // AI Cutout Badge Label
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'AI MATTING ACTIVE',
        style: TextStyle(
          color: const Color(0xFF55E6C1).withValues(alpha: intensity),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -125));
  }

  static void _renderMotionParticleGrid(Canvas canvas, Size canvasSize, double time, double intensity) {
    final random = math.Random(999);
    final particlePaint = Paint()
      ..color = const Color(0xFFFDCB6E).withValues(alpha: 0.6 * intensity)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 25; i++) {
      final speed = random.nextDouble() * 50 + 20;
      final x = (random.nextDouble() - 0.5) * canvasSize.width;
      final y = ((random.nextDouble() * canvasSize.height + time * speed) % canvasSize.height) - canvasSize.height / 2;
      final radius = random.nextDouble() * 3.0 + 1.0;
      canvas.drawCircle(Offset(x, y), radius, particlePaint);
    }
  }

  static void _renderVHSScanlines(Canvas canvas, Size canvasSize, double time, double intensity) {
    final linePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25 * intensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (double y = -canvasSize.height / 2; y < canvasSize.height / 2; y += 4.0) {
      canvas.drawLine(
        Offset(-canvasSize.width / 2, y),
        Offset(canvasSize.width / 2, y),
        linePaint,
      );
    }
  }

  static void _renderGenericAIPowerGlow(Canvas canvas, Size canvasSize, double time, double intensity) {
    final rect = Rect.fromLTWH(-100, -100, 200, 200);
    final glowPaint = Paint()
      ..color = const Color(0xFF6C5CE7).withValues(alpha: 0.3 * intensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15.0);
    canvas.drawOval(rect, glowPaint);
  }
}
