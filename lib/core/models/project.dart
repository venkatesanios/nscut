import 'timeline.dart';

class Project {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final AspectRatioPreset aspectRatio;
  final ResolutionPreset resolution;
  final int fps;

  Project({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.aspectRatio = AspectRatioPreset.ratio16x9,
    this.resolution = ResolutionPreset.res1080p,
    this.fps = 30,
  });

  Project copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    AspectRatioPreset? aspectRatio,
    ResolutionPreset? resolution,
    int? fps,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      resolution: resolution ?? this.resolution,
      fps: fps ?? this.fps,
    );
  }
}
