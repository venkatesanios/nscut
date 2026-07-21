import 'package:flutter/material.dart';
import '../../core/models/timeline.dart';
import '../../core/models/layer.dart';
import '../../core/theme/app_theme.dart';

class VideoEditorSheet extends StatelessWidget {
  final TimelineState timeline;

  const VideoEditorSheet({
    super.key,
    required this.timeline,
  });

  @override
  Widget build(BuildContext context) {
    final layer = timeline.selectedLayer;

    if (layer == null) {
      return Container(
        height: 180,
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: const Text(
          'Select a video layer on the timeline to edit properties.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return Container(
      height: 280,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            // Sheet Header & Tab Bar
            Row(
              children: [
                const Icon(Icons.movie_creation, color: AppTheme.layerVideo, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Video Editor (${layer.name})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => timeline.setActiveModule(null),
                ),
              ],
            ),

            const TabBar(
              isScrollable: true,
              labelColor: AppTheme.accentPrimary,
              unselectedLabelColor: AppTheme.textMuted,
              indicatorColor: AppTheme.accentPrimary,
              tabs: [
                Tab(text: 'Speed & Trim'),
                Tab(text: 'LUT Filters'),
                Tab(text: 'Color Adjust'),
                Tab(text: 'Transitions'),
              ],
            ),

            const SizedBox(height: 12),

            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Speed Ramps & Duration
                  _buildSpeedAndTrimTab(layer, timeline),
                  // Tab 2: LUT Filters
                  _buildLutFiltersTab(layer, timeline),
                  // Tab 3: Color Adjustments
                  _buildColorAdjustTab(layer, timeline),
                  // Tab 4: Transitions
                  _buildTransitionsTab(layer, timeline),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedAndTrimTab(Layer layer, TimelineState timeline) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Playback Speed:', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            const Spacer(),
            Text('${layer.speed.toStringAsFixed(2)}x', style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: layer.speed,
          min: 0.25,
          max: 4.0,
          divisions: 15,
          activeColor: AppTheme.layerVideo,
          onChanged: (val) => timeline.updateLayer(layer.copyWith(speed: val)),
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => timeline.splitSelectedLayer(),
              icon: const Icon(Icons.call_split, size: 14),
              label: const Text('Split Clip at Cursor'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.bgSurface),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => timeline.duplicateSelectedLayer(),
              icon: const Icon(Icons.copy, size: 14),
              label: const Text('Duplicate'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.bgSurface),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLutFiltersTab(Layer layer, TimelineState timeline) {
    final luts = [
      {'id': 'none', 'name': 'Normal'},
      {'id': 'cyberpunk', 'name': 'Cyberpunk'},
      {'id': 'vintage', 'name': 'Vintage 80s'},
      {'id': 'monochrome', 'name': 'Monochrome'},
      {'id': 'cinematic', 'name': 'Teal & Orange'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: luts.map((lut) {
          final isSelected = layer.lutFilter == lut['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => timeline.updateLayer(layer.copyWith(lutFilter: lut['id'] as String)),
              child: Column(
                children: [
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.accentPrimary : AppTheme.bgSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? Colors.white : AppTheme.borderDark, width: 2),
                    ),
                    child: Icon(Icons.palette, color: isSelected ? Colors.white : AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(lut['name'] as String, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildColorAdjustTab(Layer layer, TimelineState timeline) {
    return ListView(
      children: [
        _buildSliderRow('Contrast', layer.contrast, 0.5, 2.0, (v) => timeline.updateLayer(layer.copyWith(contrast: v))),
        _buildSliderRow('Saturation', layer.saturation, 0.0, 2.0, (v) => timeline.updateLayer(layer.copyWith(saturation: v))),
        _buildSliderRow('Vignette', layer.vignette, 0.0, 1.0, (v) => timeline.updateLayer(layer.copyWith(vignette: v))),
      ],
    );
  }

  Widget _buildTransitionsTab(Layer layer, TimelineState timeline) {
    final transitions = ['none', 'fade', 'dissolve', 'slide', 'zoom', 'glitch'];

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('In Transition:', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              DropdownButton<String>(
                value: layer.transitionIn,
                isExpanded: true,
                dropdownColor: AppTheme.bgSurface,
                items: transitions.map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase()))).toList(),
                onChanged: (val) => timeline.updateLayer(layer.copyWith(transitionIn: val!)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Out Transition:', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              DropdownButton<String>(
                value: layer.transitionOut,
                isExpanded: true,
                dropdownColor: AppTheme.bgSurface,
                items: transitions.map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase()))).toList(),
                onChanged: (val) => timeline.updateLayer(layer.copyWith(transitionOut: val!)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliderRow(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary))),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            activeColor: AppTheme.accentPrimary,
            onChanged: onChanged,
          ),
        ),
        SizedBox(width: 35, child: Text(value.toStringAsFixed(2), style: const TextStyle(fontSize: 11, color: AppTheme.accentGold))),
      ],
    );
  }
}
