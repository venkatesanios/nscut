import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/timeline.dart';
import '../../core/models/layer.dart';
import '../../core/models/media_item.dart';

class PhoneGalleryModal extends StatefulWidget {
  final TimelineState timeline;
  final MediaType? filterType;

  const PhoneGalleryModal({
    super.key,
    required this.timeline,
    this.filterType,
  });

  @override
  State<PhoneGalleryModal> createState() => _PhoneGalleryModalState();
}

class _PhoneGalleryModalState extends State<PhoneGalleryModal> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  
  // Track selected items: key is type_index
  String? _selectedItemKey;
  Map<String, dynamic>? _selectedItemData;

  // Mock Gallery Data
  final List<Map<String, dynamic>> _mockVideos = [
    {
      'id': 'v_cyber_drive',
      'name': 'Cyberpunk Drive.mp4',
      'duration': 12.0,
      'size': '24.5 MB',
      'color': const Color(0xFF6C5CE7),
    },
    {
      'id': 'v_neon_rain',
      'name': 'Neon Rain.mp4',
      'duration': 8.0,
      'size': '15.2 MB',
      'color': const Color(0xFFA29BFE),
    },
    {
      'id': 'v_tokyo_night',
      'name': 'Tokyo Nightlife.mp4',
      'duration': 15.0,
      'size': '32.1 MB',
      'color': const Color(0xFFE84393),
    },
    {
      'id': 'v_retro_grid',
      'name': 'Retro Grid.mp4',
      'duration': 10.0,
      'size': '18.9 MB',
      'color': const Color(0xFF00CEC9),
    },
  ];

  final List<Map<String, dynamic>> _mockPhotos = [
    {
      'id': 'p_cyber_girl',
      'name': 'Cyberpunk Model.png',
      'size': '4.2 MB',
      'color': const Color(0xFFFD79A8),
    },
    {
      'id': 'p_neon_sign',
      'name': 'Neon Sign.jpg',
      'size': '2.1 MB',
      'color': const Color(0xFFFF7675),
    },
    {
      'id': 'p_futuristic_car',
      'name': 'Futuristic Ride.jpg',
      'size': '3.7 MB',
      'color': const Color(0xFFFDCB6E),
    },
    {
      'id': 'p_glitch_bg',
      'name': 'Glitch Texture.png',
      'size': '1.5 MB',
      'color': const Color(0xFF55E6C1),
    },
  ];

  final List<Map<String, dynamic>> _mockAudios = [
    {
      'id': 'a_synth_pulse',
      'name': 'Synthwave Pulse.mp3',
      'duration': 20.0,
      'size': '4.8 MB',
      'color': const Color(0xFF00CEC9),
    },
    {
      'id': 'a_ambient_rain',
      'name': 'Rain Ambient Loop.wav',
      'duration': 15.0,
      'size': '8.2 MB',
      'color': const Color(0xFF55E6C1),
    },
    {
      'id': 'a_techno_kick',
      'name': 'Techno Drum Loop.mp3',
      'duration': 12.0,
      'size': '3.1 MB',
      'color': const Color(0xFF6C5CE7),
    },
    {
      'id': 'a_retro_bells',
      'name': 'Retro Synth Bells.wav',
      'duration': 18.0,
      'size': '5.5 MB',
      'color': const Color(0xFFFF7675),
    },
  ];

  @override
  void initState() {
    super.initState();
    
    // Determine active tab based on filterType
    int initialIndex = 0;
    if (widget.filterType == MediaType.image) {
      initialIndex = 1;
    } else if (widget.filterType == MediaType.audio) {
      initialIndex = 2;
    }
    
    // 3 tabs: Videos (0), Photos (1), Audios (2)
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: initialIndex,
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedItemKey = null;
          _selectedItemData = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _selectItem(String type, int index, Map<String, dynamic> data) {
    setState(() {
      final key = '${type}_$index';
      if (_selectedItemKey == key) {
        _selectedItemKey = null;
        _selectedItemData = null;
      } else {
        _selectedItemKey = key;
        _selectedItemData = {
          'type': type,
          ...data,
        };
      }
    });
  }

  void _handleImport() {
    if (_selectedItemData == null) return;
    
    final data = _selectedItemData!;
    final typeStr = data['type'] as String;
    final name = data['name'] as String;
    final id = '${typeStr}_${DateTime.now().millisecondsSinceEpoch}';
    
    MediaType mediaType;
    double duration = 5.0; // Default for images
    
    if (typeStr == 'video') {
      mediaType = MediaType.video;
      duration = data['duration'] as double;
    } else if (typeStr == 'audio') {
      mediaType = MediaType.audio;
      duration = data['duration'] as double;
    } else {
      mediaType = MediaType.image;
    }

    final newLayer = Layer(
      id: id,
      name: name.split('.').first,
      type: mediaType,
      media: MediaItem(
        id: 'media_$id',
        name: name,
        type: mediaType,
        color: data['color'] as Color,
        duration: duration,
      ),
      startTime: widget.timeline.currentTime,
      duration: duration,
      zIndex: widget.timeline.layers.length,
    );

    widget.timeline.addLayer(newLayer);
    
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppTheme.accentGreen, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Imported "${newLayer.name}" to Timeline',
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.bgSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isFiltered = widget.filterType != null;
    
    return Container(
      height: 480,
      decoration: const BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppTheme.dividerColor, width: 1)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Top Drag Handle & Title Bar
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textMuted.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.photo_library_outlined, color: AppTheme.accentSecondary, size: 20),
                  const SizedBox(width: 10),
                  const Text(
                    'Phone Gallery',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: AppTheme.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            const Divider(color: AppTheme.dividerColor, height: 1),
            
            // Tab Bar
            AbsorbPointer(
              absorbing: isFiltered, // Disable switching if filtered
              child: Opacity(
                opacity: isFiltered ? 0.5 : 1.0,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.accentSecondary,
                  unselectedLabelColor: AppTheme.textMuted,
                  indicatorColor: AppTheme.accentSecondary,
                  dividerColor: AppTheme.dividerColor,
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.video_collection, size: 16),
                          SizedBox(width: 6),
                          Text('Videos', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, size: 16),
                          SizedBox(width: 6),
                          Text('Photos', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.audiotrack, size: 16),
                          SizedBox(width: 6),
                          Text('Audios', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Tab Views List
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: isFiltered ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
                children: [
                  // Tab 0: Videos
                  _buildVideosGrid(),
                  // Tab 1: Photos
                  _buildPhotosGrid(),
                  // Tab 2: Audios
                  _buildAudiosList(),
                ],
              ),
            ),
            
            // Bottom Action Bar
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideosGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mockVideos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.25,
      ),
      itemBuilder: (context, index) {
        final video = _mockVideos[index];
        final isSelected = _selectedItemKey == 'video_$index';
        
        return InkWell(
          onTap: () => _selectItem('video', index, video),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: video['color'].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppTheme.accentSecondary : AppTheme.borderDark,
                width: isSelected ? 2.0 : 1.0,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(Icons.play_circle_filled, color: video['color'], size: 36),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video['name'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${video['duration'].toInt()}s', style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
                          Text(video['size'], style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: AppTheme.accentSecondary,
                      radius: 10,
                      child: Icon(Icons.check, size: 12, color: Colors.black),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotosGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mockPhotos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        final photo = _mockPhotos[index];
        final isSelected = _selectedItemKey == 'photo_$index';
        
        return InkWell(
          onTap: () => _selectItem('photo', index, photo),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: photo['color'].withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppTheme.accentSecondary : AppTheme.borderDark,
                width: isSelected ? 2.0 : 1.0,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(Icons.image, color: photo['color'], size: 28),
                ),
                Positioned(
                  bottom: 6,
                  left: 6,
                  right: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        photo['name'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 1),
                      Text(photo['size'], style: const TextStyle(fontSize: 8, color: AppTheme.textMuted)),
                    ],
                  ),
                ),
                if (isSelected)
                  const Positioned(
                    top: 6,
                    right: 6,
                    child: CircleAvatar(
                      backgroundColor: AppTheme.accentSecondary,
                      radius: 9,
                      child: Icon(Icons.check, size: 10, color: Colors.black),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAudiosList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _mockAudios.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final audio = _mockAudios[index];
        final isSelected = _selectedItemKey == 'audio_$index';
        
        return Container(
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.bgSurface : AppTheme.bgSurface.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.accentSecondary : AppTheme.borderDark,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: ListTile(
            dense: true,
            leading: CircleAvatar(
              backgroundColor: audio['color'].withValues(alpha: 0.2),
              child: Icon(Icons.music_note, color: audio['color'], size: 18),
            ),
            title: Text(
              audio['name'],
              style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            subtitle: Text(
              '${audio['duration'].toInt()}s • ${audio['size']}',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
            ),
            trailing: isSelected 
              ? const Icon(Icons.check_circle, color: AppTheme.accentSecondary, size: 20) 
              : const Icon(Icons.circle_outlined, color: AppTheme.textMuted, size: 18),
            onTap: () => _selectItem('audio', index, audio),
          ),
        );
      },
    );
  }

  Widget _buildBottomActionBar() {
    final hasSelection = _selectedItemData != null;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              hasSelection 
                ? 'Selected: ${_selectedItemData!['name']}' 
                : 'Choose a file to import',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: hasSelection ? AppTheme.textPrimary : AppTheme.textMuted,
                fontSize: 12,
                fontWeight: hasSelection ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: hasSelection ? _handleImport : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentSecondary,
              foregroundColor: Colors.black,
              disabledBackgroundColor: AppTheme.borderDark,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              'Add to Project',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
