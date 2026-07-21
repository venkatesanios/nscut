import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/models/layer.dart';

class VideoEditingEngine {
  static void renderVideoLayer(Canvas canvas, Size canvasSize, Layer layer, double currentTime) {
    const double width = 280.0;
    const double height = 180.0;
    final rect = Rect.fromCenter(center: Offset.zero, width: width, height: height);

    // Apply Opacity & Color Adjustments
    final double activeOpacity = _calculateTransitionOpacity(layer, currentTime) * layer.opacity;

    // Build Paint with LUT & Color Matrices
    final paint = Paint()
      ..color = layer.media.color.withValues(alpha: activeOpacity)
      ..style = PaintingStyle.fill;

    // Apply Color Matrix Filters
    paint.colorFilter = _createColorMatrixFilter(
      brightness: layer.brightness,
      contrast: layer.contrast,
      saturation: layer.saturation,
      lutFilter: layer.lutFilter,
    );

    // Draw Simulated Procedural Dynamic Video Frame (Cyberpunk Sunset Drive)
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), paint);

    // Render Dynamic Motion Lines / Video Content Simulation
    final timePhase = (currentTime * layer.speed * 2.0);
    final gridPaint = Paint()
      ..color = Colors.cyan.withValues(alpha: 0.3 * activeOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    for (double i = -width / 2; i < width / 2; i += 20) {
      final yOffset = math.sin((i + timePhase * 40) * 0.05) * 15;
      path.moveTo(i, -height / 2);
      path.lineTo(i + yOffset, height / 2);
    }
    canvas.drawPath(path, gridPaint);

    // Render Sun/Horizon Disk
    final sunPaint = Paint()
      ..color = Colors.orangeAccent.withValues(alpha: 0.8 * activeOpacity)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(0, math.sin(timePhase) * 10 - 10), 35.0, sunPaint);

    // Render Glitch Transition Effect if enabled
    if (layer.transitionIn == 'glitch' && (currentTime - layer.startTime) < 0.5) {
      _renderGlitchEffect(canvas, rect, activeOpacity);
    }

    // Apply Vignette Overlay if set
    if (layer.vignette > 0.0) {
      _renderVignette(canvas, rect, layer.vignette * activeOpacity);
    }
  }

  static double _calculateTransitionOpacity(Layer layer, double currentTime) {
    final relTime = currentTime - layer.startTime;
    final remainingTime = layer.endTime - currentTime;
    const transitionDuration = 0.6;

    if (layer.transitionIn == 'fade' && relTime < transitionDuration) {
      return (relTime / transitionDuration).clamp(0.0, 1.0);
    }
    if (layer.transitionOut == 'fade' && remainingTime < transitionDuration) {
      return (remainingTime / transitionDuration).clamp(0.0, 1.0);
    }
    return 1.0;
  }

  static ColorFilter _createColorMatrixFilter({
    required double brightness,
    required double contrast,
    required double saturation,
    required String lutFilter,
  }) {
    // Standard Color Matrix calculation
    final b = brightness * 255;
    final c = contrast;
    final s = saturation;

    // Saturation weights
    final sr = (1 - s) * 0.2126;
    final sg = (1 - s) * 0.7152;
    final sb = (1 - s) * 0.0722;

    List<double> matrix = [
      (sr + s) * c, sg * c, sb * c, 0, b,
      sr * c, (sg + s) * c, sb * c, 0, b,
      sr * c, sg * c, (sb + s) * c, 0, b,
      0, 0, 0, 1, 0,
    ];

    if (lutFilter == 'cyberpunk') {
      matrix[0] *= 1.3; // Boost Red
      matrix[10] *= 1.4; // Boost Blue
    } else if (lutFilter == 'vintage') {
      matrix[0] *= 1.2;
      matrix[6] *= 1.1;
      matrix[10] *= 0.8;
    } else if (lutFilter == 'monochrome') {
      final greyR = 0.299;
      final greyG = 0.587;
      final greyB = 0.114;
      matrix = [
        greyR, greyG, greyB, 0, b,
        greyR, greyG, greyB, 0, b,
        greyR, greyG, greyB, 0, b,
        0, 0, 0, 1, 0,
      ];
    }

    return ColorFilter.matrix(matrix);
  }

  static void _renderGlitchEffect(Canvas canvas, Rect rect, double opacity) {
    final random = math.Random(1234);
    final glitchPaint = Paint()
      ..color = const Color(0xFFFF00FF).withValues(alpha: 0.5 * opacity)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final top = rect.top + random.nextDouble() * rect.height;
      final sliceHeight = random.nextDouble() * 15 + 5;
      final offset = (random.nextDouble() - 0.5) * 30;

      canvas.drawRect(
        Rect.fromLTWH(rect.left + offset, top, rect.width, sliceHeight),
        glitchPaint,
      );
    }
  }

  static void _renderVignette(Canvas canvas, Rect rect, double intensity) {
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: intensity.clamp(0.0, 0.95)),
        ],
        stops: const [0.5, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, vignettePaint);
  }
}
