import 'package:flutter/material.dart';

import '../../db/mixin_database.dart';
import '../../util/extension/extension.dart';
import 'text.dart';

const _chainNetworks = {
  '43d61dcd-e413-450d-80b8-101d5e903357': 'ERC-20',
  '17f78d7c-ed96-40ff-980c-5dc62fecbc85': 'BEP-2',
  '1949e683-6a08-49e2-b087-d6b72398588f': 'BEP-20',
  '6cfe566e-4aad-470b-8c9a-2fd35b49c68d': 'EOS',
  'b7938396-3f94-4e0a-9179-d3440718156f': 'Polygon',
};

const _bepChainIds = {
  '17f78d7c-ed96-40ff-980c-5dc62fecbc85',
  '1949e683-6a08-49e2-b087-d6b72398588f'
};

@visibleForTesting
bool isDigitsOnly(String? text) {
  if (text == null) {
    return false;
  }
  final regex = RegExp(r'^[0-9]+$');
  return regex.hasMatch(text);
}

extension _AssetExt on AssetResult {
  String? get chainNetworkLabel {
    if (chainId == assetId && !_bepChainIds.contains(chainId)) {
      return null;
    }

    // TRON_CHAIN_ID
    if (chainId == '25dabac5-056a-48ff-b9f9-f67395dc407c') {
      if (isDigitsOnly(assetKey)) {
        return 'TRC-10';
      } else {
        return 'TRC-20';
      }
    }
    return _chainNetworks[chainId];
  }
}

class ChainNetworkLabel extends StatelessWidget {
  const ChainNetworkLabel({
    required this.asset,
    super.key,
  });

  final AssetResult asset;

  @override
  Widget build(BuildContext context) {
    final label = asset.chainNetworkLabel;
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
