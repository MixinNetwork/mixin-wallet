import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../util/extension/extension.dart';
import '../../util/r.dart';
import 'action_button.dart';
import 'brightness_observer.dart';

class MixinBackButton extends StatelessWidget {
  const MixinBackButton({
    Key? key,
    this.color,
    this.onTap,
  }) : super(key: key);

  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 14),
        child: ActionButton(
          name: R.resourcesIcBackSvg,
          color: color ?? BrightnessData.themeOf(context).icon,
          padding: const EdgeInsets.all(6),
          size: 24,
          onTap: () {
            if (onTap != null) return onTap?.call();
            context.pop();
          },
        ),
      );
}

class MixinBackButton2 extends StatelessWidget {
  const MixinBackButton2({Key? key, this.onTap}) : super(key: key);
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 14),
        child: ActionButton(
          name: R.resourcesBackBlackSvg,
          color: context.colorScheme.primaryText,
          padding: const EdgeInsets.all(6),
          size: 24,
          onTap: () {
            if (onTap != null) return onTap?.call();
            context.pop();
          },
        ),
      );
}

class HeaderButtonBarLayout extends StatelessWidget {
  const HeaderButtonBarLayout({
    Key? key,
    required this.buttons,
  }) : super(key: key);

  final List<HeaderButton> buttons;

  @override
  Widget build(BuildContext context) => Material(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 40,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ...buttons
                  .map<Widget>((e) => Expanded(child: e))
                  .separated(_divider(context))
            ],
          ),
        ),
      );

  Widget _divider(BuildContext context) => Container(
        width: 2,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(1),
          color: context.colorScheme.background,
        ),
      );
}

class HeaderButton extends HookWidget {
  const HeaderButton({
    Key? key,
    required this.child,
    required this.onTap,
  }) : super(key: key);

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final animator = useAnimationController(
      duration: const Duration(milliseconds: 150),
      initialValue: 1,
      lowerBound: 0.3,
      upperBound: 1,
    );
    useAnimation(animator);
    return GestureDetector(
      onTap: onTap,
      onTapDown: (_) => animator.reverse(),
      onTapUp: (_) => animator.forward(),
      onTapCancel: animator.forward,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: DefaultTextStyle(
          style: TextStyle(
            color: context.colorScheme.primaryText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          child: Opacity(
            opacity: animator.value,
            child: child,
          ),
        ),
      ),
    );
  }
}
