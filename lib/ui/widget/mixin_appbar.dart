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
    this.actions,
  }) : super(key: key);

  final Widget? leading;

  final Widget? title;

  final Color? backgroundColor;

  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) => AppBar(
        leading: leading ??
            (Navigator.canPop(context) ? const MixinBackButton() : null),
        toolbarHeight: preferredSize.height,
        elevation: 0,
        actions: actions,
        centerTitle: false,
        title: title,
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: Colors.white,
        ),
        backgroundColor: backgroundColor ?? context.theme.accent,
      );

  @override
  Size get preferredSize => const Size.fromHeight(44);
}
