import 'package:flutter/material.dart';
import '../../core/models/timeline.dart';
import '../../core/theme/app_theme.dart';
import '../../engine/export_engine.dart';

class ExportEngineSheet extends StatefulWidget {
  final TimelineState timeline;
  final ExportEngine exportEngine;

  const ExportEngineSheet({
    super.key,
    required this.timeline,
    required this.exportEngine,
  });

  @override
  State<ExportEngineSheet> createState() => _ExportEngineSheetState();
}

class _ExportEngineSheetState extends State<ExportEngineSheet> {
  String _selectedFormat = 'mp4';

  @override
  Widget build(BuildContext context) {
    final timeline = widget.timeline;
    return ListenableBuilder(
      listenable: widget.exportEngine,
      builder: (context, _) {
        final state = widget.exportEngine.state;

        return Container(
          height: 360,
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
                  const Icon(Icons.file_upload_outlined, color: AppTheme.accentSecondary, size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    'Export & Render Engine',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => timeline.setActiveModule(null),
                  ),
                ],
              ),

              if (state.isExporting) ...[
                // Export Progress View
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: state.progress,
                      strokeWidth: 6,
                      backgroundColor: AppTheme.bgSurface,
                      color: AppTheme.accentSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    '${(state.progress * 100).toInt()}%',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.accentGold),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    state.statusMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ),
                const Spacer(),
                Center(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(foregroundColor: AppTheme.accentPink),
                    onPressed: () => widget.exportEngine.cancelExport(),
                    child: const Text('Cancel Export'),
                  ),
                ),
              ] else if (state.exportFilePath != null) ...[
                // Export Success Dialog View
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.accentGreen),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle, color: AppTheme.accentGreen, size: 40),
                      const SizedBox(height: 8),
                      const Text(
                        'Video Successfully Rendered!',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Saved to: ${state.exportFilePath}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentSecondary, foregroundColor: Colors.black),
                      icon: const Icon(Icons.share, size: 16),
                      label: const Text('Share Video'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Video ready to share!')),
                        );
                      },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.bgSurface),
                      child: const Text('Close'),
                      onPressed: () => timeline.setActiveModule(null),
                    ),
                  ],
                ),
              ] else ...[
                // Resolution Selector
                const Text('Output Resolution:', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                const SizedBox(height: 6),
                Row(
                  children: ResolutionPreset.values.map((res) {
                    final isSelected = timeline.resolution == res;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(res.label, style: TextStyle(fontSize: 10, color: isSelected ? Colors.black : Colors.white)),
                        selected: isSelected,
                        selectedColor: AppTheme.accentSecondary,
                        backgroundColor: AppTheme.bgSurface,
                        onSelected: (val) {
                          if (val) timeline.setResolution(res);
                        },
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 12),

                // FPS Selector & Format
                Row(
                  children: [
                    const Text('Frame Rate:', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: timeline.fps,
                      dropdownColor: AppTheme.bgSurface,
                      items: const [
                        DropdownMenuItem(value: 24, child: Text('24 FPS (Film)')),
                        DropdownMenuItem(value: 30, child: Text('30 FPS (Standard)')),
                        DropdownMenuItem(value: 60, child: Text('60 FPS (Smooth)')),
                      ],
                      onChanged: (val) => timeline.setFps(val!),
                    ),
                    const Spacer(),
                    const Text('Format:', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _selectedFormat,
                      dropdownColor: AppTheme.bgSurface,
                      items: const [
                        DropdownMenuItem(value: 'mp4', child: Text('MP4 (H.264)')),
                        DropdownMenuItem(value: 'gif', child: Text('Animated GIF')),
                        DropdownMenuItem(value: 'prores', child: Text('ProRes 422')),
                      ],
                      onChanged: (val) => setState(() => _selectedFormat = val!),
                    ),
                  ],
                ),

                const Spacer(),

                // Start Export Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.movie_creation, size: 20),
                    label: Text(
                      'START RENDER (${timeline.resolution.label} @ ${timeline.fps}fps)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    onPressed: () {
                      widget.exportEngine.startExport(
                        timeline: timeline,
                        resolution: timeline.resolution,
                        fps: timeline.fps,
                        format: _selectedFormat,
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
