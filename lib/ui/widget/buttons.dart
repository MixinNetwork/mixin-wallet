import 'package:flutter/widgets.dart';

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
  Widget build(BuildContext context) => ActionButton(
        name: R.resourcesBackBlackSvg,
        color: context.colorScheme.primaryText,
        padding: const EdgeInsets.all(6),
        size: 24,
        onTap: () {
          if (onTap != null) return onTap?.call();
          context.pop();
        },
      );
}
