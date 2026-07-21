import 'package:flutter/material.dart';
import '../core/models/layer.dart';

class TextEditorEngine {
  static void renderTextLayer(Canvas canvas, Size canvasSize, Layer layer, double currentTime) {
    final media = layer.media;
    final text = media.textContent ?? 'Sample Text';
    if (text.isEmpty) return;

    // Calculate Text Animation substring/opacity
    final String displayText = _getAnimatedTextContent(text, media.textAnimation, layer, currentTime);
    final double animOpacity = _getAnimatedOpacity(media.textAnimation, layer, currentTime) * layer.opacity;

    if (displayText.isEmpty || animOpacity <= 0) return;

    final textStyle = TextStyle(
      fontSize: media.fontSize,
      fontFamily: media.fontFamily,
      fontWeight: FontWeight.bold,
      color: media.textGradientEnabled
          ? Colors.white
          : media.textColor.withValues(alpha: animOpacity),
      shadows: [
        Shadow(
          blurRadius: 8.0,
          color: Colors.black.withValues(alpha: 0.8 * animOpacity),
          offset: const Offset(2.0, 2.0),
        ),
      ],
    );

    // Text Painter
    final textPainter = TextPainter(
      text: TextSpan(text: displayText, style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();

    final textOffset = Offset(-textPainter.width / 2, -textPainter.height / 2);

    // Optional Background Box
    if (media.textBgColor != null) {
      final bgRect = Rect.fromLTWH(
        textOffset.dx - 12,
        textOffset.dy - 6,
        textPainter.width + 24,
        textPainter.height + 12,
      );
      final bgPaint = Paint()
        ..color = media.textBgColor!.withValues(alpha: 0.85 * animOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(RRect.fromRectAndRadius(bgRect, const Radius.circular(8)), bgPaint);
    }

    // Optional Outline Stroke
    if (media.textOutlineWidth > 0) {
      final strokePainter = TextPainter(
        text: TextSpan(
          text: displayText,
          style: TextStyle(
            fontSize: media.fontSize,
            fontFamily: media.fontFamily,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = media.textOutlineWidth
              ..color = media.textOutlineColor.withValues(alpha: animOpacity),
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      strokePainter.layout();
      strokePainter.paint(canvas, textOffset);
    }

    // Gradient Text Fill Shader
    if (media.textGradientEnabled) {
      final rect = Rect.fromLTWH(textOffset.dx, textOffset.dy, textPainter.width, textPainter.height);
      final gradientPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF00CEC9).withValues(alpha: animOpacity),
            const Color(0xFF6C5CE7).withValues(alpha: animOpacity),
            const Color(0xFFFF7675).withValues(alpha: animOpacity),
          ],
        ).createShader(rect);

      final gradientPainter = TextPainter(
        text: TextSpan(
          text: displayText,
          style: TextStyle(
            fontSize: media.fontSize,
            fontFamily: media.fontFamily,
            fontWeight: FontWeight.bold,
            foreground: gradientPaint,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      gradientPainter.layout();
      gradientPainter.paint(canvas, textOffset);
    } else {
      textPainter.paint(canvas, textOffset);
    }
  }

  static String _getAnimatedTextContent(String fullText, String animType, Layer layer, double currentTime) {
    if (animType != 'typewriter') return fullText;
    final relTime = currentTime - layer.startTime;
    const charRateSeconds = 0.08; // 12 chars per sec
    final charCount = (relTime / charRateSeconds).floor().clamp(0, fullText.length);
    return fullText.substring(0, charCount);
  }

  static double _getAnimatedOpacity(String animType, Layer layer, double currentTime) {
    if (animType != 'fade') return 1.0;
    final relTime = currentTime - layer.startTime;
    const fadeDuration = 0.8;
    return (relTime / fadeDuration).clamp(0.0, 1.0);
  }
}
