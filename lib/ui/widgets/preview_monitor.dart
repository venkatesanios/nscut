import 'package:flutter/material.dart';
import '../../core/models/timeline.dart';
import '../../core/theme/app_theme.dart';
import '../../engine/native_rendering_engine.dart';

class PreviewMonitor extends StatelessWidget {
  final TimelineState timeline;

  const PreviewMonitor({
    super.key,
    required this.timeline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.bgDark,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Native Render Viewport with Touch Drag/Transform Gesture Recognizer
          GestureDetector(
            onTapUp: (details) {
              _handleCanvasTap(details, context);
            },
            onPanUpdate: (details) {
              _handleCanvasPan(details, context);
            },
            child: SizedBox.expand(
              child: CustomPaint(
                painter: _NativeCanvasPainter(
                  timeline: timeline,
                ),
              ),
            ),
          ),

          // 2. Selected Layer Info Badge Overlay (Top Left of Preview)
          if (timeline.selectedLayer != null)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.bgCard.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.accentPrimary),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.layers, size: 14, color: AppTheme.accentSecondary),
                    const SizedBox(width: 6),
                    Text(
                      timeline.selectedLayer!.name,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => timeline.selectLayer(null),
                      child: const Icon(Icons.close, size: 14, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ),

          // 3. Floating Playback Transport Bar Overlay (Bottom Center of Preview)
          Positioned(
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.bgCard.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.borderDark),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 3)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay_10, size: 20),
                    color: AppTheme.textSecondary,
                    onPressed: () => timeline.seekTo(timeline.currentTime - 1.0),
                    tooltip: 'Back 1s',
                  ),
                  IconButton(
                    icon: Icon(
                      timeline.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                      size: 36,
                    ),
                    color: AppTheme.accentPrimary,
                    onPressed: () => timeline.togglePlay(),
                    tooltip: timeline.isPlaying ? 'Pause' : 'Play',
                  ),
                  IconButton(
                    icon: const Icon(Icons.forward_10, size: 20),
                    color: AppTheme.textSecondary,
                    onPressed: () => timeline.seekTo(timeline.currentTime + 1.0),
                    tooltip: 'Forward 1s',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCanvasTap(TapUpDetails details, BuildContext context) {
    final activeLayers = timeline.activeLayersAtCurrentTime;
    if (activeLayers.isEmpty) {
      timeline.selectLayer(null);
      return;
    }
    // Cycle layer selection
    final currentIndex = activeLayers.indexWhere((l) => l.id == timeline.selectedLayerId);
    final nextIndex = (currentIndex + 1) % activeLayers.length;
    timeline.selectLayer(activeLayers[nextIndex].id);
  }

  void _handleCanvasPan(DragUpdateDetails details, BuildContext context) {
    final layer = timeline.selectedLayer;
    if (layer == null || layer.isLocked) return;

    final Size screenSize = MediaQuery.of(context).size;
    final double dxChange = (details.delta.dx / (screenSize.width * 0.4)) * 2;
    final double dyChange = (details.delta.dy / (screenSize.height * 0.3)) * 2;

    final updated = layer.copyWith(
      position: Offset(
        (layer.position.dx + dxChange).clamp(-1.8, 1.8),
        (layer.position.dy + dyChange).clamp(-1.8, 1.8),
      ),
    );
    timeline.updateLayer(updated);
  }
}

class _NativeCanvasPainter extends CustomPainter {
  final TimelineState timeline;

  _NativeCanvasPainter({
    required this.timeline,
  }) : super(repaint: timeline);

  @override
  void paint(Canvas canvas, Size size) {
    NativeRenderingEngine.renderFrame(
      canvas: canvas,
      size: size,
      layers: timeline.layers,
      currentTime: timeline.currentTime,
      aspectRatio: timeline.aspectRatio,
      selectedLayerId: timeline.selectedLayerId,
    );
  }

  @override
  bool shouldRepaint(covariant _NativeCanvasPainter oldDelegate) => true;
}
