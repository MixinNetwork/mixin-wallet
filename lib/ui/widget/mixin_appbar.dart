import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../util/extension/extension.dart';
import 'buttons.dart';

class MixinAppBar extends StatelessWidget with PreferredSizeWidget {
  const MixinAppBar({
    Key? key,
    this.leading,
    this.title,
    this.backgroundColor,
    this.backButtonColor,
    this.actions,
    this.bottom,
  }) : super(key: key);

  final Widget? leading;

  final Widget? title;

  final Color? backgroundColor;

  final List<Widget>? actions;

  final Color? backButtonColor;

  final PreferredSizeWidget? bottom;

  List<Widget> get validActions {
    final isNotEmpty = actions?.isNotEmpty == true;
    return [
      if (isNotEmpty) ...actions!,
      if (isNotEmpty) const SizedBox(width: 110),
    ];
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: AppBar(
          leading: leading ??
              (Navigator.canPop(context)
                  ? MixinBackButton(color: backButtonColor)
                  : null),
          toolbarHeight: preferredSize.height - 2,
          elevation: 0,
          titleSpacing: 0,
          actions: validActions,
          centerTitle: false,
          title: title,
          titleTextStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
          backgroundColor: backgroundColor ?? context.theme.accent,
          bottom: bottom,
        ),
      );

  @override
  Size get preferredSize =>
      Size.fromHeight(48 + (bottom?.preferredSize.height ?? 0));
}
