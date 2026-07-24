import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class TourStep {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;

  const TourStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });
}

class AppTourOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const AppTourOverlay({super.key, required this.onComplete});

  @override
  State<AppTourOverlay> createState() => _AppTourOverlayState();
}

class _AppTourOverlayState extends State<AppTourOverlay>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late final AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;

  static const List<TourStep> _steps = [
    TourStep(
      title: 'Welcome to nscut PRO 🎬',
      description:
          'Your premium multi-layer video editor. Let\'s take a quick tour '
          'of the workspace to help you get started creating stunning content!',
      icon: Icons.movie_filter,
      accentColor: AppTheme.accentPrimary,
    ),
    TourStep(
      title: 'Top Navigation Bar',
      description:
          'Adjust the aspect ratio, view the live timecode, undo/redo edits, '
          'and hit Export when your project is ready. Tap the menu icon to '
          'access your profile, settings, and more.',
      icon: Icons.space_dashboard_outlined,
      accentColor: AppTheme.accentSecondary,
    ),
    TourStep(
      title: 'Preview Monitor',
      description:
          'This is your real-time preview canvas. All layers — video, images, '
          'stickers, text, and drawings — are composited here. Tap and drag '
          'to reposition selected layers.',
      icon: Icons.personal_video,
      accentColor: AppTheme.accentGold,
    ),
    TourStep(
      title: 'Multi-Track Timeline',
      description:
          'Manage all your media tracks here. Each colored bar represents a '
          'layer on the timeline. Tap a clip to select it, drag to reposition, '
          'and use pinch or the zoom slider to scale the view.',
      icon: Icons.view_timeline,
      accentColor: AppTheme.accentGreen,
    ),
    TourStep(
      title: 'Quick Actions & Import',
      description:
          'Use the bottom toolbar to open module editors — Video, Audio, '
          'Image, Stickers, Text, Drawing, AI Effects, and Export. Tap the '
          '"Import" button to add media from your phone gallery!',
      icon: Icons.dashboard_customize,
      accentColor: AppTheme.accentPink,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      _animController.reverse().then((_) {
        setState(() => _currentStep++);
        _animController.forward();
      });
    } else {
      widget.onComplete();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _animController.reverse().then((_) {
        setState(() => _currentStep--);
        _animController.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    final screenSize = MediaQuery.sizeOf(context);

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Semi-transparent background with tap to skip
          GestureDetector(
            onTap: () {}, // absorb taps
            child: Container(
              width: screenSize.width,
              height: screenSize.height,
              color: Colors.black.withValues(alpha: 0.75),
            ),
          ),

          // Animated card
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnim.value,
                child: Transform.translate(
                  offset: Offset(0, _slideAnim.value),
                  child: child,
                ),
              );
            },
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: _buildTourCard(step),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTourCard(TourStep step) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: AppTheme.bgCard.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: step.accentColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: step.accentColor.withValues(alpha: 0.15),
            blurRadius: 30,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  step.accentColor.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: step.accentColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: step.accentColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child:
                      Icon(step.icon, color: step.accentColor, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  step.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),

          // Description
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: Text(
              step.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),

          // Progress dots
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_steps.length, (index) {
                final isActive = index == _currentStep;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? step.accentColor
                        : AppTheme.textMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),

          // Step counter
          Text(
            'Step ${_currentStep + 1} of ${_steps.length}',
            style: TextStyle(
              color: step.accentColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),

          // Action buttons
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Row(
              children: [
                // Skip button
                TextButton(
                  onPressed: widget.onComplete,
                  child: const Text(
                    'Skip Tour',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ),
                const Spacer(),
                // Back button
                if (_currentStep > 0)
                  TextButton(
                    onPressed: _prevStep,
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back_ios, size: 14),
                        SizedBox(width: 4),
                        Text('Back', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                const SizedBox(width: 8),
                // Next / Finish button
                ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: step.accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    shadowColor: step.accentColor.withValues(alpha: 0.4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentStep == _steps.length - 1
                            ? 'Start Editing!'
                            : 'Next',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _currentStep == _steps.length - 1
                            ? Icons.check
                            : Icons.arrow_forward_ios,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
