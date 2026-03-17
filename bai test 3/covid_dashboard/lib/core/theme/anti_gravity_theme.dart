import 'package:flutter/material.dart';

class AntiGravityTheme {
  // Base background color (vibrant/dark usually works best for Neumorphism/Glassmorphism with contrast)
  static const Color backgroundColor = Color(0xFF1E1F26);
  static const Color surfaceColor = Color(0xFF272935);
  static const Color accentColor = Color(0xFF00FFC2); // Neon Mint
  static const Color secondaryAccent = Color(0xFFFF007F); // Neon Pink
  static const Color textPrimaryColor = Color(0xFFF0F0F0);
  static const Color textSecondaryColor = Color(0xFF8C92AC);

  // Shadows for Anti Gravity
  // Highlights (top-left) and Shadows (bottom-right)
  static const List<BoxShadow> floatShadows = [
    // Bottom Right Shadow (Darker)
    BoxShadow(
      color: Color(0xFF131418), // Darker than surface
      offset: Offset(8, 8),
      blurRadius: 16,
      spreadRadius: 1,
    ),
    // Top Left Highlight (Lighter)
    BoxShadow(
      color: Color(0xFF3B3D4F), // Lighter than surface
      offset: Offset(-8, -8),
      blurRadius: 16,
      spreadRadius: 1,
    ),
    // Soft underglow for extra 'float' feeling
    BoxShadow(
      color: Color(0x3300FFC2), // Tint of accent
      offset: Offset(0, 15),
      blurRadius: 25,
      spreadRadius: -5,
    ),
  ];

  static const List<BoxShadow> activeFloatShadows = [
    // Bottom Right Shadow (Darker, further)
    BoxShadow(
      color: Color(0xFF131418), // Darker than surface
      offset: Offset(12, 12),
      blurRadius: 20,
      spreadRadius: 2,
    ),
    // Top Left Highlight (Lighter, further)
    BoxShadow(
      color: Color(0xFF3B3D4F), // Lighter than surface
      offset: Offset(-12, -12),
      blurRadius: 20,
      spreadRadius: 2,
    ),
    // Stronger underglow
    BoxShadow(
      color: Color(0x6600FFC2), // Tint of accent
      offset: Offset(0, 20),
      blurRadius: 35,
      spreadRadius: -2,
    ),
  ];
}
