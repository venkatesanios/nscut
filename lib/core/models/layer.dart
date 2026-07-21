import 'package:flutter/material.dart';
import 'media_item.dart';

class Keyframe {
  final double time; // time offset relative to layer start
  final Offset position;
  final double scale;
  final double rotation;
  final double opacity;

  Keyframe({
    required this.time,
    required this.position,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.opacity = 1.0,
  });
}

class Layer {
  final String id;
  final String name;
  final MediaType type;
  final MediaItem media;

  // Timeline Timing
  final double startTime; // Seconds
  final double duration; // Seconds
  final double trimIn; // Internal trim start
  final double trimOut; // Internal trim end
  final double speed; // Playback speed modifier

  // Canvas Transform
  final Offset position; // Canvas relative offset (center 0,0)
  final double scale;
  final double rotation; // Radians
  final double opacity;
  final int zIndex;

  // Track State Flags
  final bool isLocked;
  final bool isVisible;
  final bool isMuted;
  final double volume; // 0.0 to 2.0

  // Color Grading & Effects
  final double brightness; // -1.0 to 1.0
  final double contrast; // 0.0 to 2.0
  final double saturation; // 0.0 to 2.0
  final double temperature; // -1.0 to 1.0
  final double vignette; // 0.0 to 1.0
  final String lutFilter; // 'none', 'cyberpunk', 'vintage', 'cinematic', 'monochrome', 'warm'

  // Chroma Key (Green Screen)
  final bool chromaKeyEnabled;
  final Color chromaKeyColor;
  final double chromaKeySimilarity;

  // Keyframes & Transitions
  final List<Keyframe> keyframes;
  final String transitionIn; // 'none', 'fade', 'dissolve', 'slide', 'zoom'
  final String transitionOut;

  Layer({
    required this.id,
    required this.name,
    required this.type,
    required this.media,
    required this.startTime,
    required this.duration,
    this.trimIn = 0.0,
    this.trimOut = 0.0,
    this.speed = 1.0,
    this.position = Offset.zero,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.opacity = 1.0,
    this.zIndex = 0,
    this.isLocked = false,
    this.isVisible = true,
    this.isMuted = false,
    this.volume = 1.0,
    this.brightness = 0.0,
    this.contrast = 1.0,
    this.saturation = 1.0,
    this.temperature = 0.0,
    this.vignette = 0.0,
    this.lutFilter = 'none',
    this.chromaKeyEnabled = false,
    this.chromaKeyColor = Colors.green,
    this.chromaKeySimilarity = 0.4,
    List<Keyframe>? keyframes,
    this.transitionIn = 'none',
    this.transitionOut = 'none',
  }) : keyframes = keyframes ?? [];

  double get endTime => startTime + duration;

  bool isVisibleAt(double currentTime) {
    if (!isVisible) return false;
    return currentTime >= startTime && currentTime < endTime;
  }

  Layer copyWith({
    String? id,
    String? name,
    MediaType? type,
    MediaItem? media,
    double? startTime,
    double? duration,
    double? trimIn,
    double? trimOut,
    double? speed,
    Offset? position,
    double? scale,
    double? rotation,
    double? opacity,
    int? zIndex,
    bool? isLocked,
    bool? isVisible,
    bool? isMuted,
    double? volume,
    double? brightness,
    double? contrast,
    double? saturation,
    double? temperature,
    double? vignette,
    String? lutFilter,
    bool? chromaKeyEnabled,
    Color? chromaKeyColor,
    double? chromaKeySimilarity,
    List<Keyframe>? keyframes,
    String? transitionIn,
    String? transitionOut,
  }) {
    return Layer(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      media: media ?? this.media,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      trimIn: trimIn ?? this.trimIn,
      trimOut: trimOut ?? this.trimOut,
      speed: speed ?? this.speed,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      opacity: opacity ?? this.opacity,
      zIndex: zIndex ?? this.zIndex,
      isLocked: isLocked ?? this.isLocked,
      isVisible: isVisible ?? this.isVisible,
      isMuted: isMuted ?? this.isMuted,
      volume: volume ?? this.volume,
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      saturation: saturation ?? this.saturation,
      temperature: temperature ?? this.temperature,
      vignette: vignette ?? this.vignette,
      lutFilter: lutFilter ?? this.lutFilter,
      chromaKeyEnabled: chromaKeyEnabled ?? this.chromaKeyEnabled,
      chromaKeyColor: chromaKeyColor ?? this.chromaKeyColor,
      chromaKeySimilarity: chromaKeySimilarity ?? this.chromaKeySimilarity,
      keyframes: keyframes ?? List.from(this.keyframes),
      transitionIn: transitionIn ?? this.transitionIn,
      transitionOut: transitionOut ?? this.transitionOut,
    );
  }
}
