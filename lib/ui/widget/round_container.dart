import 'package:flutter/widgets.dart';

class RoundContainer extends StatelessWidget {
  const RoundContainer({
    Key? key,
    required this.child,
    this.height = 56,
    this.padding = const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
    this.radius = 12,
    this.color = const Color(0xfff8f8f8),
  }) : super(key: key);

  final Widget child;
  final double? height;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: color,
        ),
        child: child,
      );
}
