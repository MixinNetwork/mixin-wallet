import 'package:flutter/widgets.dart';
import 'brightness_observer.dart';

class TransactionInfoTile extends StatelessWidget {
  const TransactionInfoTile({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  final Widget title;
  final Widget subtitle;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          DefaultTextStyle(
            style: TextStyle(
              fontSize: 16,
              height: 1,
              color: context.colorScheme.thirdText,
            ),
            child: title,
          ),
          const SizedBox(height: 8),
          DefaultTextStyle(
            style: TextStyle(
              fontSize: 16,
              height: 1,
              color: context.colorScheme.primaryText,
            ),
            child: subtitle,
          ),
          const SizedBox(height: 12),
        ],
      );
}