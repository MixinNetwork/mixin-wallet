import 'package:flutter/material.dart';

import 'brightness_observer.dart';

class MenuItemWidget extends StatelessWidget {
  const MenuItemWidget({
    required this.title,
    super.key,
    this.leading,
    this.topRounded = false,
    this.bottomRounded = false,
    this.trailing,
    this.onTap,
    this.subtitle,
  });

  final Widget title;
  final Widget? leading;
  final Widget? trailing;
  final Widget? subtitle;

  final VoidCallback? onTap;

  final bool topRounded;
  final bool bottomRounded;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.vertical(
      top: topRounded ? const Radius.circular(12) : Radius.zero,
      bottom: bottomRounded ? const Radius.circular(12) : Radius.zero,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: context.colorScheme.surface,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: SizedBox(
            height: 64,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 20),
                if (leading != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SizedBox.square(dimension: 24, child: leading),
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(flex: 2),
                    DefaultTextStyle.merge(
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: context.colorScheme.primaryText,
                      ),
                      child: title,
                    ),
                    if (subtitle != null) ...[
                      const Spacer(flex: 1),
                      DefaultTextStyle.merge(
                        style: TextStyle(
                          fontSize: 14,
                          height: 1,
                          color: context.colorScheme.thirdText,
                        ),
                        child: subtitle!,
                      ),
                    ],
                    const Spacer(flex: 2),
                  ],
                ),
                const Spacer(),
                if (trailing != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: trailing,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
