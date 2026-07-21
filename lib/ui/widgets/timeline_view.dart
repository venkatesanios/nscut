import 'package:flutter/material.dart';
import '../../core/models/timeline.dart';
import '../../core/models/layer.dart';
import '../../core/models/media_item.dart';
import '../../core/theme/app_theme.dart';

class TimelineView extends StatefulWidget {
  final TimelineState timeline;

  const TimelineView({
    super.key,
    required this.timeline,
  });

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  final ScrollController _horizontalScroll = ScrollController();
  static const double _basePixelsPerSecond = 40.0;

  @override
  Widget build(BuildContext context) {
    final timeline = widget.timeline;
    final pps = _basePixelsPerSecond * timeline.zoomLevel;
    final totalWidth = timeline.totalDuration * pps;

    return Container(
      color: AppTheme.bgCard,
      child: Column(
        children: [
          // 1. Timeline Header Controls & Ruler
          _buildRulerAndControlsHeader(timeline, pps, totalWidth),

          const Divider(height: 1, color: AppTheme.dividerColor),

          // 2. Track List & Playhead Stack
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  controller: _horizontalScroll,
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SizedBox(
                      width: totalWidth + 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: timeline.layers.map((layer) {
                          return _buildTrackRow(layer, timeline, pps);
                        }).toList(),
                      ),
                    ),
                  ),
                ),

                // Red Interactive Playhead Cursor Bar
                _buildPlayheadCursor(timeline, pps),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulerAndControlsHeader(TimelineState timeline, double pps, double totalWidth) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: AppTheme.bgSurface,
      child: Row(
        children: [
          const Icon(Icons.tune, size: 16, color: AppTheme.accentSecondary),
          const SizedBox(width: 6),
          const Text('Tracks', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),

          const Spacer(),

          // Timeline Zoom Controls
          const Icon(Icons.zoom_out, size: 14, color: AppTheme.textMuted),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              activeTrackColor: AppTheme.accentPrimary,
              inactiveTrackColor: AppTheme.borderDark,
            ),
            child: SizedBox(
              width: 100,
              child: Slider(
                value: timeline.zoomLevel,
                min: 0.5,
                max: 4.0,
                onChanged: (val) => timeline.setZoomLevel(val),
              ),
            ),
          ),
          const Icon(Icons.zoom_in, size: 14, color: AppTheme.textMuted),
        ],
      ),
    );
  }

  Widget _buildTrackRow(Layer layer, TimelineState timeline, double pps) {
    final isSelected = layer.id == timeline.selectedLayerId;
    final leftOffset = layer.startTime * pps;
    final clipWidth = layer.duration * pps;

    Color trackColor = AppTheme.layerVideo;
    IconData trackIcon = Icons.movie;

    switch (layer.type) {
      case MediaType.video:
        trackColor = AppTheme.layerVideo;
        trackIcon = Icons.video_collection;
        break;
      case MediaType.audio:
        trackColor = AppTheme.layerAudio;
        trackIcon = Icons.audiotrack;
        break;
      case MediaType.text:
        trackColor = AppTheme.layerText;
        trackIcon = Icons.text_fields;
        break;
      case MediaType.sticker:
        trackColor = AppTheme.layerSticker;
        trackIcon = Icons.auto_awesome;
        break;
      case MediaType.drawing:
        trackColor = AppTheme.layerDrawing;
        trackIcon = Icons.brush;
        break;
      case MediaType.aiEffect:
        trackColor = AppTheme.layerAI;
        trackIcon = Icons.psychology;
        break;
      case MediaType.image:
        trackColor = AppTheme.layerImage;
        trackIcon = Icons.image;
        break;
    }

    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.bgElevated : Colors.transparent,
        border: Border(bottom: BorderSide(color: AppTheme.dividerColor.withValues(alpha: 0.4))),
      ),
      child: Stack(
        children: [
          // Clip Box on Timeline
          Positioned(
            left: leftOffset,
            width: clipWidth,
            top: 4,
            bottom: 4,
            child: GestureDetector(
              onTap: () => timeline.selectLayer(layer.id),
              onHorizontalDragUpdate: (details) {
                if (layer.isLocked) return;
                final newStart = (layer.startTime + (details.delta.dx / pps)).clamp(0.0, timeline.totalDuration - 0.5);
                timeline.updateLayer(layer.copyWith(startTime: newStart));
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                decoration: BoxDecoration(
                  color: trackColor.withValues(alpha: isSelected ? 0.9 : 0.65),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? Colors.white : trackColor,
                    width: isSelected ? 2.0 : 1.0,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(color: trackColor.withValues(alpha: 0.5), blurRadius: 6),
                  ] : null,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Icon(trackIcon, size: 16, color: Colors.white),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        layer.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      '${layer.duration.toStringAsFixed(1)}s',
                      style: const TextStyle(fontSize: 10, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayheadCursor(TimelineState timeline, double pps) {
    final playheadX = timeline.currentTime * pps;

    return Positioned(
      left: playheadX,
      top: 0,
      bottom: 0,
      child: GestureDetector(
        onPanUpdate: (details) {
          final newTime = timeline.currentTime + (details.delta.dx / pps);
          timeline.seekTo(newTime);
        },
        child: Container(
          width: 14,
          transform: Matrix4.translationValues(-7, 0, 0),
          child: Column(
            children: [
              // Playhead Knob
              Container(
                width: 14,
                height: 16,
                decoration: const BoxDecoration(
                  color: AppTheme.accentPink,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
                ),
                child: const Icon(Icons.arrow_drop_down, size: 14, color: Colors.white),
              ),
              // Vertical Line
              Expanded(
                child: Container(
                  width: 2,
                  color: AppTheme.accentPink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
