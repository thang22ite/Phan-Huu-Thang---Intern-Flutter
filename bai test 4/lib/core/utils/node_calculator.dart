import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class NodeCalculator {
  NodeCalculator._();

  // University radius: scales from 24 to 56 px based on student count
  static double calculateUniversityRadius(int studentCount) {
    const double minRadius = 24.0;
    const double maxRadius = 56.0;
    const int minStudents = 5000;
    const int maxStudents = 80000;

    final double clamped = studentCount
        .clamp(minStudents, maxStudents)
        .toDouble();
    final double t = (clamped - minStudents) / (maxStudents - minStudents);
    return minRadius + t * (maxRadius - minRadius);
  }

  // Region node radius is fixed large
  static const double regionRadius = 52.0;

  /// Returns gradient colors based on faculty count.
  /// low < 500 → slate, 500-1000 → blue, 1000-2000 → violet, >2000 → amber
  static List<Color> universityGradientColors(int facultyCount) {
    if (facultyCount < 500) {
      return AppColors.universityLow;
    } else if (facultyCount < 1000) {
      return AppColors.universityMid;
    } else if (facultyCount < 2000) {
      return AppColors.universityHigh;
    } else {
      return AppColors.universityVeryHigh;
    }
  }

  /// Returns primary color for glow/shadow based on faculty count gradient.
  static Color universityPrimaryColor(int facultyCount) {
    final colors = universityGradientColors(facultyCount);
    return colors.last;
  }

  /// Formats large numbers with K/M suffix.
  static String formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  /// Calculates the center point of a node given top-left offset and radius.
  static Offset nodeCenter(Offset topLeft, double radius) {
    return Offset(topLeft.dx + radius, topLeft.dy + radius);
  }
}
