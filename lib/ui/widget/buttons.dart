import 'package:flutter/material.dart';

import '../../util/extension/extension.dart';
import '../../util/r.dart';
import '../router/mixin_routes.dart';
import 'action_button.dart';

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
            if (!context.canPop()) {
              context.replace(homeUri);
              return;
            }
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
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Material(
          color: context.colorScheme.surface,
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

class HeaderButton extends StatelessWidget {
  const HeaderButton({
    Key? key,
    required this.child,
    required this.onTap,
  }) : super(key: key);

  factory HeaderButton.text({
    required String text,
    required VoidCallback onTap,
  }) =>
      HeaderButton(
        onTap: onTap,
        child: SelectableText(
          text,
          onTap: onTap,
          enableInteractiveSelection: false,
        ),
      );

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Center(
          child: DefaultTextStyle.merge(
            style: TextStyle(
              color: context.colorScheme.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            child: child,
          ),
        ),
      );
}

class SendButton extends StatelessWidget {
  const SendButton({
    Key? key,
    required this.onTap,
    required this.enable,
  }) : super(key: key);

  final VoidCallback onTap;
  final bool enable;

  @override
  Widget build(BuildContext context) => ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateColor.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return context.colorScheme.primaryText.withOpacity(0.2);
            }
            return context.colorScheme.primaryText;
          }),
          padding: MaterialStateProperty.all(const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 24,
          )),
          minimumSize: MaterialStateProperty.all(const Size(110, 48)),
          foregroundColor:
              MaterialStateProperty.all(context.colorScheme.background),
          shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
        ),
        onPressed: enable ? onTap : null,
        child: SelectableText(
          context.l10n.send,
          style: TextStyle(
            fontSize: 16,
            color: context.colorScheme.background,
          ),
          onTap: enable ? onTap : null,
          enableInteractiveSelection: false,
        ),
      );
}

class MixinPrimaryTextButton extends StatelessWidget {
  const MixinPrimaryTextButton({
    Key? key,
    required this.onTap,
    required this.text,
    this.enable = true,
  }) : super(key: key);

  final VoidCallback onTap;
  final String text;
  final bool enable;

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: enable ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colorScheme.primaryText,
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 24,
          ),
          minimumSize: const Size(110, 48),
          foregroundColor: context.colorScheme.background,
          shape: const StadiumBorder(),
        ),
        child: SelectableText(
          text,
          onTap: enable ? onTap : null,
          enableInteractiveSelection: false,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
