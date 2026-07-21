import 'package:flutter/material.dart';
import '../../core/models/timeline.dart';
import '../../core/models/layer.dart';
import '../../core/models/media_item.dart';
import '../../core/theme/app_theme.dart';

class DrawingCanvasSheet extends StatefulWidget {
  final TimelineState timeline;

  const DrawingCanvasSheet({
    super.key,
    required this.timeline,
  });

  @override
  State<DrawingCanvasSheet> createState() => _DrawingCanvasSheetState();
}

class _DrawingCanvasSheetState extends State<DrawingCanvasSheet> {
  String _selectedBrush = 'neon';
  Color _selectedColor = const Color(0xFFFF7675);
  double _strokeWidth = 6.0;

  @override
  Widget build(BuildContext context) {
    final timeline = widget.timeline;
    final selectedLayer = timeline.selectedLayer;
    final isDrawing = selectedLayer != null && selectedLayer.type == MediaType.drawing;

    return Container(
      height: 310,
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
              const Icon(Icons.gesture, color: AppTheme.layerDrawing, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Digital Drawing Canvas',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => timeline.setActiveModule(null),
              ),
            ],
          ),

          // Brush Type Picker
          const Text('Select Brush Type:', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBrushTypeTile('neon', 'Neon Glow', Icons.blur_on),
              _buildBrushTypeTile('pencil', 'Pencil', Icons.edit),
              _buildBrushTypeTile('marker', 'Marker', Icons.border_color),
              _buildBrushTypeTile('spray', 'Spray', Icons.grain),
            ],
          ),

          const SizedBox(height: 10),

          // Color Palette Row
          Row(
            children: [
              const Text('Color:', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              const SizedBox(width: 12),
              ...[
                const Color(0xFFFF7675),
                const Color(0xFF00CEC9),
                const Color(0xFF55E6C1),
                const Color(0xFFFDCB6E),
                const Color(0xFFA29BFE),
                Colors.white,
              ].map((c) {
                final isSelected = _selectedColor == c;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => setState(() => _selectedColor = c),
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(color: isSelected ? Colors.white : Colors.transparent, width: 2.5),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),

          const SizedBox(height: 8),

          // Stroke Width Slider
          Row(
            children: [
              const Text('Stroke Width:', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              Expanded(
                child: Slider(
                  value: _strokeWidth,
                  min: 2.0,
                  max: 20.0,
                  activeColor: AppTheme.layerDrawing,
                  onChanged: (val) => setState(() => _strokeWidth = val),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Action Button
          Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.layerDrawing, foregroundColor: Colors.black),
              icon: const Icon(Icons.brush, size: 16),
              label: Text(isDrawing ? 'Add Stroke to Current Layer' : 'Create New Drawing Layer'),
              onPressed: () {
                if (isDrawing) {
                  final newStroke = DrawingStroke(
                    points: [
                      const Offset(-80, -30),
                      const Offset(-30, 20),
                      const Offset(20, -20),
                      const Offset(70, 30),
                    ],
                    color: _selectedColor,
                    strokeWidth: _strokeWidth,
                    brushType: _selectedBrush,
                  );
                  final updatedStrokes = List<DrawingStroke>.from(selectedLayer.media.drawingStrokes)..add(newStroke);
                  timeline.updateLayer(selectedLayer.copyWith(media: selectedLayer.media.copyWith(drawingStrokes: updatedStrokes)));
                } else {
                  final id = 'drawing_${DateTime.now().millisecondsSinceEpoch}';
                  timeline.addLayer(
                    Layer(
                      id: id,
                      name: 'Neon Sketch',
                      type: MediaType.drawing,
                      media: MediaItem(
                        id: 'media_$id',
                        name: 'Drawing',
                        type: MediaType.drawing,
                        drawingStrokes: [
                          DrawingStroke(
                            points: [
                              const Offset(-100, 20),
                              const Offset(-40, -40),
                              const Offset(20, 30),
                              const Offset(80, -10),
                            ],
                            color: _selectedColor,
                            strokeWidth: _strokeWidth,
                            brushType: _selectedBrush,
                          ),
                        ],
                      ),
                      startTime: timeline.currentTime,
                      duration: 6.0,
                      zIndex: timeline.layers.length,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrushTypeTile(String type, String label, IconData icon) {
    final isSelected = _selectedBrush == type;

    return InkWell(
      onTap: () => setState(() => _selectedBrush = type),
      child: Container(
        width: 75,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.layerDrawing.withValues(alpha: 0.25) : AppTheme.bgSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppTheme.layerDrawing : AppTheme.borderDark),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: isSelected ? AppTheme.layerDrawing : AppTheme.textMuted),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 9, color: isSelected ? AppTheme.textPrimary : AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }
}
