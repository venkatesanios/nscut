import 'dart:async';
import 'package:flutter/material.dart';
import 'layer.dart';
import 'media_item.dart';

enum AspectRatioPreset {
  ratio16x9('16:9', 16 / 9),
  ratio9x16('9:16 (TikTok/Reels)', 9 / 16),
  ratio1x1('1:1 (Square)', 1 / 1),
  ratio4x3('4:3', 4 / 3),
  ratio21x9('21:9 (Cinematic)', 21 / 9);

  final String label;
  final double value;
  const AspectRatioPreset(this.label, this.value);
}

enum ResolutionPreset {
  res720p('720p HD', 1280, 720),
  res1080p('1080p Full HD', 1920, 1080),
  res4k('4K Ultra HD', 3840, 2160);

  final String label;
  final int width;
  final int height;
  const ResolutionPreset(this.label, this.width, this.height);
}

class TimelineState extends ChangeNotifier {
  double _currentTime = 0.0;
  double _totalDuration = 15.0;
  bool _isPlaying = false;
  double _zoomLevel = 1.0;
  String? _selectedLayerId;
  String? _activeModule; // 'video', 'audio', 'image', 'sticker', 'text', 'drawing', 'ai', 'export'
  
  AspectRatioPreset _aspectRatio = AspectRatioPreset.ratio16x9;
  ResolutionPreset _resolution = ResolutionPreset.res1080p;
  int _fps = 30;

  List<Layer> _layers = [];
  Timer? _tickerTimer;

  // History for Undo/Redo
  final List<List<Layer>> _undoHistory = [];
  final List<List<Layer>> _redoHistory = [];

  TimelineState() {
    _loadSampleDemoProject();
  }

  // Getters
  double get currentTime => _currentTime;
  double get totalDuration => _totalDuration;
  bool get isPlaying => _isPlaying;
  double get zoomLevel => _zoomLevel;
  String? get selectedLayerId => _selectedLayerId;
  String? get activeModule => _activeModule;
  AspectRatioPreset get aspectRatio => _aspectRatio;
  ResolutionPreset get resolution => _resolution;
  int get fps => _fps;
  List<Layer> get layers => List.unmodifiable(_layers);

  Layer? get selectedLayer {
    if (_selectedLayerId == null) return null;
    try {
      return _layers.firstWhere((l) => l.id == _selectedLayerId);
    } catch (_) {
      return null;
    }
  }

  // Active layers at current playhead timestamp sorted by Z-Index
  List<Layer> get activeLayersAtCurrentTime {
    final active = _layers.where((l) => l.isVisibleAt(_currentTime)).toList();
    active.sort((a, b) => a.zIndex.compareTo(b.zIndex));
    return active;
  }

