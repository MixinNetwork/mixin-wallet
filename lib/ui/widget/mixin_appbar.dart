import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../util/constants.dart';
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
  }) : super(key: key);

  final Widget? leading;

  final Widget? title;

  final Color? backgroundColor;

  final List<Widget>? actions;

  final Color? backButtonColor;

  List<Widget> get validActions {
    final isNotEmpty = actions?.isNotEmpty == true;
    return [
      if (isNotEmpty) ...actions!,
      if (isNotEmpty) const SizedBox(width: 122),
    ];
  }

  @override
  Widget build(BuildContext context) => AppBar(
        leading: leading ??
            (Navigator.canPop(context)
                ? MixinBackButton(color: backButtonColor)
                : null),
        toolbarHeight: preferredSize.height,
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
      );

  @override
  Size get preferredSize => const Size.fromHeight(44);
}

class ListRoundedHeaderContainer extends StatelessWidget {
  const ListRoundedHeaderContainer({
    Key? key,
    this.radius = topRadius,
    this.height = 50,
    required this.child,
  }) : super(key: key);

  final double height;
  final double radius;

  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 20,
                color: context.theme.accent,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(radius)),
                color: context.theme.background,
              ),
              child: child,
            ),
          ],
        ),
      );
}
