import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/timeline.dart';

class SettingsSheet extends StatefulWidget {
  final TimelineState timeline;

  const SettingsSheet({super.key, required this.timeline});

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  bool _autoSave = true;
  bool _gpuAcceleration = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: AppTheme.dividerColor, width: 1)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle indicator
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textMuted.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.settings_outlined, color: AppTheme.accentSecondary, size: 22),
                  const SizedBox(width: 12),
                  const Text(
                    'Project Settings',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(color: AppTheme.dividerColor, height: 1),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Aspect Ratio Preset Selection
                    _buildSectionHeader('Aspect Ratio', Icons.aspect_ratio_rounded),
                    const SizedBox(height: 10),
                    _buildAspectRatioSelector(),
                    const SizedBox(height: 24),

                    // Resolution Selection
                    _buildSectionHeader('Export Resolution', Icons.hd_outlined),
                    const SizedBox(height: 10),
                    _buildResolutionSelector(),
                    const SizedBox(height: 24),

                    // Frame Rate Selection
                    _buildSectionHeader('Frame Rate (FPS)', Icons.speed_rounded),
                    const SizedBox(height: 10),
                    _buildFpsSelector(),
                    const SizedBox(height: 24),

                    // Additional Toggles
                    _buildSectionHeader('Performance & Behavior', Icons.tune_rounded),
                    const SizedBox(height: 10),
                    _buildToggleCard(
                      title: 'Auto-Save Drafts',
                      subtitle: 'Periodically save project progress in background',
                      value: _autoSave,
                      onChanged: (val) {
                        setState(() {
                          _autoSave = val;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildToggleCard(
                      title: 'Hardware GPU Acceleration',
                      subtitle: 'Boost timeline rendering speed and previews',
                      value: _gpuAcceleration,
                      onChanged: (val) {
                        setState(() {
                          _gpuAcceleration = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textMuted, size: 16),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: AppTheme.accentSecondary,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildAspectRatioSelector() {
    return ListenableBuilder(
      listenable: widget.timeline,
      builder: (context, _) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AspectRatioPreset.values.map((preset) {
            final isSelected = widget.timeline.aspectRatio == preset;
            return ChoiceChip(
              label: Text(
                preset.label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  widget.timeline.setAspectRatio(preset);
                }
              },
              selectedColor: AppTheme.accentPrimary,
              backgroundColor: AppTheme.bgSurface,
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected ? AppTheme.accentPrimary : AppTheme.borderDark,
                  width: 1.0,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildResolutionSelector() {
    return ListenableBuilder(
      listenable: widget.timeline,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.bgSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.borderDark),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ResolutionPreset>(
              value: widget.timeline.resolution,
              dropdownColor: AppTheme.bgSurface,
              icon: const Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary),
              isExpanded: true,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
              onChanged: (ResolutionPreset? value) {
                if (value != null) {
                  widget.timeline.setResolution(value);
                }
              },
              items: ResolutionPreset.values.map((ResolutionPreset preset) {
                return DropdownMenuItem<ResolutionPreset>(
                  value: preset,
                  child: Text('${preset.label} (${preset.width}x${preset.height})'),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFpsSelector() {
    return ListenableBuilder(
      listenable: widget.timeline,
      builder: (context, _) {
        final currentFps = widget.timeline.fps;
        final presets = [24, 30, 60];
        return Row(
          children: presets.map((fps) {
            final isSelected = currentFps == fps;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: InkWell(
                  onTap: () => widget.timeline.setFps(fps),
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.accentPrimary : AppTheme.bgSurface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppTheme.accentPrimary : AppTheme.borderDark,
                      ),
                    ),
                    child: Text(
                      '$fps FPS',
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildToggleCard({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.accentSecondary,
            activeTrackColor: AppTheme.accentSecondary.withValues(alpha: 0.2),
            inactiveThumbColor: AppTheme.textMuted,
            inactiveTrackColor: AppTheme.bgCard,
          ),
        ],
      ),
    );
  }
}
