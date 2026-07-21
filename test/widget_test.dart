import 'package:flutter_test/flutter_test.dart';
import 'package:nscut/core/models/timeline.dart';
import 'package:nscut/core/models/media_item.dart';
import 'package:nscut/engine/audio_editing_engine.dart';
import 'package:nscut/engine/export_engine.dart';
import 'package:nscut/main.dart';

void main() {
  group('nscut Video Editor Unit Tests', () {
    testWidgets('NSCutApp renders main EditorScreen', (WidgetTester tester) async {
      await tester.pumpWidget(const NSCutApp());
      await tester.pumpAndSettle();

      expect(find.text('nscut'), findsOneWidget);
      expect(find.text('PRO'), findsOneWidget);
      expect(find.text('Video'), findsOneWidget);
      expect(find.text('Audio'), findsOneWidget);
    });

    test('TimelineState initializes with demo layers and tracks', () {
      final timeline = TimelineState();
      expect(timeline.layers.isNotEmpty, isTrue);
      expect(timeline.totalDuration, greaterThan(10.0));
      expect(timeline.currentTime, equals(0.0));
      expect(timeline.isPlaying, isFalse);
    });

    test('TimelineState play/pause/seek controls work correctly', () {
      final timeline = TimelineState();
      timeline.seekTo(5.0);
      expect(timeline.currentTime, equals(5.0));

      timeline.play();
      expect(timeline.isPlaying, isTrue);

      timeline.pause();
      expect(timeline.isPlaying, isFalse);
    });

    test('TimelineState layer split operation splits clip correctly', () {
      final timeline = TimelineState();
      final videoLayer = timeline.layers.firstWhere((l) => l.type == MediaType.video);
      timeline.selectLayer(videoLayer.id);
      timeline.seekTo(3.0);

      final initialLayerCount = timeline.layers.length;
      timeline.splitSelectedLayer();

      expect(timeline.layers.length, equals(initialLayerCount + 1));
    });

    test('AudioEditingEngine calculates effective volume envelope', () {
      final volume = AudioEditingEngine.calculateEffectiveVolume(
        baseVolume: 1.0,
        layerStartTime: 0.0,
        layerDuration: 10.0,
        currentTime: 5.0,
        fadeInSeconds: 1.0,
        fadeOutSeconds: 1.0,
      );
      expect(volume, equals(1.0));
    });

    test('ExportEngine state updates during export task', () {
      final exportEngine = ExportEngine();
      final timeline = TimelineState();

      expect(exportEngine.state.isExporting, isFalse);
      exportEngine.startExport(
        timeline: timeline,
        resolution: ResolutionPreset.res1080p,
        fps: 30,
        format: 'mp4',
      );

      expect(exportEngine.state.isExporting, isTrue);
      exportEngine.cancelExport();
      expect(exportEngine.state.isExporting, isFalse);
    });
  });
}
