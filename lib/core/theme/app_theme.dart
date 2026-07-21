import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors - Dark Cyberpunk Studio Palette
  static const Color bgDark = Color(0xFF0D0F14);
  static const Color bgCard = Color(0xFF161A23);
  static const Color bgSurface = Color(0xFF1E2430);
  static const Color bgElevated = Color(0xFF283040);
  
  static const Color accentPrimary = Color(0xFF6C5CE7); // Deep Violet
  static const Color accentSecondary = Color(0xFF00CEC9); // Cyan Glow
  static const Color accentPink = Color(0xFFFF7675); // Neon Pink
  static const Color accentGold = Color(0xFFFDCB6E); // Gold/Yellow
  static const Color accentGreen = Color(0xFF55E6C1); // Emerald Green
  
  static const Color textPrimary = Color(0xFFF1F2F6);
  static const Color textSecondary = Color(0xFFA4B0BE);
  static const Color textMuted = Color(0xFF747D8C);
  
  static const Color borderDark = Color(0xFF2F3542);
  static const Color dividerColor = Color(0xFF252A36);
  
  // Layer Type Specific Colors for Timeline Tracks
  static const Color layerVideo = Color(0xFF6C5CE7);
  static const Color layerAudio = Color(0xFF00CEC9);
  static const Color layerImage = Color(0xFFFD79A8);
  static const Color layerText = Color(0xFFFDCB6E);
  static const Color layerSticker = Color(0xFFE84393);
  static const Color layerDrawing = Color(0xFF00B894);
  static const Color layerAI = Color(0xFFA29BFE);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      primaryColor: accentPrimary,
      colorScheme: const ColorScheme.dark(
        primary: accentPrimary,
        secondary: accentSecondary,
        surface: bgCard,
        error: accentPink,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: bgCard,
        modalBackgroundColor: bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }

  // Glassmorphic Card Container Decoration
  static BoxDecoration glassDecoration({
    Color borderColor = borderDark,
    double radius = 12.0,
    Color bgColor = bgCard,
  }) {
    return BoxDecoration(
      color: bgColor.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor.withValues(alpha: 0.5), width: 1.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
