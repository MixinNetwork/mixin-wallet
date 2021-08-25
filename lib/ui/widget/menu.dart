import 'package:flutter/material.dart';

import 'brightness_observer.dart';

class MenuItemWidget extends StatelessWidget {
  const MenuItemWidget({
    Key? key,
    required this.title,
    required this.leading,
    this.topRounded = false,
    this.bottomRounded = false,
    this.trailing,
    this.onTap,
    this.subtitle,
  }) : super(key: key);

  final Widget title;
  final Widget leading;
  final Widget? trailing;
  final Widget? subtitle;

  final VoidCallback? onTap;

  final bool topRounded;
  final bool bottomRounded;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: topRounded ? const Radius.circular(12) : Radius.zero,
            bottom: bottomRounded ? const Radius.circular(12) : Radius.zero,
          ),
          color: context.colorScheme.surface,
        ),
        padding: EdgeInsets.only(
          top: topRounded ? 10 : 0,
          bottom: bottomRounded ? 10 : 0,
        ),
        child: Material(
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              height: 64,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 20),
                  SizedBox.square(dimension: 24, child: leading),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(flex: 2),
                      DefaultTextStyle(
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: context.colorScheme.primaryText,
                        ),
                        child: title,
                      ),
                      if (subtitle != null) ...[
                        const Spacer(flex: 1),
                        DefaultTextStyle(
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
