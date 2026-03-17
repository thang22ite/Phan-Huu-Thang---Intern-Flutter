import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/university.dart';
import '../../domain/entities/region.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/physics_config.dart';
import '../../core/utils/node_calculator.dart';
import '../bloc/graph_bloc.dart';
import '../bloc/graph_event.dart';

/// A draggable, spring-physics node representing either a Region or University.
class NodeWidget extends StatefulWidget {
  final String nodeId;
  final String label;
  final Offset position;
  final double radius;
  final List<Color> gradientColors;
  final List<BoxShadow> glowShadows;
  final bool isRegion;
  final bool isSelected;
  final double opacity;

  const NodeWidget({
    super.key,
    required this.nodeId,
    required this.label,
    required this.position,
    required this.radius,
    required this.gradientColors,
    required this.glowShadows,
    this.isRegion = false,
    this.isSelected = false,
    this.opacity = 1.0,
  });

  @override
  State<NodeWidget> createState() => _NodeWidgetState();
}

class _NodeWidgetState extends State<NodeWidget>
    with TickerProviderStateMixin {
  late AnimationController _springController;
  late AnimationController _bobController;
  late Animation<double> _bobAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  bool _isDragging = false;

  @override
  void initState() {
    super.initState();

    // Spring controller for bounce-back on drag release
    _springController = AnimationController.unbounded(vsync: this);

    // Gentle floating bob animation
    _bobController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: (1000 / PhysicsConfig.bobFrequency).round(),
      ),
    )..repeat(reverse: true);

    _bobAnimation = Tween<double>(
      begin: -PhysicsConfig.bobAmplitude,
      end: PhysicsConfig.bobAmplitude,
    ).animate(CurvedAnimation(
      parent: _bobController,
      curve: Curves.easeInOut,
    ));

    // Scale animation for press effect
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      value: 1.0,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: PhysicsConfig.pressedScale,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _springController.dispose();
    _bobController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
    _bobController.stop();
    _springController.stop();
    _scaleController.forward();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final newPosition = Offset(
      widget.position.dx + details.delta.dx,
      widget.position.dy + details.delta.dy,
    );
    context.read<GraphBloc>().add(UpdateNodePosition(
          nodeId: widget.nodeId,
          position: newPosition,
          isRegion: widget.isRegion,
        ));
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
    _scaleController.reverse();
    // Resume bob
    _bobController.repeat(reverse: true);

    // Spring bounce simulation using velocity
    final velocity = details.velocity.pixelsPerSecond;
    final spring = SpringDescription(
      mass: PhysicsConfig.nodeMass,
      stiffness: PhysicsConfig.springStiffness,
      damping: PhysicsConfig.springDamping,
    );
    final sim = SpringSimulation(spring, 0, 0, velocity.dy * 0.002);
    _springController.animateWith(sim);
  }

  void _onTap() {
    context.read<GraphBloc>().add(SelectNode(widget.nodeId));
  }

  @override
  Widget build(BuildContext context) {
    final diameter = widget.radius * 2;

    return AnimatedPositioned(
      duration: Duration(
        milliseconds: _isDragging ? 0 : PhysicsConfig.opacityTransitionMs,
      ),
      curve: Curves.easeOut,
      left: widget.position.dx,
      top: widget.position.dy,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: PhysicsConfig.opacityTransitionMs),
        opacity: widget.opacity,
        child: AnimatedBuilder(
          animation: Listenable.merge([_bobAnimation, _scaleAnimation]),
          builder: (context, child) {
            return Transform.translate(
              offset: _isDragging ? Offset.zero : Offset(0, _bobAnimation.value),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            onTap: _onTap,
            child: _buildNodeBody(diameter),
          ),
        ),
      ),
    );
  }

  Widget _buildNodeBody(double diameter) {
    return SizedBox(
      width: diameter,
      height: diameter,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              widget.gradientColors.first.withValues(alpha: 0.9),
              widget.gradientColors.last,
            ],
            center: Alignment(-0.3, -0.3),
            radius: 0.85,
          ),
          boxShadow: [
            ...widget.glowShadows,
            if (widget.isSelected)
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.6),
                blurRadius: 20,
                spreadRadius: 4,
              ),
          ],
          border: Border.all(
            color: widget.isSelected
                ? Colors.white.withValues(alpha: 0.9)
                : AppColors.glassBorder,
            width: widget.isSelected ? 2.5 : 1.2,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Inner glass shine
            Positioned(
              top: diameter * 0.1,
              left: diameter * 0.15,
              child: Container(
                width: diameter * 0.4,
                height: diameter * 0.25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(diameter),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.35),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Label
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                widget.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: widget.isRegion ? 11 : 9,
                  height: 1.2,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.8),
                      blurRadius: 4,
                    ),
                  ],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Factory constructors for Region & University nodes
// ──────────────────────────────────────────────────────────────────────────────

class RegionNodeWidget extends StatelessWidget {
  final Region region;
  final bool isSelected;
  final double opacity;

  const RegionNodeWidget({
    super.key,
    required this.region,
    this.isSelected = false,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return NodeWidget(
      key: ValueKey('region_${region.id}'),
      nodeId: region.id,
      label: '${region.emoji}\n${region.name}',
      position: region.position,
      radius: NodeCalculator.regionRadius,
      gradientColors: _gradientColors(region.id),
      glowShadows: AppColors.regionGlow(region.id),
      isRegion: true,
      isSelected: isSelected,
      opacity: opacity,
    );
  }

  List<Color> _gradientColors(String id) {
    final g = AppColors.regionGradient(id);
    return List<Color>.from(g.colors);
  }
}

class UniversityNodeWidget extends StatelessWidget {
  final University university;
  final bool isSelected;
  final double opacity;

  const UniversityNodeWidget({
    super.key,
    required this.university,
    this.isSelected = false,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final colors =
        NodeCalculator.universityGradientColors(university.facultyCount);
    final primaryColor = NodeCalculator.universityPrimaryColor(university.facultyCount);

    return NodeWidget(
      key: ValueKey('uni_${university.id}'),
      nodeId: university.id,
      label: university.shortName,
      position: university.position,
      radius: NodeCalculator.calculateUniversityRadius(university.studentCount),
      gradientColors: colors,
      glowShadows: AppColors.universityGlow(primaryColor),
      isRegion: false,
      isSelected: isSelected,
      opacity: opacity,
    );
  }
}
