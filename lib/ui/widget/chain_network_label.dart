import 'package:flutter/material.dart';

import '../../util/constants.dart';
import '../../util/extension/extension.dart';
import 'text.dart';

class ChainNetworkLabel extends StatelessWidget {
  const ChainNetworkLabel({
    Key? key,
    required this.chainId,
  }) : super(key: key);

  final String chainId;

  @override
  Widget build(BuildContext context) {
    final label = chainNetworks[chainId];
    if (label == null) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(4),
      ),
      child: MixinText(
        label,
        style: TextStyle(
          color: context.theme.secondaryText,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
