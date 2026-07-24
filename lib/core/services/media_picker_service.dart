import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/timeline.dart';
import '../models/layer.dart';
import '../models/media_item.dart';
import '../theme/app_theme.dart';

class MediaPickerService {
  static Future<void> pickMedia(BuildContext context, TimelineState timeline, {MediaType? filterType}) async {
    FileType fileType = FileType.custom;
    List<String>? allowedExtensions;

    if (filterType == MediaType.video) {
      fileType = FileType.video;
    } else if (filterType == MediaType.audio) {
      fileType = FileType.audio;
    } else if (filterType == MediaType.image) {
      fileType = FileType.image;
    } else {
      // Allow common media types if no specific filter
      allowedExtensions = ['mp4', 'mov', 'avi', 'mkv', 'mp3', 'wav', 'm4a', 'jpg', 'jpeg', 'png', 'webp'];
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: fileType,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        for (var file in result.files) {
          _importFile(context, timeline, file);
        }
      }
    } catch (e) {
      debugPrint('Error picking files: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to open gallery or pick files.')),
        );
      }
    }
  }

  static void _importFile(BuildContext context, TimelineState timeline, PlatformFile file) {
    final String id = 'real_${DateTime.now().millisecondsSinceEpoch}_${file.name.hashCode}';
    final String name = file.name;
    final String? extension = file.extension?.toLowerCase();
    
    MediaType mediaType = MediaType.image; // Default
    Color layerColor = AppTheme.layerImage;
    double duration = 5.0; // Default duration for images

    if (['mp4', 'mov', 'avi', 'mkv'].contains(extension)) {
      mediaType = MediaType.video;
      layerColor = AppTheme.layerVideo;
      duration = 10.0; // Placeholder: Real apps should extract duration via video_player or ffmpeg
    } else if (['mp3', 'wav', 'm4a'].contains(extension)) {
      mediaType = MediaType.audio;
      layerColor = AppTheme.layerAudio;
      duration = 15.0; // Placeholder
    }

    final newLayer = Layer(
      id: id,
      name: name.split('.').first,
      type: mediaType,
      media: MediaItem(
        id: 'media_$id',
        name: name,
        type: mediaType,
        assetPath: file.path, // Store the local path
        color: layerColor,
        duration: duration,
      ),
      startTime: timeline.currentTime,
      duration: duration,
      zIndex: timeline.layers.length,
    );

    timeline.addLayer(newLayer);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Imported "$name"'),
          backgroundColor: AppTheme.bgSurface,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
