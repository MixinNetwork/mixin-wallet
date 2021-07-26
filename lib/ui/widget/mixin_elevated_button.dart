import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MixinElevatedButton extends StatelessWidget {
  const MixinElevatedButton({
    Key? key,
    required this.onTap,
    required this.child,
    this.primary,
    this.padding = EdgeInsets.zero,
    this.alignment = Alignment.center,
    this.shape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    this.fixedSize,
  }) : super(key: key);

  final VoidCallback? onTap;
  final Widget? child;
  final Color? primary;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;
  final OutlinedBorder shape;
  final Size? fixedSize;

  @override
  Widget build(BuildContext context) => ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: primary,
          elevation: 0.0,
          shape: shape,
          padding: padding,
          minimumSize: Size.zero,
          fixedSize: fixedSize,
          alignment: alignment,
        ),
        onPressed: onTap,
        child: child,
      );
}
