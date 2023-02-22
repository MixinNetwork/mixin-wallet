import 'package:flutter/material.dart';

class MixinElevatedButton extends StatelessWidget {
  const MixinElevatedButton({
    required this.onTap,
    required this.child,
    super.key,
    this.primary,
    this.padding = EdgeInsets.zero,
    this.alignment = Alignment.center,
    this.shape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    this.fixedSize,
  });

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
          backgroundColor: primary,
          elevation: 0.0,
          shape: shape,
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          fixedSize: fixedSize,
          alignment: alignment,
        ),
        onPressed: onTap,
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      );
}
