import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../domain/entities/university.dart';
import '../../domain/entities/region.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/node_calculator.dart';

/// Custom painter that draws Bézier curve edges from each university node
/// to its corresponding region node. Rendered at the bottom of the Stack.
class EdgePainter extends CustomPainter {
  final List<University> universities;
  final List<Region> regions;
  final String? activeFilter;

  EdgePainter({
    required this.universities,
    required this.regions,
    this.activeFilter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final regionMap = {for (var r in regions) r.id: r};

    for (final uni in universities) {
      final region = regionMap[uni.regionId];
      if (region == null) continue;

      // Compute dynamic opacity for filter
      double opacity = 1.0;
      if (activeFilter != null && uni.regionId != activeFilter) {
        opacity = 0.06;
      }

      final uniRadius = NodeCalculator.calculateUniversityRadius(uni.studentCount);
      final regionRadius = NodeCalculator.regionRadius;

      // Center points of each node
      final uniCenter = Offset(
        uni.position.dx + uniRadius,
        uni.position.dy + uniRadius,
      );
      final regionCenter = Offset(
        region.position.dx + regionRadius,
        region.position.dy + regionRadius,
      );

      // Control points for smooth cubic Bézier
      final dx = (regionCenter.dx - uniCenter.dx) * 0.45;
      // Use dy to create a natural curve arc
      final dy = (regionCenter.dy - uniCenter.dy) * 0.15;

      final cp1 = Offset(uniCenter.dx + dx, uniCenter.dy + dy);
      final cp2 = Offset(regionCenter.dx - dx, regionCenter.dy - dy);

      final path = Path()
        ..moveTo(uniCenter.dx, uniCenter.dy)
        ..cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, regionCenter.dx, regionCenter.dy);

      // Gradient stroke using shader
      final edgeColor = AppColors.edgeColor(uni.regionId);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..shader = ui.Gradient.linear(
          uniCenter,
          regionCenter,
          [
            edgeColor.withValues(alpha: 0.08 * opacity),
            edgeColor.withValues(alpha: 0.7 * opacity),
            edgeColor.withValues(alpha: 0.08 * opacity),
          ],
          [0.0, 0.5, 1.0],
        );

      canvas.drawPath(path, paint);

      // Glow pass — wider, very transparent
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
        ..shader = ui.Gradient.linear(
          uniCenter,
          regionCenter,
          [
            edgeColor.withValues(alpha: 0.0),
            edgeColor.withValues(alpha: 0.25 * opacity),
            edgeColor.withValues(alpha: 0.0),
          ],
          [0.0, 0.5, 1.0],
        );
      canvas.drawPath(path, glowPaint);
    }
  }

  @override
  bool shouldRepaint(EdgePainter oldDelegate) {
    return oldDelegate.universities != universities ||
        oldDelegate.regions != regions ||
        oldDelegate.activeFilter != activeFilter;
  }
}
