import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../util/extension/extension.dart';

class MixinAppBar extends StatelessWidget with PreferredSizeWidget {
  const MixinAppBar({
    Key? key,
    this.leading,
  }) : super(key: key);

  final Widget? leading;

  @override
  Widget build(BuildContext context) => AppBar(
        leading: leading,
        toolbarHeight: preferredSize.height,
        elevation: 0,
        backgroundColor: context.theme.accent,
      );

  @override
  Size get preferredSize => const Size.fromHeight(44);
}
