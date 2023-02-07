import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    this.name,
    this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(8),
    this.size = 24,
    this.color,
    this.enable = true,
    Key? key,
  })  : assert(name != null || child != null),
        super(key: key);

  final String? name;
  final Widget? child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final double size;
  final Color? color;

  final bool enable;

  @override
  Widget build(BuildContext context) {
    var child = this.child;
    if (name?.isNotEmpty ?? false) {
      child = SvgPicture.asset(
        name!,
        width: size,
        height: size,
        colorFilter:
            color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
      );
    }
    if (!enable) {
      return Opacity(
        opacity: 0.1,
        child: Padding(
          padding: padding,
          child: child,
        ),
      );
    }
    return InkResponse(
      onTap: onTap,
      radius: size,
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
