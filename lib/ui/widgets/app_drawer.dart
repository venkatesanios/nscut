import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/timeline.dart';
import '../sheets/settings_sheet.dart';

class AppDrawer extends StatefulWidget {
  final TimelineState timeline;
  final VoidCallback? onTourRequested;

  const AppDrawer({super.key, required this.timeline, this.onTourRequested});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String _userName = 'Creative User';
  String _userEmail = 'user@example.com';

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // User Profile Header
          _buildProfileHeader(),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Profile Section Header
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Text(
                    'Profile',
                    style: TextStyle(
                      color: AppTheme.accentSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                _buildDrawerItem(
                  icon: Icons.account_circle_outlined,
                  label: 'Google Account',
                  onTap: () => _showGoogleAccountDialog(context),
                ),
                _buildDrawerItem(
                  icon: Icons.edit_outlined,
                  label: 'Edit Profile',
                  onTap: () => _showEditProfileDialog(context),
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(color: AppTheme.dividerColor, height: 24),
                ),

                _buildDrawerItem(
                  icon: Icons.home_outlined,
                  label: 'Home',
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Workspace active',
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                        ),
                        backgroundColor: AppTheme.bgSurface,
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  trailing: const Text('⚙️', style: TextStyle(fontSize: 16)),
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    _showSettingsSheet(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.help_outline,
                  label: 'Help Center',
                  trailing: const Text('❓', style: TextStyle(fontSize: 16)),
                  onTap: () => _showHelpCenterDialog(context),
                ),
                _buildDrawerItem(
                  icon: Icons.explore_outlined,
                  label: 'Take App Tour',
                  trailing: const Text('🚀', style: TextStyle(fontSize: 16)),
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    widget.onTourRequested?.call();
                  },
                ),
              ],
            ),
          ),

          // Bottom Action Footer
          const Divider(color: AppTheme.dividerColor, height: 1),
          _buildDrawerItem(
            icon: Icons.logout,
            label: 'Sign Out',
            iconColor: AppTheme.accentPink,
            trailing: const Text('🚪', style: TextStyle(fontSize: 16)),
            onTap: () => _showSignOutDialog(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final initials = _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      decoration: const BoxDecoration(
        color: AppTheme.bgSurface,
        border: Border(bottom: BorderSide(color: AppTheme.dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Glowing round profile picture/avatar
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppTheme.accentPrimary, AppTheme.accentSecondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentPrimary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            padding: const EdgeInsets.all(2.5), // Border thickness
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.bgCard,
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: const TextStyle(
                  color: AppTheme.accentSecondary,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _userName,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userEmail,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppTheme.textSecondary, size: 22),
      title: Text(
        label,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
      ),
      trailing: trailing,
      onTap: onTap,
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }

  void _showGoogleAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.account_circle_outlined, color: AppTheme.accentSecondary, size: 24),
            const SizedBox(width: 10),
            const Text(
              'Google Account',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status: Sync Enabled',
              style: TextStyle(color: AppTheme.accentGreen, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            const Text(
              'Connected Email:',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              _userEmail,
              style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your projects, stickers, and preferences are automatically synced across devices via cloud integration.',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppTheme.accentSecondary)),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(text: _userName);
    final emailController = TextEditingController(text: _userEmail);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.edit_outlined, color: AppTheme.accentPrimary, size: 24),
            const SizedBox(width: 10),
            const Text(
              'Edit Profile',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              decoration: const InputDecoration(
                labelText: 'Full Name',
                labelStyle: TextStyle(color: AppTheme.textSecondary),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.borderDark)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.accentPrimary)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              decoration: const InputDecoration(
                labelText: 'Email Address',
                labelStyle: TextStyle(color: AppTheme.textSecondary),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.borderDark)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.accentPrimary)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (nameController.text.trim().isNotEmpty && emailController.text.trim().isNotEmpty) {
                setState(() {
                  _userName = nameController.text.trim();
                  _userEmail = emailController.text.trim();
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SettingsSheet(timeline: widget.timeline),
    );
  }

  void _showHelpCenterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.help_outline_rounded, color: AppTheme.accentSecondary, size: 24),
            const SizedBox(width: 10),
            const Text(
              'Help Center',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Frequently Asked Questions',
                style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              SizedBox(height: 10),
              Text(
                'Q: How do I export my video?',
                style: TextStyle(color: AppTheme.accentSecondary, fontWeight: FontWeight.w600, fontSize: 12),
              ),
              Text(
                'A: Tap the Export button in the bottom tool bar to open resolution options and trigger high-speed rendering.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, height: 1.4),
              ),
              SizedBox(height: 12),
              Text(
                'Q: Can I edit drawing layers?',
                style: TextStyle(color: AppTheme.accentSecondary, fontWeight: FontWeight.w600, fontSize: 12),
              ),
              Text(
                'A: Yes, select the drawing track and enter the canvas sheet to draw and edit curves dynamically.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it', style: TextStyle(color: AppTheme.accentSecondary)),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: AppTheme.accentPink, size: 24),
            SizedBox(width: 10),
            Text(
              'Sign Out',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to sign out and exit the application?',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentPink,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context); // Close Dialog
              SystemNavigator.pop(); // Exit app
            },
            child: const Text('Exit App', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
