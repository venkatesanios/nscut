import 'package:flutter/material.dart';
import '../../core/models/timeline.dart';
import '../../core/theme/app_theme.dart';
import '../../engine/export_engine.dart';
import '../widgets/top_nav_bar.dart';
import '../widgets/preview_monitor.dart';
import '../widgets/timeline_view.dart';
import '../widgets/bottom_tool_bar.dart';
import '../sheets/video_editor_sheet.dart';
import '../sheets/audio_editor_sheet.dart';
import '../sheets/image_editor_sheet.dart';
import '../sheets/sticker_generator_sheet.dart';
import '../sheets/text_editor_sheet.dart';
import '../sheets/drawing_canvas_sheet.dart';
import '../sheets/ai_effects_sheet.dart';
import '../sheets/export_engine_sheet.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late final TimelineState _timeline;
  late final ExportEngine _exportEngine;

  @override
  void initState() {
    super.initState();
    _timeline = TimelineState();
    _exportEngine = ExportEngine();
  }

  @override
  void dispose() {
    _timeline.dispose();
    _exportEngine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _timeline,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppTheme.bgDark,
          body: SafeArea(
            child: Column(
              children: [
                // 1. Top Navigation Bar
                TopNavBar(timeline: _timeline),

                // 2. Real-Time Interactive Preview Monitor Viewport
                Expanded(
                  flex: 5,
                  child: PreviewMonitor(timeline: _timeline),
                ),

                // 3. Multi-Layer Timeline View Scrubber
                Expanded(
                  flex: 4,
                  child: TimelineView(timeline: _timeline),
                ),

                // 4. Active Modular Sheet Container Overlay (if any module is open)
                if (_timeline.activeModule != null)
                  _buildActiveModuleSheet(_timeline.activeModule!),

                // 5. Bottom Quick Action Module Tool Bar
                BottomToolBar(timeline: _timeline),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveModuleSheet(String module) {
    switch (module) {
      case 'video':
        return VideoEditorSheet(timeline: _timeline);
      case 'audio':
        return AudioEditorSheet(timeline: _timeline);
      case 'image':
        return ImageEditorSheet(timeline: _timeline);
      case 'sticker':
        return StickerGeneratorSheet(timeline: _timeline);
      case 'text':
        return TextEditorSheet(timeline: _timeline);
      case 'drawing':
        return DrawingCanvasSheet(timeline: _timeline);
      case 'ai':
        return AIEffectsSheet(timeline: _timeline);
      case 'export':
        return ExportEngineSheet(timeline: _timeline, exportEngine: _exportEngine);
      default:
        return const SizedBox.shrink();
    }
  }
}
