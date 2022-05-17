import 'package:flutter/material.dart';

import '../../util/extension/extension.dart';

class TipTile extends StatelessWidget {
  const TipTile({
    Key? key,
    required this.text,
    this.highlight,
    this.highlightColor,
    this.foregroundColor,
    this.fontWeight,
  }) : super(key: key);

  final String text;
  final String? highlight;
  final Color? highlightColor;

  final Color? foregroundColor;

  final FontWeight? fontWeight;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: foregroundColor ?? context.colorScheme.thirdText,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
              child: SelectableText.rich(
            text.highlight(
              TextStyle(
                color: foregroundColor ?? context.colorScheme.thirdText,
                fontSize: 14,
                fontWeight: fontWeight,
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

class TipListLayout extends StatelessWidget {
  const TipListLayout({Key? key, required this.children}) : super(key: key);

  final List<TipTile> children;

  @override
  Widget build(BuildContext context) => Material(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0x99F5F7FA),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              ...children.cast<Widget>().separated(const SizedBox(height: 8)),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
}
