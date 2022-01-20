import 'package:flutter/material.dart';
import '../../util/constants.dart';

import '../../util/extension/extension.dart';
import '../../util/r.dart';
import 'action_button.dart';

Future<T?> showMixinBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
}) =>
    showModalBottomSheet(
      context: context,
      builder: (context) => Material(
        color: context.colorScheme.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(topRadius),
        ),
        child: builder(context),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(topRadius),
        ),
      ),
      isScrollControlled: isScrollControlled,
    );

class MixinBottomSheetTitle extends StatelessWidget {
  const MixinBottomSheetTitle({
    Key? key,
    required this.title,
    this.action = const BottomSheetCloseButton(),
    this.padding = const EdgeInsets.only(left: 20, right: 12),
  }) : super(key: key);

  final Widget title;
  final Widget action;

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 70,
        child: Padding(
          padding: padding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DefaultTextStyle.merge(
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: context.colorScheme.primaryText,
                  ),
                  child: title),
              const Spacer(),
              action,
            ],
          ),
        ),
      );
}

class BottomSheetCloseButton extends StatelessWidget {
  const BottomSheetCloseButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ActionButton(
        name: R.resourcesCloseSvg,
        size: 24,
        onTap: () {
          Navigator.pop(context);
        },
      );
}
