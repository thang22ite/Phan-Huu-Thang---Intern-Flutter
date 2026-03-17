import 'package:flutter/material.dart';
import '../../../core/theme/anti_gravity_theme.dart';

class AntiGravityContainer extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double? width;
  final double? height;

  const AntiGravityContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius = 20.0,
    this.width,
    this.height,
  });

  @override
  State<AntiGravityContainer> createState() => _AntiGravityContainerState();
}

class _AntiGravityContainerState extends State<AntiGravityContainer> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        width: widget.width,
        height: widget.height,
        padding: widget.padding,
        transform: Matrix4.translationValues(0, _isHovering ? -8 : 0, 0),
        decoration: BoxDecoration(
          color: AntiGravityTheme.surfaceColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: _isHovering
              ? AntiGravityTheme.activeFloatShadows
              : AntiGravityTheme.floatShadows,
          border: Border.all(
            color: _isHovering 
                ? AntiGravityTheme.accentColor.withOpacity(0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
