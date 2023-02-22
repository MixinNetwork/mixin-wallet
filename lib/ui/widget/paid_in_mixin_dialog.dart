import 'package:flutter/material.dart';
import '../../util/l10n.dart';

import 'brightness_observer.dart';

class PaidInMixinDialog extends StatelessWidget {
  const PaidInMixinDialog({
    required this.onPaid,
    super.key,
    this.title,
    this.positiveText,
    this.negativeText,
  });

  final VoidCallback onPaid;
  final String? title;
  final String? positiveText;
  final String? negativeText;

  @override
  Widget build(BuildContext context) => Center(
      child: Material(
          color: context.theme.background,
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
              width: 275,
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 36),
                        Text(title ?? context.l10n.paidInMixin,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: context.colorScheme.primaryText,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            )),
                        const SizedBox(height: 37),
                        Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _Button(
                                  text: negativeText ?? context.l10n.unpaid,
                                  color: context.colorScheme.thirdText,
                                  onTap: () => Navigator.of(context).pop()),
                              const SizedBox(width: 87),
                              _Button(
                                  text: positiveText ?? context.l10n.paid,
                                  color: context.colorScheme.primaryText,
                                  onTap: onPaid)
                            ]),
                        const SizedBox(height: 26),
                      ])))));
}

class _Button extends StatelessWidget {
  const _Button({
    required this.text,
    required this.color,
    required this.onTap,
  });

  final String text;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Center(
            child: Text(text,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ))),
      );
}
