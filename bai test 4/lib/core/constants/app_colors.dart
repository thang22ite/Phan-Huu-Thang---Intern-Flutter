import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Background
  static const Color backgroundDark = Color(0xFF050A18);
  static const Color backgroundMid = Color(0xFF0A1628);

  // Region node colors
  static const Color northRegion = Color(0xFF4FC3F7);
  static const Color centralRegion = Color(0xFFA78BFA);
  static const Color southRegion = Color(0xFF34D399);

  // Region gradients
  static const LinearGradient northGradient = LinearGradient(
    colors: [Color(0xFF1E90FF), Color(0xFF00CFFD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient centralGradient = LinearGradient(
    colors: [Color(0xFF9333EA), Color(0xFFC084FC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient southGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // University node gradients (by faculty count: low → high)
  static const List<Color> universityLow = [Color(0xFF334155), Color(0xFF64748B)];
  static const List<Color> universityMid = [Color(0xFF1E3A5F), Color(0xFF2563EB)];
  static const List<Color> universityHigh = [Color(0xFF6D28D9), Color(0xFF8B5CF6)];
  static const List<Color> universityVeryHigh = [Color(0xFFB45309), Color(0xFFF59E0B)];

  // Edge colors
  static const Color edgeNorth = Color(0x884FC3F7);
  static const Color edgeCentral = Color(0x88A78BFA);
  static const Color edgeSouth = Color(0x8834D399);

  // Glassmorphism
  static const Color glassFill = Color(0x14FFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glowWhite = Color(0x22FFFFFF);

  // Text
  static const Color textPrimary = Color(0xFFE2E8F0);
  static const Color textSecondary = Color(0xFF94A3B8);

  // Filter chip
  static const Color chipActive = Color(0xFF3B82F6);
  static const Color chipInactive = Color(0x33FFFFFF);

  // Glow shadow
  static List<BoxShadow> northGlow = [
    BoxShadow(color: northRegion.withValues(alpha: 0.6), blurRadius: 24, spreadRadius: 4),
    BoxShadow(color: northRegion.withValues(alpha: 0.3), blurRadius: 48, spreadRadius: 8),
    const BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 4)),
  ];
  static List<BoxShadow> centralGlow = [
    BoxShadow(color: centralRegion.withValues(alpha: 0.6), blurRadius: 24, spreadRadius: 4),
    BoxShadow(color: centralRegion.withValues(alpha: 0.3), blurRadius: 48, spreadRadius: 8),
    const BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 4)),
  ];
  static List<BoxShadow> southGlow = [
    BoxShadow(color: southRegion.withValues(alpha: 0.6), blurRadius: 24, spreadRadius: 4),
    BoxShadow(color: southRegion.withValues(alpha: 0.3), blurRadius: 48, spreadRadius: 8),
    const BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 4)),
  ];

  static List<BoxShadow> universityGlow(Color color) => [
        BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 18, spreadRadius: 2),
        BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 32, spreadRadius: 4),
        const BoxShadow(color: Color(0x44000000), blurRadius: 6, offset: Offset(0, 3)),
      ];

  static Color regionColor(String regionId) {
    switch (regionId) {
      case 'north':
        return northRegion;
      case 'central':
        return centralRegion;
      case 'south':
        return southRegion;
      default:
        return northRegion;
    }
  }

  static LinearGradient regionGradient(String regionId) {
    switch (regionId) {
      case 'north':
        return northGradient;
      case 'central':
        return centralGradient;
      case 'south':
        return southGradient;
      default:
        return northGradient;
    }
  }

  static List<BoxShadow> regionGlow(String regionId) {
    switch (regionId) {
      case 'north':
        return northGlow;
      case 'central':
        return centralGlow;
      case 'south':
        return southGlow;
      default:
        return northGlow;
    }
  }

  static Color edgeColor(String regionId) {
    switch (regionId) {
      case 'north':
        return edgeNorth;
      case 'central':
        return edgeCentral;
      case 'south':
        return edgeSouth;
      default:
        return edgeNorth;
    }
  }
}
