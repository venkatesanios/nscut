import 'package:flutter/material.dart';
import '../../core/models/timeline.dart';
import '../../core/models/layer.dart';
import '../../core/models/media_item.dart';
import '../../core/theme/app_theme.dart';
import '../../engine/audio_editing_engine.dart';

class AudioEditorSheet extends StatefulWidget {
  final TimelineState timeline;

  const AudioEditorSheet({
    super.key,
    required this.timeline,
  });

  @override
  State<AudioEditorSheet> createState() => _AudioEditorSheetState();
}

class _AudioEditorSheetState extends State<AudioEditorSheet> {
  String _selectedEq = 'Bass Boost';

  @override
  Widget build(BuildContext context) {
    final timeline = widget.timeline;
    final selectedLayer = timeline.selectedLayer;
    final isAudioSelected = selectedLayer != null && selectedLayer.type == MediaType.audio;

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sheet Header
          Row(
            children: [
              const Icon(Icons.graphic_eq, color: AppTheme.layerAudio, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Audio Editing & Mixer',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => timeline.setActiveModule(null),
              ),
            ],
          ),

          if (isAudioSelected) ...[
            // Volume Gain & Mute
            Row(
              children: [
                IconButton(
                  icon: Icon(selectedLayer.isMuted ? Icons.volume_off : Icons.volume_up, color: AppTheme.layerAudio),
                  onPressed: () => timeline.updateLayer(selectedLayer.copyWith(isMuted: !selectedLayer.isMuted)),
                ),
                Expanded(
                  child: Slider(
                    value: selectedLayer.volume,
                    min: 0.0,
                    max: 2.0,
                    activeColor: AppTheme.layerAudio,
                    onChanged: (val) => timeline.updateLayer(selectedLayer.copyWith(volume: val)),
                  ),
                ),
                Text(
                  '${(selectedLayer.volume * 100).toInt()}%',
                  style: const TextStyle(fontSize: 12, color: AppTheme.accentGold, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            // Equalizer Spectrum Visualizer
            const SizedBox(height: 8),
            const Text('Graphic Equalizer Presets:', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            const SizedBox(height: 6),

            Row(
              children: ['Flat', 'Bass Boost', 'Vocal Enhancer', 'Treble Boost'].map((eq) {
                final isSelected = _selectedEq == eq;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(eq, style: TextStyle(fontSize: 10, color: isSelected ? Colors.black : Colors.white)),
                    selected: isSelected,
                    selectedColor: AppTheme.layerAudio,
                    backgroundColor: AppTheme.bgSurface,
                    onSelected: (val) {
                      if (val) setState(() => _selectedEq = eq);
                    },
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 8),

            // Equalizer Bands Simulation
            SizedBox(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: AudioEditingEngine.getEqualizerSpectrum(_selectedEq, timeline.currentTime).map((val) {
                  return Container(
                    width: 12,
                    height: 40 * val,
                    decoration: BoxDecoration(
                      color: AppTheme.layerAudio.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }).toList(),
              ),
            ),
          ] else ...[
            // Add Audio Track Options
            const SizedBox(height: 12),
            const Text('Add Soundtrack to Project:', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 12),

            Expanded(
              child: ListView(
                children: [
                  _buildAddSoundtrackTile(timeline, 'Synthwave Beats', 'Upbeat Cyber Synth', 15.0),
                  _buildAddSoundtrackTile(timeline, 'Midnight Highway FX', 'Cinematic Car Engine', 10.0),
                  _buildAddSoundtrackTile(timeline, 'Lofi Chill Vibes', 'Relaxing Ambient Beat', 18.0),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddSoundtrackTile(TimelineState timeline, String title, String subtitle, double duration) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppTheme.layerAudio.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
        child: const Icon(Icons.music_note, color: AppTheme.layerAudio),
      ),
      title: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
      subtitle: Text('$subtitle • ${duration.toInt()}s', style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
      trailing: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.layerAudio, foregroundColor: Colors.black),
        child: const Text('Add Track', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        onPressed: () {
          final id = 'audio_${DateTime.now().millisecondsSinceEpoch}';
          timeline.addLayer(
            Layer(
              id: id,
              name: title,
              type: MediaType.audio,
              media: MediaItem(
                id: 'media_$id',
                name: title,
                type: MediaType.audio,
                color: AppTheme.layerAudio,
                duration: duration,
              ),
              startTime: timeline.currentTime,
              duration: duration,
              zIndex: timeline.layers.length,
            ),
          );
        },
      ),
    );
  }
}
