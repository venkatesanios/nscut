import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/models/layer.dart';

class DrawingCanvasEngine {
  static void renderDrawingLayer(Canvas canvas, Size canvasSize, Layer layer, double currentTime) {
    final media = layer.media;
    final strokes = media.drawingStrokes;
    if (strokes.isEmpty) return;

    final double relTime = currentTime - layer.startTime;
    final double animProgress = media.animateDrawing
        ? (relTime / (layer.duration * 0.8)).clamp(0.0, 1.0)
        : 1.0;

    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;

      final visibleCount = (stroke.points.length * animProgress).ceil();
      if (visibleCount <= 0) continue;

      final visiblePoints = stroke.points.sublist(0, visibleCount);

      if (stroke.brushType == 'neon') {
        _renderNeonBrush(canvas, visiblePoints, stroke.color, stroke.strokeWidth, layer.opacity);
      } else if (stroke.brushType == 'marker') {
        _renderMarkerBrush(canvas, visiblePoints, stroke.color, stroke.strokeWidth, layer.opacity);
      } else if (stroke.brushType == 'spray') {
        _renderSprayBrush(canvas, visiblePoints, stroke.color, stroke.strokeWidth, layer.opacity);
      } else {
        // Standard Pencil Brush
        _renderPencilBrush(canvas, visiblePoints, stroke.color, stroke.strokeWidth, layer.opacity);
      }
    }
  }

  static void _renderPencilBrush(Canvas canvas, List<Offset> points, Color color, double width, double opacity) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  static void _renderNeonBrush(Canvas canvas, List<Offset> points, Color color, double width, double opacity) {
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.6 * opacity)
      ..strokeWidth = width * 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

    final corePaint = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, corePaint);
  }

  static void _renderMarkerBrush(Canvas canvas, List<Offset> points, Color color, double width, double opacity) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.7 * opacity)
      ..strokeWidth = width * 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.bevel;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  static void _renderSprayBrush(Canvas canvas, List<Offset> points, Color color, double width, double opacity) {
    final sprayPaint = Paint()
      ..color = color.withValues(alpha: 0.5 * opacity)
      ..style = PaintingStyle.fill;

    final random = math.Random(5678);
    for (final p in points) {
      for (int i = 0; i < 12; i++) {
        final rx = p.dx + (random.nextDouble() - 0.5) * width * 2.5;
        final ry = p.dy + (random.nextDouble() - 0.5) * width * 2.5;
        final r = random.nextDouble() * 2.0 + 1.0;
        canvas.drawCircle(Offset(rx, ry), r, sprayPaint);
      }
    }
  }
}
