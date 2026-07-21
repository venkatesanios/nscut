import 'package:flutter/material.dart';
import '../../core/models/timeline.dart';
import '../../core/models/layer.dart';
import '../../core/models/media_item.dart';
import '../../core/theme/app_theme.dart';

class StickerGeneratorSheet extends StatelessWidget {
  final TimelineState timeline;

  const StickerGeneratorSheet({
    super.key,
    required this.timeline,
  });

  @override
  Widget build(BuildContext context) {
    final layer = timeline.selectedLayer;
    final isSticker = layer != null && layer.type == MediaType.sticker;

    return Container(
      height: 290,
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
              const Icon(Icons.auto_awesome, color: AppTheme.layerSticker, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Procedural Sticker Generator',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => timeline.setActiveModule(null),
              ),
            ],
          ),

          if (isSticker) ...[
            const SizedBox(height: 8),
            Text('Editing Sticker: ${layer.name}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 12),

            Row(
              children: [
                const SizedBox(width: 8),
                const Text('Scale:', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                Expanded(
                  child: Slider(
                    value: layer.scale,
                    min: 0.3,
                    max: 3.0,
                    activeColor: AppTheme.layerSticker,
                    onChanged: (val) => timeline.updateLayer(layer.copyWith(scale: val)),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const SizedBox(width: 8),
                const Text('Rotation:', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                Expanded(
                  child: Slider(
                    value: layer.rotation,
                    min: -3.14,
                    max: 3.14,
                    activeColor: AppTheme.layerSticker,
                    onChanged: (val) => timeline.updateLayer(layer.copyWith(rotation: val)),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 8),
            const Text('Generate & Add Animated Vector Sticker:', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 12),

            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildStickerPresetTile(timeline, 'Star Badge', 'star', Icons.auto_awesome),
                  _buildStickerPresetTile(timeline, 'Neon Heart', 'heart', Icons.favorite),
                  _buildStickerPresetTile(timeline, 'PRO Tag', 'badge', Icons.verified),
                  _buildStickerPresetTile(timeline, 'Flame Icon', 'circle', Icons.local_fire_department),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStickerPresetTile(TimelineState timeline, String name, String shape, IconData icon) {
    return InkWell(
      onTap: () {
        final id = 'sticker_${DateTime.now().millisecondsSinceEpoch}';
        timeline.addLayer(
          Layer(
            id: id,
            name: name,
            type: MediaType.sticker,
            media: MediaItem(
              id: 'media_$id',
              name: name,
              type: MediaType.sticker,
              stickerCategory: 'procedural',
              stickerSvgShape: shape,
              stickerIcon: icon,
            ),
            startTime: timeline.currentTime,
            duration: 5.0,
            zIndex: timeline.layers.length,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.bgSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.layerSticker.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: AppTheme.layerSticker),
            const SizedBox(height: 4),
            Text(name, style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
