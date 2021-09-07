import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../util/extension/extension.dart';
import 'brightness_observer.dart';

class TipTile extends StatelessWidget {
  const TipTile({
    Key? key,
    required this.text,
    this.highlight,
  }) : super(key: key);

  final String text;
  final String? highlight;

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
                  color: context.colorScheme.primaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
          )),
        ],
      );
}
