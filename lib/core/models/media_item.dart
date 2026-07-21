import 'package:flutter/material.dart';

enum MediaType {
  video,
  audio,
  image,
  text,
  sticker,
  drawing,
  aiEffect,
}

class DrawingStroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final String brushType; // 'pencil', 'neon', 'marker', 'spray'

  DrawingStroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
    this.brushType = 'pencil',
  });

  DrawingStroke copyWith({
    List<Offset>? points,
    Color? color,
    double? strokeWidth,
    String? brushType,
  }) {
    return DrawingStroke(
      points: points ?? List.from(this.points),
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      brushType: brushType ?? this.brushType,
    );
  }
}

class MediaItem {
  final String id;
  final String name;
  final MediaType type;
  final String? assetPath;
  final Color color;
  
  // Text specific attributes
  final String? textContent;
  final String fontFamily;
  final double fontSize;
  final Color textColor;
  final Color? textBgColor;
  final Color textOutlineColor;
  final double textOutlineWidth;
  final bool textGradientEnabled;
  final String textAnimation; // 'none', 'typewriter', 'fade', 'bounce', 'slide'

  // Sticker specific attributes
  final String? stickerCategory; // 'procedural', 'emoji', 'badge', 'neon'
  final IconData? stickerIcon;
  final String? stickerSvgShape; // 'star', 'badge', 'heart', 'speech_bubble', 'arrow'

  // Drawing specific attributes
  final List<DrawingStroke> drawingStrokes;
  final bool animateDrawing; // replay drawing stroke by stroke

  // AI Effect specific attributes
  final String aiEffectType; // 'cyberpunk_anime', 'bg_remove', 'motion_blur', 'face_retouch', 'vhs_glitch'
  final double aiIntensity;

  // Video/Audio specific
  final double duration;
  final String? thumbnailPath;

  MediaItem({
    required this.id,
    required this.name,
    required this.type,
    this.assetPath,
    this.color = Colors.deepPurple,
    this.textContent,
    this.fontFamily = 'Roboto',
    this.fontSize = 24.0,
    this.textColor = Colors.white,
    this.textBgColor,
    this.textOutlineColor = Colors.black,
    this.textOutlineWidth = 0.0,
    this.textGradientEnabled = false,
    this.textAnimation = 'none',
    this.stickerCategory,
    this.stickerIcon,
    this.stickerSvgShape,
    List<DrawingStroke>? drawingStrokes,
    this.animateDrawing = true,
    this.aiEffectType = 'none',
    this.aiIntensity = 0.8,
    this.duration = 5.0,
    this.thumbnailPath,
  }) : drawingStrokes = drawingStrokes ?? [];

  MediaItem copyWith({
    String? id,
    String? name,
    MediaType? type,
    String? assetPath,
    Color? color,
    String? textContent,
    String? fontFamily,
    double? fontSize,
    Color? textColor,
    Color? textBgColor,
    Color? textOutlineColor,
    double? textOutlineWidth,
    bool? textGradientEnabled,
    String? textAnimation,
    String? stickerCategory,
    IconData? stickerIcon,
    String? stickerSvgShape,
    List<DrawingStroke>? drawingStrokes,
    bool? animateDrawing,
    String? aiEffectType,
    double? aiIntensity,
    double? duration,
    String? thumbnailPath,
  }) {
    return MediaItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      assetPath: assetPath ?? this.assetPath,
      color: color ?? this.color,
      textContent: textContent ?? this.textContent,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      textColor: textColor ?? this.textColor,
      textBgColor: textBgColor ?? this.textBgColor,
      textOutlineColor: textOutlineColor ?? this.textOutlineColor,
      textOutlineWidth: textOutlineWidth ?? this.textOutlineWidth,
      textGradientEnabled: textGradientEnabled ?? this.textGradientEnabled,
      textAnimation: textAnimation ?? this.textAnimation,
      stickerCategory: stickerCategory ?? this.stickerCategory,
      stickerIcon: stickerIcon ?? this.stickerIcon,
      stickerSvgShape: stickerSvgShape ?? this.stickerSvgShape,
      drawingStrokes: drawingStrokes ?? List.from(this.drawingStrokes),
      animateDrawing: animateDrawing ?? this.animateDrawing,
      aiEffectType: aiEffectType ?? this.aiEffectType,
      aiIntensity: aiIntensity ?? this.aiIntensity,
      duration: duration ?? this.duration,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }
}
