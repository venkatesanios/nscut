import 'package:flutter/material.dart';
import '../../core/models/timeline.dart';
import '../../core/theme/app_theme.dart';

class TopNavBar extends StatelessWidget {
  final TimelineState timeline;

  const TopNavBar({
    super.key,
    required this.timeline,
  });

  String _formatTimestamp(double seconds) {
    final int mins = seconds ~/ 60;
    final int secs = (seconds % 60).toInt();
    final int millis = ((seconds % 1) * 100).toInt();
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}.${millis.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: AppTheme.bgCard,
        border: Border(bottom: BorderSide(color: AppTheme.dividerColor, width: 1)),
      ),
      child: Row(
        children: [
          // App Brand & Logo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.accentPrimary, AppTheme.accentSecondary],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.movie_filter, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Text(
                'nscut',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accentPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppTheme.accentPrimary.withValues(alpha: 0.5)),
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(
                    color: AppTheme.accentSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          // Aspect Ratio Picker Menu
          PopupMenuButton<AspectRatioPreset>(
            initialValue: timeline.aspectRatio,
            tooltip: 'Aspect Ratio',
            onSelected: (ratio) => timeline.setAspectRatio(ratio),
            style: const ButtonStyle(
              visualDensity: VisualDensity.compact,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.bgSurface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.borderDark),
              ),
              child: Row(
                children: [
                  const Icon(Icons.aspect_ratio, size: 16, color: AppTheme.accentSecondary),
                  const SizedBox(width: 6),
                  Text(
                    timeline.aspectRatio.label,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
                  ),
                ],
              ),
            ),
            itemBuilder: (context) => AspectRatioPreset.values.map((preset) {
              return PopupMenuItem<AspectRatioPreset>(
                value: preset,
                child: Text(preset.label),
              );
            }).toList(),
          ),

          const SizedBox(width: 8),

          // Timecode Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.bgDark,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _formatTimestamp(timeline.currentTime),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: AppTheme.accentGold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Undo / Redo
          IconButton(
            icon: const Icon(Icons.undo, size: 20),
            color: timeline.canUndo ? AppTheme.textPrimary : AppTheme.textMuted,
            onPressed: timeline.canUndo ? () => timeline.undo() : null,
            tooltip: 'Undo',
          ),
          IconButton(
            icon: const Icon(Icons.redo, size: 20),
            color: timeline.canRedo ? AppTheme.textPrimary : AppTheme.textMuted,
            onPressed: timeline.canRedo ? () => timeline.redo() : null,
            tooltip: 'Redo',
          ),

          const SizedBox(width: 4),

          // Export Button
          ElevatedButton.icon(
            onPressed: () => timeline.setActiveModule('export'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.ios_share, size: 16),
            label: const Text('Export', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
