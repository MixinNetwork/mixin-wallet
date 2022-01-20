import 'package:flutter/widgets.dart';
import 'brightness_observer.dart';

class TransactionInfoTile extends StatelessWidget {
  const TransactionInfoTile({
    Key? key,
    required this.title,
    required this.subtitle,
    this.subtitleColor,
  }) : super(key: key);

  final Widget title;
  final Widget subtitle;
  final Color? subtitleColor;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          DefaultTextStyle.merge(
            style: TextStyle(
              fontSize: 16,
              height: 1,
              color: context.colorScheme.thirdText,
            ),
            child: title,
          ),
          const SizedBox(height: 8),
          DefaultTextStyle.merge(
            style: TextStyle(
              fontSize: 16,
              height: 1,
              color: subtitleColor ?? context.colorScheme.primaryText,
            ),
            child: subtitle,
          ),
          const SizedBox(height: 12),
        ],
      );
}
