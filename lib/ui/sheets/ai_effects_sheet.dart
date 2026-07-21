import 'package:flutter/material.dart';
import '../../core/models/timeline.dart';
import '../../core/models/layer.dart';
import '../../core/models/media_item.dart';
import '../../core/theme/app_theme.dart';

class AIEffectsSheet extends StatelessWidget {
  final TimelineState timeline;

  const AIEffectsSheet({
    super.key,
    required this.timeline,
  });

  @override
  Widget build(BuildContext context) {
    final layer = timeline.selectedLayer;
    final isAIEffect = layer != null && layer.type == MediaType.aiEffect;

    return Container(
      height: 310,
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
              const Icon(Icons.psychology, color: AppTheme.layerAI, size: 20),
              const SizedBox(width: 8),
              const Text(
                'AI Special Effects & Neural Matting',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => timeline.setActiveModule(null),
              ),
            ],
          ),

          if (isAIEffect) ...[
            const SizedBox(height: 8),
            Text('Editing AI Effect: ${layer.name}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 12),

            Row(
              children: [
                const SizedBox(width: 8),
                const Text('Effect Intensity:', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                Expanded(
                  child: Slider(
                    value: layer.media.aiIntensity,
                    min: 0.1,
                    max: 1.0,
                    activeColor: AppTheme.layerAI,
                    onChanged: (val) => timeline.updateLayer(
                      layer.copyWith(media: layer.media.copyWith(aiIntensity: val)),
                    ),
                  ),
                ),
                Text('${(layer.media.aiIntensity * 100).toInt()}%', style: const TextStyle(fontSize: 11, color: AppTheme.accentGold)),
              ],
            ),
          ] else ...[
            const SizedBox(height: 8),
            const Text('Apply AI Neural Effect Layer:', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 12),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 2.8,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildAIEffectCard(timeline, 'Cyberpunk Anime', 'cyberpunk_anime', Icons.auto_fix_high),
                  _buildAIEffectCard(timeline, 'AI BG Removal', 'bg_remove', Icons.person_remove),
                  _buildAIEffectCard(timeline, 'Motion Tracking', 'motion_blur', Icons.scatter_plot),
                  _buildAIEffectCard(timeline, 'VHS Glitch Overlay', 'vhs_glitch', Icons.vignette),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAIEffectCard(TimelineState timeline, String title, String effectType, IconData icon) {
    return InkWell(
      onTap: () {
        final id = 'ai_${DateTime.now().millisecondsSinceEpoch}';
        timeline.addLayer(
          Layer(
            id: id,
            name: title,
            type: MediaType.aiEffect,
            media: MediaItem(
              id: 'media_$id',
              name: title,
              type: MediaType.aiEffect,
              aiEffectType: effectType,
              aiIntensity: 0.8,
            ),
            startTime: timeline.currentTime,
            duration: 6.0,
            opacity: 0.85,
            zIndex: timeline.layers.length,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.bgSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.layerAI.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppTheme.layerAI),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
