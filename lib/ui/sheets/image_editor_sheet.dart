import 'package:flutter/material.dart';
import '../../core/models/timeline.dart';
import '../../core/models/layer.dart';
import '../../core/models/media_item.dart';
import '../../core/theme/app_theme.dart';

class ImageEditorSheet extends StatelessWidget {
  final TimelineState timeline;

  const ImageEditorSheet({
    super.key,
    required this.timeline,
  });

  @override
  Widget build(BuildContext context) {
    final layer = timeline.selectedLayer;
    final isImage = layer != null && layer.type == MediaType.image;

    return Container(
      height: 270,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.image, color: AppTheme.layerImage, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Image & Photo Editing',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => timeline.setActiveModule(null),
              ),
            ],
          ),

          if (isImage) ...[
            // Chroma Key (Green Screen) Controls
            SwitchListTile(
              title: const Text('Chroma Key (Green Screen Removal)', style: TextStyle(fontSize: 12, color: AppTheme.textPrimary)),
              subtitle: const Text('Isolate and remove green background color', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
              value: layer.chromaKeyEnabled,
              activeTrackColor: AppTheme.accentGreen,
              onChanged: (val) => timeline.updateLayer(layer.copyWith(chromaKeyEnabled: val)),
            ),

            if (layer.chromaKeyEnabled) ...[
              Row(
                children: [
                  const SizedBox(width: 16),
                  const Text('Key Tolerance:', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                  Expanded(
                    child: Slider(
                      value: layer.chromaKeySimilarity,
                      min: 0.1,
                      max: 0.9,
                      activeColor: AppTheme.accentGreen,
                      onChanged: (val) => timeline.updateLayer(layer.copyWith(chromaKeySimilarity: val)),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 8),

            // Opacity Slider
            Row(
              children: [
                const SizedBox(width: 16),
                const Text('Layer Opacity:', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                Expanded(
                  child: Slider(
                    value: layer.opacity,
                    min: 0.0,
                    max: 1.0,
                    activeColor: AppTheme.layerImage,
                    onChanged: (val) => timeline.updateLayer(layer.copyWith(opacity: val)),
                  ),
                ),
                Text('${(layer.opacity * 100).toInt()}%', style: const TextStyle(fontSize: 11, color: AppTheme.accentGold)),
              ],
            ),
          ] else ...[
            const SizedBox(height: 12),
            const Text('Add Image Overlay to Timeline:', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAddImageCard(timeline, 'Neon Frame', const Color(0xFFFD79A8)),
                _buildAddImageCard(timeline, 'Logo Watermark', const Color(0xFF6C5CE7)),
                _buildAddImageCard(timeline, 'Chroma Subject', const Color(0xFF00B894)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddImageCard(TimelineState timeline, String title, Color color) {
    return InkWell(
      onTap: () {
        final id = 'image_${DateTime.now().millisecondsSinceEpoch}';
        timeline.addLayer(
          Layer(
            id: id,
            name: title,
            type: MediaType.image,
            media: MediaItem(
              id: 'media_$id',
              name: title,
              type: MediaType.image,
              color: color,
            ),
            startTime: timeline.currentTime,
            duration: 6.0,
            zIndex: timeline.layers.length,
          ),
        );
      },
        child: Container(
        width: 95,
        height: 110,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 28, color: color),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
