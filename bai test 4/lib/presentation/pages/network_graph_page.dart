import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/university.dart';
import '../../domain/entities/region.dart';
import '../bloc/graph_bloc.dart';
import '../bloc/graph_event.dart';
import '../bloc/graph_state.dart';
import '../widgets/edge_painter.dart';
import '../widgets/node_widget.dart';
import '../widgets/info_card.dart';

class NetworkGraphPage extends StatefulWidget {
  const NetworkGraphPage({super.key});

  @override
  State<NetworkGraphPage> createState() => _NetworkGraphPageState();
}

class _NetworkGraphPageState extends State<NetworkGraphPage> {
  static const double _canvasWidth = 1200.0;
  static const double _canvasHeight = 1000.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Radial deep-space background
          _buildBackground(),
          // Main graph area
          BlocBuilder<GraphBloc, GraphState>(
            builder: (context, state) {
              if (state is GraphLoading) {
                return const Center(
                  child: _LoadingIndicator(),
                );
              }
              if (state is GraphError) {
                return Center(
                  child: Text(
                    'Lỗi: ${state.message}',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                );
              }
              if (state is GraphLoaded) {
                return _buildGraphView(context, state);
              }
              return const SizedBox.shrink();
            },
          ),
          // Fixed header overlay
          _buildHeader(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.0, -0.3),
          radius: 1.4,
          colors: [
            Color(0xFF0D1B3E),
            Color(0xFF070E20),
            Color(0xFF030710),
          ],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      child: CustomPaint(painter: _StarfieldPainter()),
    );
  }

  Widget _buildGraphView(BuildContext context, GraphLoaded state) {
    return Column(
      children: [
        const SizedBox(height: 120), // Room for the header
        Expanded(
          child: Stack(
            children: [
              // InteractiveViewer for pan/zoom
              InteractiveViewer(
                constrained: false,
                minScale: 0.35,
                maxScale: 3.0,
                boundaryMargin: const EdgeInsets.all(200),
                child: SizedBox(
                  width: _canvasWidth,
                  height: _canvasHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Layer 0: Edges (Bézier curves) — bottom
                      Positioned.fill(
                        child: CustomPaint(
                          painter: EdgePainter(
                            universities: state.universities,
                            regions: state.regions,
                            activeFilter: state.activeFilterRegionId,
                          ),
                        ),
                      ),
                      // Layer 1: University nodes
                      ...state.universities.map((uni) => UniversityNodeWidget(
                            key: ValueKey('uni_${uni.id}'),
                            university: uni,
                            isSelected: state.selectedNodeId == uni.id,
                            opacity: state.opacityForUniversity(uni),
                          )),
                      // Layer 2: Region nodes (on top)
                      ...state.regions.map((region) => RegionNodeWidget(
                            key: ValueKey('region_${region.id}'),
                            region: region,
                            isSelected: state.selectedNodeId == region.id,
                            opacity: state.opacityForRegion(region),
                          )),
                    ],
                  ),
                ),
              ),
              // Floating InfoCard overlay
              if (state.selectedNodeId != null)
                _buildInfoOverlay(context, state),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoOverlay(BuildContext context, GraphLoaded state) {
    University? selectedUni;
    Region? selectedRegion;

    try {
      selectedUni = state.universities
          .firstWhere((u) => u.id == state.selectedNodeId);
    } catch (_) {
      // Not a university, check regions
    }

    if (selectedUni == null) {
      try {
        selectedRegion = state.regions
            .firstWhere((r) => r.id == state.selectedNodeId);
      } catch (_) {}
    }

    return Positioned(
      right: 20,
      bottom: 40,
      child: InfoCard(
        university: selectedUni,
        region: selectedRegion,
        onClose: () {
          context.read<GraphBloc>().add(const SelectNode(null));
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.only(
                top: 48, left: 20, right: 20, bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.backgroundDark.withOpacity(0.95),
                  AppColors.backgroundDark.withOpacity(0.6),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.08),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF60A5FA), Color(0xFFA78BFA)],
                      ).createShader(bounds),
                      child: const Text(
                        '🎓 Mạng lưới Đại học Việt Nam',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '25 trường đại học trên toàn quốc',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 12),
                _FilterChipRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Filter Chip Row
// ──────────────────────────────────────────────────────────────────────────────

class _FilterChipRow extends StatelessWidget {
  final List<_ChipData> _chips = const [
    _ChipData(label: '🌐 Tất cả', regionId: null),
    _ChipData(label: '🔵 Miền Bắc', regionId: 'north'),
    _ChipData(label: '🟣 Miền Trung', regionId: 'central'),
    _ChipData(label: '🟢 Miền Nam', regionId: 'south'),
  ];

  const _FilterChipRow();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GraphBloc, GraphState>(
      builder: (context, state) {
        final activeFilter =
            state is GraphLoaded ? state.activeFilterRegionId : null;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _chips.map((chip) {
              final isActive = activeFilter == chip.regionId;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    context
                        .read<GraphBloc>()
                        .add(FilterByRegion(chip.regionId));
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.chipActive.withOpacity(0.85)
                          : AppColors.chipInactive,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive
                            ? AppColors.chipActive
                            : Colors.white.withOpacity(0.15),
                        width: 1.2,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppColors.chipActive.withOpacity(0.4),
                                blurRadius: 12,
                                spreadRadius: 1,
                              )
                            ]
                          : [],
                    ),
                    child: Text(
                      chip.label,
                      style: TextStyle(
                        color: isActive
                            ? Colors.white
                            : Colors.white.withOpacity(0.6),
                        fontSize: 12,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _ChipData {
  final String label;
  final String? regionId;
  const _ChipData({required this.label, required this.regionId});
}

// ──────────────────────────────────────────────────────────────────────────────
// Star field background painter
// ──────────────────────────────────────────────────────────────────────────────

class _StarfieldPainter extends CustomPainter {
  final List<_Star> _stars = _generateStars(120);

  static List<_Star> _generateStars(int count) {
    // Fixed seed positions to avoid repaints
    final stars = <_Star>[];
    for (int i = 0; i < count; i++) {
      final hash = (i * 2654435761) & 0xFFFFFFFF;
      final x = (hash & 0xFFFF) / 0xFFFF;
      final y = ((hash >> 16) & 0xFFFF) / 0xFFFF;
      final r = 0.5 + (hash % 10) / 20.0;
      final opacity = 0.1 + (hash % 7) / 14.0;
      stars.add(_Star(x, y, r, opacity));
    }
    return stars;
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in _stars) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(star.opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarfieldPainter oldDelegate) => false;
}

class _Star {
  final double x, y, radius, opacity;
  const _Star(this.x, this.y, this.radius, this.opacity);
}

// ──────────────────────────────────────────────────────────────────────────────
// Loading indicator
// ──────────────────────────────────────────────────────────────────────────────

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.northRegion,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Đang tải mạng lưới...',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
