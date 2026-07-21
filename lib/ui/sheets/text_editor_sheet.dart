import 'package:flutter/material.dart';
import '../../core/models/timeline.dart';
import '../../core/models/layer.dart';
import '../../core/models/media_item.dart';
import '../../core/theme/app_theme.dart';

class TextEditorSheet extends StatefulWidget {
  final TimelineState timeline;

  const TextEditorSheet({
    super.key,
    required this.timeline,
  });

  @override
  State<TextEditorSheet> createState() => _TextEditorSheetState();
}

class _TextEditorSheetState extends State<TextEditorSheet> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    final layer = widget.timeline.selectedLayer;
    _textController = TextEditingController(
      text: layer?.media.textContent ?? 'NSCUT PRO VIDEO',
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeline = widget.timeline;
    final selectedLayer = timeline.selectedLayer;
    final isTextSelected = selectedLayer != null && selectedLayer.type == MediaType.text;

    return Container(
      height: 340,
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
              const Icon(Icons.text_fields, color: AppTheme.layerText, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Text Editor & Captions',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => timeline.setActiveModule(null),
              ),
            ],
          ),

          // Text Input Field
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Enter text here...',
                    hintStyle: const TextStyle(color: AppTheme.textMuted),
                    filled: true,
                    fillColor: AppTheme.bgSurface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                  onChanged: (val) {
                    if (isTextSelected) {
                      timeline.updateLayer(
                        selectedLayer.copyWith(media: selectedLayer.media.copyWith(textContent: val)),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              if (!isTextSelected)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.layerText, foregroundColor: Colors.black),
                  child: const Text('Add Text', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    final id = 'text_${DateTime.now().millisecondsSinceEpoch}';
                    timeline.addLayer(
                      Layer(
                        id: id,
                        name: _textController.text.isEmpty ? 'Text Clip' : _textController.text,
                        type: MediaType.text,
                        media: MediaItem(
                          id: 'media_$id',
                          name: 'Text',
                          type: MediaType.text,
                          textContent: _textController.text.isEmpty ? 'NSCUT CINEMATIC' : _textController.text,
                          fontSize: 32.0,
                          textColor: AppTheme.accentSecondary,
                          textGradientEnabled: true,
                          textOutlineColor: Colors.black,
                          textOutlineWidth: 2.0,
                          textAnimation: 'typewriter',
                        ),
                        startTime: timeline.currentTime,
                        duration: 5.0,
                        zIndex: timeline.layers.length,
                      ),
                    );
                  },
                ),
            ],
          ),

          const SizedBox(height: 12),

          if (isTextSelected) ...[
            // Font Size & Outline Sliders
            Row(
              children: [
                const SizedBox(width: 4),
                const Text('Size:', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                Expanded(
                  child: Slider(
                    value: selectedLayer.media.fontSize,
                    min: 14.0,
                    max: 72.0,
                    activeColor: AppTheme.layerText,
                    onChanged: (val) => timeline.updateLayer(
                      selectedLayer.copyWith(media: selectedLayer.media.copyWith(fontSize: val)),
                    ),
                  ),
                ),
              ],
            ),

            // Gradient Toggle & Animation Type
            Row(
              children: [
                const Text('Gradient Fill:', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                Switch(
                  value: selectedLayer.media.textGradientEnabled,
                  activeTrackColor: AppTheme.accentSecondary,
                  onChanged: (val) => timeline.updateLayer(
                    selectedLayer.copyWith(media: selectedLayer.media.copyWith(textGradientEnabled: val)),
                  ),
                ),
                const Spacer(),
                const Text('Animation:', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: selectedLayer.media.textAnimation,
                  dropdownColor: AppTheme.bgSurface,
                  items: const [
                    DropdownMenuItem(value: 'none', child: Text('NONE')),
                    DropdownMenuItem(value: 'typewriter', child: Text('TYPEWRITER')),
                    DropdownMenuItem(value: 'fade', child: Text('FADE IN')),
                  ],
                  onChanged: (val) => timeline.updateLayer(
                    selectedLayer.copyWith(media: selectedLayer.media.copyWith(textAnimation: val!)),
                  ),
                ),
              ],
            ),
          ] else ...[
            // AI Auto Captioning Generator Button
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.bgSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.accentPrimary.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppTheme.accentGold),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AI Auto-Subtitles & Captions', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('Automatically generate speech captions', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentPrimary),
                    onPressed: () {
                      final id = 'caption_${DateTime.now().millisecondsSinceEpoch}';
                      timeline.addLayer(
                        Layer(
                          id: id,
                          name: 'AI Subtitle',
                          type: MediaType.text,
                          media: MediaItem(
                            id: 'media_$id',
                            name: 'Subtitle',
                            type: MediaType.text,
                            textContent: '✨ Auto-generated AI Subtitle ✨',
                            fontSize: 24.0,
                            textColor: Colors.yellowAccent,
                            textOutlineWidth: 2.0,
                          ),
                          startTime: timeline.currentTime,
                          duration: 4.0,
                          position: const Offset(0.0, 0.7),
                          zIndex: timeline.layers.length,
                        ),
                      );
                    },
                    child: const Text('Generate', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
