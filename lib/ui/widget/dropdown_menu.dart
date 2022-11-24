import 'package:flutter/material.dart';
import 'package:mixin_wallet/ui/widget/text.dart';

import '../../util/extension/extension.dart';

class MixinDropdownMenu extends StatelessWidget {
  const MixinDropdownMenu({
    Key? key,
    required this.label,
  }) : super(key: key);

  final Widget label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            const SizedBox(width: 20),
            DefaultTextStyle.merge(
              style: TextStyle(
                fontSize: 16,
                color: context.colorScheme.thirdText,
              ),
              child: label,
            ),
            const SizedBox(width: 10),
          ],
        ),
      );
}