  // Playback Control
  void play() {
    if (_isPlaying) return;
    _isPlaying = true;
    notifyListeners();

    final intervalMs = (1000 / _fps).round();
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }
      _currentTime += intervalMs / 1000.0;
      if (_currentTime >= _totalDuration) {
        _currentTime = 0.0; // Loop playback
      }
      notifyListeners();
    });
  }

  void pause() {
    _isPlaying = false;
    _tickerTimer?.cancel();
    notifyListeners();
  }

  void togglePlay() {
    if (_isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void seekTo(double timeSeconds) {
    _currentTime = timeSeconds.clamp(0.0, _totalDuration);
    notifyListeners();
  }

  void setZoomLevel(double zoom) {
    _zoomLevel = zoom.clamp(0.5, 5.0);
    notifyListeners();
  }

  void selectLayer(String? id) {
    _selectedLayerId = id;
    notifyListeners();
  }

  void setActiveModule(String? module) {
    _activeModule = module;
    notifyListeners();
  }

  void setAspectRatio(AspectRatioPreset ratio) {
    _aspectRatio = ratio;
    notifyListeners();
  }

  void setResolution(ResolutionPreset res) {
    _resolution = res;
    notifyListeners();
  }

  void setFps(int newFps) {
    _fps = newFps;
    notifyListeners();
  }

  // History & Mutation Helpers
  void _saveStateToHistory() {
    _undoHistory.add(_layers.map((l) => l.copyWith()).toList());
    if (_undoHistory.length > 30) {
      _undoHistory.removeAt(0);
    }
    _redoHistory.clear();
  }

  bool get canUndo => _undoHistory.isNotEmpty;
  bool get canRedo => _redoHistory.isNotEmpty;

  void undo() {
    if (!canUndo) return;
    _redoHistory.add(_layers.map((l) => l.copyWith()).toList());
    _layers = _undoHistory.removeLast();
    notifyListeners();
  }

  void redo() {
    if (!canRedo) return;
    _undoHistory.add(_layers.map((l) => l.copyWith()).toList());
    _layers = _redoHistory.removeLast();
    notifyListeners();
  }

  // Layer CRUD
  void addLayer(Layer layer) {
    _saveStateToHistory();
    _layers.add(layer);
    _selectedLayerId = layer.id;
    _recalculateTotalDuration();
    notifyListeners();
  }

  void updateLayer(Layer updatedLayer) {
    _saveStateToHistory();
    final index = _layers.indexWhere((l) => l.id == updatedLayer.id);
    if (index != -1) {
      _layers[index] = updatedLayer;
      _recalculateTotalDuration();
      notifyListeners();
    }
  }

  void removeLayer(String layerId) {
    _saveStateToHistory();
    _layers.removeWhere((l) => l.id == layerId);
    if (_selectedLayerId == layerId) {
      _selectedLayerId = null;
    }
    _recalculateTotalDuration();
    notifyListeners();
  }

  void splitSelectedLayer() {
    final layer = selectedLayer;
    if (layer == null) return;
    if (_currentTime <= layer.startTime || _currentTime >= layer.endTime) return;

    _saveStateToHistory();
    final firstPartDuration = _currentTime - layer.startTime;
    final secondPartDuration = layer.endTime - _currentTime;

    final layer1 = layer.copyWith(duration: firstPartDuration);
    final layer2 = layer.copyWith(
      id: '${layer.id}_split_${DateTime.now().millisecondsSinceEpoch}',
      name: '${layer.name} (Split)',
      startTime: _currentTime,
      duration: secondPartDuration,
      trimIn: layer.trimIn + firstPartDuration,
    );

    final index = _layers.indexWhere((l) => l.id == layer.id);
    _layers[index] = layer1;
    _layers.insert(index + 1, layer2);
    _selectedLayerId = layer2.id;
    notifyListeners();
  }

  void duplicateSelectedLayer() {
    final layer = selectedLayer;
    if (layer == null) return;

    _saveStateToHistory();
    final dup = layer.copyWith(
      id: '${layer.id}_dup_${DateTime.now().millisecondsSinceEpoch}',
      name: '${layer.name} (Copy)',
      startTime: layer.startTime + 0.5,
      zIndex: layer.zIndex + 1,
    );
    _layers.add(dup);
    _selectedLayerId = dup.id;
    notifyListeners();
  }

  void _recalculateTotalDuration() {
    double maxEnd = 15.0;
    for (final l in _layers) {
      if (l.endTime > maxEnd) {
        maxEnd = l.endTime;
      }
    }
    _totalDuration = maxEnd + 2.0;
  }

  // Load rich sample project assets so user can edit right away
  void _loadSampleDemoProject() {
    _layers = [
      // Track 0: Main Video Base Layer
      Layer(
        id: 'layer_video_1',
        name: 'Neon City Drive',
        type: MediaType.video,
        media: MediaItem(
          id: 'media_v1',
          name: 'Cyberpunk Sunset',
          type: MediaType.video,
          color: const Color(0xFF6C5CE7),
          duration: 12.0,
        ),
        startTime: 0.0,
        duration: 12.0,
        zIndex: 0,
        lutFilter: 'cyberpunk',
        contrast: 1.15,
        saturation: 1.25,
      ),
      // Track 1: Audio Soundtrack
      Layer(
        id: 'layer_audio_1',
        name: 'Synthwave Beats',
        type: MediaType.audio,
        media: MediaItem(
          id: 'media_a1',
          name: 'Midnight Highway FX',
          type: MediaType.audio,
          color: const Color(0xFF00CEC9),
          duration: 15.0,
        ),
        startTime: 0.0,
        duration: 15.0,
        volume: 0.85,
        zIndex: 1,
      ),
      // Track 2: Animated Title Text
      Layer(
        id: 'layer_text_1',
        name: 'NSCUT CINEMATIC',
        type: MediaType.text,
        media: MediaItem(
          id: 'media_t1',
          name: 'Title Text',
          type: MediaType.text,
          textContent: 'NSCUT PRO VIDEO',
          fontSize: 32.0,
          textColor: const Color(0xFF00CEC9),
          textGradientEnabled: true,
          textOutlineColor: Colors.black,
          textOutlineWidth: 2.5,
          textAnimation: 'typewriter',
        ),
        startTime: 1.0,
        duration: 6.0,
        position: const Offset(0.0, -0.6),
        scale: 1.1,
        zIndex: 2,
      ),
      // Track 3: Sticker Graphic
      Layer(
        id: 'layer_sticker_1',
        name: 'Neon Badge',
        type: MediaType.sticker,
        media: MediaItem(
          id: 'media_s1',
          name: 'Star Badge',
          type: MediaType.sticker,
          stickerCategory: 'badge',
          stickerSvgShape: 'star',
          stickerIcon: Icons.auto_awesome,
        ),
        startTime: 2.0,
        duration: 5.0,
        position: const Offset(0.7, -0.7),
        scale: 0.9,
        rotation: 0.15,
        zIndex: 3,
      ),
      // Track 4: AI Stylize Layer
      Layer(
        id: 'layer_ai_1',
        name: 'AI Cyber Filter',
        type: MediaType.aiEffect,
        media: MediaItem(
          id: 'media_ai1',
          name: 'Style Transfer',
          type: MediaType.aiEffect,
          aiEffectType: 'cyberpunk_anime',
          aiIntensity: 0.75,
        ),
        startTime: 4.0,
        duration: 7.0,
        opacity: 0.8,
        zIndex: 4,
      ),
      // Track 5: Hand-drawn Neon Canvas Stroke
      Layer(
        id: 'layer_drawing_1',
        name: 'Neon Glow Draw',
        type: MediaType.drawing,
        media: MediaItem(
          id: 'media_d1',
          name: 'Brush Sketch',
          type: MediaType.drawing,
          drawingStrokes: [
            DrawingStroke(
              points: [
                const Offset(-100, 50),
                const Offset(-50, -20),
                const Offset(0, 40),
                const Offset(50, -10),
                const Offset(100, 30),
              ],
              color: const Color(0xFFFF7675),
              strokeWidth: 5.0,
              brushType: 'neon',
            ),
          ],
        ),
        startTime: 3.0,
        duration: 8.0,
        position: const Offset(0.0, 0.4),
        zIndex: 5,
      ),
    ];
    _recalculateTotalDuration();
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }
}
