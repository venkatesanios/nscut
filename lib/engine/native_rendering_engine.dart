import 'package:flutter/material.dart';
import '../core/models/layer.dart';
import '../core/models/media_item.dart';
import '../core/models/timeline.dart';
import 'video_editing_engine.dart';
import 'text_editor_engine.dart';
import 'sticker_generator_engine.dart';
import 'drawing_canvas_engine.dart';
import 'ai_effects_engine.dart';
import 'image_editing_engine.dart';

class NativeRenderingEngine {
  /// Core native canvas rendering function called frame-by-frame
  static void renderFrame({
    required Canvas canvas,
    required Size size,
    required List<Layer> layers,
    required double currentTime,
    required AspectRatioPreset aspectRatio,
    String? selectedLayerId,
  }) {
    // 1. Calculate Viewport & Aspect Ratio Clip Rect
    final double targetRatio = aspectRatio.value;
    final Size canvasSize = _calculateCanvasViewportSize(size, targetRatio);
    final Offset canvasOffset = Offset(
      (size.width - canvasSize.width) / 2,
      (size.height - canvasSize.height) / 2,
    );

    // Render Canvas Dark Background & Grid Backdrop
    final bgPaint = Paint()..color = const Color(0xFF000000);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    canvas.save();
    canvas.translate(canvasOffset.dx, canvasOffset.dy);
    canvas.clipRect(Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height));

    // Fill project viewport background
    final viewportPaint = Paint()..color = const Color(0xFF11141C);
    canvas.drawRect(Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height), viewportPaint);

    // 2. Render Layers in Z-Index Order
    final sortedLayers = List<Layer>.from(layers);
    sortedLayers.sort((a, b) => a.zIndex.compareTo(b.zIndex));

    for (final layer in sortedLayers) {
      if (!layer.isVisibleAt(currentTime)) continue;

      canvas.save();
      _applyLayerTransform(canvas, canvasSize, layer);

      // Render layer according to its type
      switch (layer.type) {
        case MediaType.video:
          VideoEditingEngine.renderVideoLayer(canvas, canvasSize, layer, currentTime);
          break;
        case MediaType.image:
          ImageEditingEngine.renderImageLayer(canvas, canvasSize, layer, currentTime);
          break;
        case MediaType.text:
          TextEditorEngine.renderTextLayer(canvas, canvasSize, layer, currentTime);
          break;
        case MediaType.sticker:
          StickerGeneratorEngine.renderStickerLayer(canvas, canvasSize, layer, currentTime);
          break;
        case MediaType.drawing:
          DrawingCanvasEngine.renderDrawingLayer(canvas, canvasSize, layer, currentTime);
          break;
        case MediaType.aiEffect:
          AIEffectsEngine.renderAIEffectLayer(canvas, canvasSize, layer, currentTime);
          break;
        case MediaType.audio:
          // Audio tracks are audio only (waveform rendered on timeline)
          break;
      }

      // Draw Selection Bounding Box & Handles if selected
      if (layer.id == selectedLayerId) {
        _renderSelectionOverlay(canvas, canvasSize, layer);
      }

      canvas.restore();
    }

    canvas.restore();

    // 3. Outer Viewport Mask (Letterboxing)
    _renderViewportLetterbox(canvas, size, canvasOffset, canvasSize);
  }

  static Size _calculateCanvasViewportSize(Size size, double targetRatio) {
    double width = size.width;
    double height = width / targetRatio;

    if (height > size.height) {
      height = size.height;
      width = height * targetRatio;
    }
    return Size(width, height);
  }

  static void _applyLayerTransform(Canvas canvas, Size canvasSize, Layer layer) {
    final center = Offset(
      canvasSize.width / 2 + (layer.position.dx * canvasSize.width / 2),
      canvasSize.height / 2 + (layer.position.dy * canvasSize.height / 2),
    );

    canvas.translate(center.dx, center.dy);
    if (layer.rotation != 0) {
      canvas.rotate(layer.rotation);
    }
    if (layer.scale != 1.0) {
      canvas.scale(layer.scale, layer.scale);
    }
  }

  static void _renderSelectionOverlay(Canvas canvas, Size canvasSize, Layer layer) {
    final borderPaint = Paint()
      ..color = const Color(0xFF6C5CE7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final handlePaint = Paint()
      ..color = const Color(0xFF00CEC9)
      ..style = PaintingStyle.fill;

    // Approximate boundary rect around selected layer center
    const double w = 140.0;
    const double h = 90.0;
    final rect = Rect.fromCenter(center: Offset.zero, width: w, height: h);

    canvas.drawRect(rect, borderPaint);

    // Corner Handles
    final handleCorners = [
      rect.topLeft,
      rect.topRight,
      rect.bottomLeft,
      rect.bottomRight,
    ];

    for (final corner in handleCorners) {
      canvas.drawCircle(corner, 5.0, handlePaint);
      canvas.drawCircle(corner, 5.0, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.5);
    }
  }

  static void _renderViewportLetterbox(Canvas canvas, Size size, Offset offset, Size canvasSize) {
    final maskPaint = Paint()..color = const Color(0xDD080A0E);

    // Top / Bottom letterbox
    if (offset.dy > 0) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, offset.dy), maskPaint);
      canvas.drawRect(Rect.fromLTWH(0, offset.dy + canvasSize.height, size.width, offset.dy), maskPaint);
    }
    // Left / Right letterbox
    if (offset.dx > 0) {
      canvas.drawRect(Rect.fromLTWH(0, 0, offset.dx, size.height), maskPaint);
      canvas.drawRect(Rect.fromLTWH(offset.dx + canvasSize.width, 0, offset.dx, size.height), maskPaint);
    }

    // Canvas Border Outline
    final borderPaint = Paint()
      ..color = const Color(0xFF2F3542)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(Rect.fromLTWH(offset.dx, offset.dy, canvasSize.width, canvasSize.height), borderPaint);
  }
}
