import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../generated/r.dart';
import '../../../util/extension/extension.dart';

class EmptyLayout extends StatelessWidget {
  const EmptyLayout({
    Key? key,
    required this.content,
  }) : super(key: key);

  final String content;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 100),
          SvgPicture.asset(
            R.resourcesEmptyTransactionGreySvg,
            width: 80,
            height: 80,
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              color: context.colorScheme.thirdText,
              fontSize: 14,
            ),
          ),
          const Spacer(flex: 164),
        ],
      );
}
