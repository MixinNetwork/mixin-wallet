import 'package:flutter/material.dart';

class RoundContainer extends StatelessWidget {
  const RoundContainer({
    required this.child,
    super.key,
    this.height = 56,
    this.padding = const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
    this.alignment,
    this.radius = 12,
    this.color = const Color(0xfff8f8f8),
  });

  final Widget child;
  final double? height;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry? alignment;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) => Material(
        borderRadius: BorderRadius.circular(radius),
        color: color,
        child: Container(
          width: double.infinity,
          height: height,
          alignment: alignment,
          padding: padding,
          child: child,
        ),
      );
}
