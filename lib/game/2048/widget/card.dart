import 'package:flutter/material.dart';
import 'package:sit/design/widgets/glassmorphic.dart';

class StyledCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Gradient? gradient;
  final EdgeInsetsGeometry? margin;

  const StyledCard({
    super.key,
    required this.child,
    this.color,
    this.margin,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final color = this.color;
    return GlassmorphicContainer(
      margin: margin,
      gradient: gradient ?? (color != null ? RadialGradient(colors: [color], stops: const [1]) : null),
      child: child,
    );
  }
}
