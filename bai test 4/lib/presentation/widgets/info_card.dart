import 'dart:ui';
import 'package:flutter/material.dart';
import '../../domain/entities/university.dart';
import '../../domain/entities/region.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/node_calculator.dart';

/// Floating glassmorphism info card shown when a node is selected.
class InfoCard extends StatefulWidget {
  final University? university;
  final Region? region;
  final VoidCallback onClose;

  const InfoCard({
    super.key,
    this.university,
    this.region,
    required this.onClose,
  });

  @override
  State<InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: _buildCard(),
      ),
    );
  }

  Widget _buildCard() {
    if (widget.region != null) return _buildRegionCard(widget.region!);
    if (widget.university != null) return _buildUniversityCard(widget.university!);
    return const SizedBox.shrink();
  }

  Widget _buildRegionCard(Region region) {
    return _CardShell(
      accentColor: AppColors.regionColor(region.id),
      onClose: widget.onClose,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(region.emoji,
              style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            region.name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Khu vực',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUniversityCard(University uni) {
    final primaryColor = NodeCalculator.universityPrimaryColor(uni.facultyCount);
    return _CardShell(
      accentColor: primaryColor,
      onClose: widget.onClose,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: primaryColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  uni.type == 'public' ? 'Công lập' : 'Tư thục',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            uni.name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            uni.shortName,
            style: TextStyle(
              color: primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          _StatRow(
            icon: Icons.people_outline_rounded,
            label: 'Sinh viên',
            value: NodeCalculator.formatCount(uni.studentCount),
            color: Colors.blue.shade300,
          ),
          const SizedBox(height: 8),
          _StatRow(
            icon: Icons.school_rounded,
            label: 'Giảng viên',
            value: NodeCalculator.formatCount(uni.facultyCount),
            color: Colors.amber.shade300,
          ),
          const SizedBox(height: 8),
          _StatRow(
            icon: Icons.location_on_outlined,
            label: 'Khu vực',
            value: _regionName(uni.regionId),
            color: AppColors.regionColor(uni.regionId),
          ),
        ],
      ),
    );
  }

  String _regionName(String id) {
    switch (id) {
      case 'north':
        return 'Miền Bắc 🔵';
      case 'central':
        return 'Miền Trung 🟣';
      case 'south':
        return 'Miền Nam 🟢';
      default:
        return id;
    }
  }
}

class _CardShell extends StatelessWidget {
  final Color accentColor;
  final VoidCallback onClose;
  final Widget child;

  const _CardShell({
    required this.accentColor,
    required this.onClose,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 240,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Color.lerp(
                AppColors.backgroundMid, accentColor, 0.08)!
                .withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 16,
              ),
            ],
          ),
          child: Stack(
            children: [
              child,
              Positioned(
                top: -6,
                right: -6,
                child: GestureDetector(
                  onTap: onClose,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
