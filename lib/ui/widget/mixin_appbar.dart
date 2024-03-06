import 'package:flutter/material.dart';

import '../../util/extension/extension.dart';
import '../../util/mixin_context.dart';
import 'buttons.dart';

class MixinAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MixinAppBar({
    super.key,
    this.leading,
    this.title,
    this.backgroundColor,
    this.backButtonColor,
    this.actions,
    this.bottom,
    this.centerTitle = false,
  });

  final Widget? leading;

  final Widget? title;

  final Color? backgroundColor;

  final List<Widget>? actions;

  final Color? backButtonColor;

  final PreferredSizeWidget? bottom;

  final bool centerTitle;

  List<Widget> get validActions {
    final isNotEmpty = actions?.isNotEmpty ?? false;
    final ctx = getMixinContext();
    return [
      if (isNotEmpty) ...actions!,
      if (isNotEmpty && ctx.isNotEmpty && ctx['platform'] != 'Desktop')
        const SizedBox(width: 110),
    ];
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: AppBar(
          leading: Center(
            child: leading ??
                (Navigator.canPop(context)
                    ? MixinBackButton(color: backButtonColor)
                    : null),
          ),
          toolbarHeight: preferredSize.height - 2,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: 0,
          actions: validActions,
          centerTitle: centerTitle,
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
