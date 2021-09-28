import 'package:flutter/material.dart';

import '../../util/extension/extension.dart';

class TipTile extends StatelessWidget {
  const TipTile({
    Key? key,
    required this.text,
    this.highlight,
    this.highlightColor,
  }) : super(key: key);

  final String text;
  final String? highlight;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: context.colorScheme.thirdText,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
              child: SelectableText.rich(
            text.highlight(
              TextStyle(
                color: context.colorScheme.thirdText,
                fontSize: 14,
              ),
              highlight,
              TextStyle(
                  color: highlightColor ?? context.colorScheme.primaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
          )),
        ],
      );
}
