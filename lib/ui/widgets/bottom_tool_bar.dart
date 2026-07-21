import 'package:flutter/material.dart';
import '../../core/models/timeline.dart';
import '../../core/theme/app_theme.dart';

class BottomToolBar extends StatelessWidget {
  final TimelineState timeline;

  const BottomToolBar({
    super.key,
    required this.timeline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: AppTheme.bgCard,
        border: Border(top: BorderSide(color: AppTheme.dividerColor, width: 1)),
      ),
      child: Column(
        children: [
          // Context Action Bar (Split, Duplicate, Delete when layer is selected)
          if (timeline.selectedLayer != null)
            Container(
              height: 28,
              color: AppTheme.bgSurface,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Text(
                    'Selected: ${timeline.selectedLayer!.name}',
                    style: const TextStyle(fontSize: 11, color: AppTheme.accentGold, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => timeline.splitSelectedLayer(),
                    child: const Row(
                      children: [
                        Icon(Icons.call_split, size: 14, color: AppTheme.textPrimary),
                        SizedBox(width: 4),
                        Text('Split', style: TextStyle(fontSize: 11, color: AppTheme.textPrimary)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: () => timeline.duplicateSelectedLayer(),
                    child: const Row(
                      children: [
                        Icon(Icons.copy, size: 14, color: AppTheme.textPrimary),
                        SizedBox(width: 4),
                        Text('Duplicate', style: TextStyle(fontSize: 11, color: AppTheme.textPrimary)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: () => timeline.removeLayer(timeline.selectedLayerId!),
                    child: const Row(
                      children: [
                        Icon(Icons.delete_outline, size: 14, color: AppTheme.accentPink),
                        SizedBox(width: 4),
                        Text('Delete', style: TextStyle(fontSize: 11, color: AppTheme.accentPink)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Main 8 Modules Selector Row
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  _buildToolButton(
                    context: context,
                    id: 'video',
                    label: 'Video',
                    icon: Icons.movie_creation_outlined,
                    color: AppTheme.layerVideo,
                  ),
                  _buildToolButton(
                    context: context,
                    id: 'audio',
                    label: 'Audio',
                    icon: Icons.graphic_eq,
                    color: AppTheme.layerAudio,
                  ),
                  _buildToolButton(
                    context: context,
                    id: 'image',
                    label: 'Image',
                    icon: Icons.filter_hdr,
                    color: AppTheme.layerImage,
                  ),
                  _buildToolButton(
                    context: context,
                    id: 'sticker',
                    label: 'Stickers',
                    icon: Icons.auto_awesome,
                    color: AppTheme.layerSticker,
                  ),
                  _buildToolButton(
                    context: context,
                    id: 'text',
                    label: 'Text Editor',
                    icon: Icons.text_fields,
                    color: AppTheme.layerText,
                  ),
                  _buildToolButton(
                    context: context,
                    id: 'drawing',
                    label: 'Drawing',
                    icon: Icons.gesture,
                    color: AppTheme.layerDrawing,
                  ),
                  _buildToolButton(
                    context: context,
                    id: 'ai',
                    label: 'AI Effects',
                    icon: Icons.psychology,
                    color: AppTheme.layerAI,
                  ),
                  _buildToolButton(
                    context: context,
                    id: 'export',
                    label: 'Export',
                    icon: Icons.file_upload_outlined,
                    color: AppTheme.accentSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required BuildContext context,
    required String id,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final bool isActive = timeline.activeModule == id;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () {
          timeline.setActiveModule(isActive ? null : id);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 68,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isActive ? color.withValues(alpha: 0.25) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: isActive ? color : AppTheme.textSecondary),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? color : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
