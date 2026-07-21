import 'dart:async';
import 'package:flutter/material.dart';
import '../core/models/timeline.dart';

class ExportTaskState {
  final bool isExporting;
  final double progress; // 0.0 to 1.0
  final int currentFrame;
  final int totalFrames;
  final String statusMessage;
  final String? exportFilePath;

  ExportTaskState({
    required this.isExporting,
    required this.progress,
    required this.currentFrame,
    required this.totalFrames,
    required this.statusMessage,
    this.exportFilePath,
  });
}

class ExportEngine extends ChangeNotifier {
  ExportTaskState _state = ExportTaskState(
    isExporting: false,
    progress: 0.0,
    currentFrame: 0,
    totalFrames: 0,
    statusMessage: 'Ready to export',
  );

  Timer? _exportTimer;

  ExportTaskState get state => _state;

  void startExport({
    required TimelineState timeline,
    required ResolutionPreset resolution,
    required int fps,
    required String format, // 'mp4', 'gif', 'prores'
  }) {
    if (_state.isExporting) return;

    final int totalFrames = (timeline.totalDuration * fps).round();
    _state = ExportTaskState(
      isExporting: true,
      progress: 0.0,
      currentFrame: 0,
      totalFrames: totalFrames,
      statusMessage: 'Initializing hardware GPU rendering context...',
    );
    notifyListeners();

    int frame = 0;
    const intervalMs = 40; // 25 frames per second simulation speed

    _exportTimer?.cancel();
    _exportTimer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      frame++;
      final double progress = (frame / totalFrames).clamp(0.0, 1.0);

      String msg = 'Rendering frame $frame / $totalFrames (${resolution.label})';
      if (progress > 0.85) {
        msg = 'Encoding audio tracks & finalizing $format container...';
      }

      if (frame >= totalFrames) {
        timer.cancel();
        _state = ExportTaskState(
          isExporting: false,
          progress: 1.0,
          currentFrame: totalFrames,
          totalFrames: totalFrames,
          statusMessage: 'Export completed successfully!',
          exportFilePath: '/storage/nscut_exports/render_${DateTime.now().millisecondsSinceEpoch}.$format',
        );
        notifyListeners();
        return;
      }

      _state = ExportTaskState(
        isExporting: true,
        progress: progress,
        currentFrame: frame,
        totalFrames: totalFrames,
        statusMessage: msg,
      );
      notifyListeners();
    });
  }

  void cancelExport() {
    _exportTimer?.cancel();
    _state = ExportTaskState(
      isExporting: false,
      progress: 0.0,
      currentFrame: 0,
      totalFrames: 0,
      statusMessage: 'Export cancelled',
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _exportTimer?.cancel();
    super.dispose();
  }
}
