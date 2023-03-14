import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../db/mixin_database.dart';
import '../../../generated/r.dart';
import '../../../util/constants.dart';
import '../../../util/extension/extension.dart';
import '../chain_network_label.dart';
import '../mixin_bottom_sheet.dart';

Future<void> showDepositChooseNetworkBottomSheet(
  BuildContext context, {
  required AssetResult asset,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    builder: (context) => SingleChildScrollView(
      child: Material(
        color: context.colorScheme.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(topRadius),
        ),
        child: DepositChooseNetworkBottomSheet(asset: asset),
      ),
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(topRadius),
      ),
    ),
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
  );
}

const _chainNames = {
  '43d61dcd-e413-450d-80b8-101d5e903357': 'Ethereum (ERC-20)',
  'cbc77539-0a20-4666-8c8a-4ded62b36f0a': 'Avalanche X-Chain',
  '17f78d7c-ed96-40ff-980c-5dc62fecbc85': 'BNB Beacon Chain (BEP-2)',
  '1949e683-6a08-49e2-b087-d6b72398588f': 'BNB Smart Chain (BEP-20)',
  '05891083-63d2-4f3d-bfbe-d14d7fb9b25a': 'BitShares',
};

String? _getChainName({
  required String? chainId,
  String? chainName,
  String? assetKey,
}) {
  if (chainId == ChainId.tron) {
    if (isDigitsOnly(assetKey)) {
      return 'Tron (TRC-10)';
    } else {
      return 'Tron (TRC-20)';
    }
  }
  return _chainNames[chainId] ?? chainName;
}

class DepositChooseNetworkBottomSheet extends StatelessWidget {
  const DepositChooseNetworkBottomSheet({
    required this.asset,
    super.key,
  });

  final AssetResult asset;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          MixinBottomSheetTitle(
            title: Text(context.l10n.chooseNetwork),
            action: const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
          const _TipWidget(),
          const SizedBox(height: 16),
          _ChainWidget(asset: asset),
          const SizedBox(height: 60),
        ],
      );
}

class _ChainWidget extends StatelessWidget {
  const _ChainWidget({
    required this.asset,
  });

  final AssetResult asset;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Material(
          color: const Color(0xFFF6F7FA),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Image.network(
                    asset.chainIconUrl ?? '',
                    width: 36,
                    height: 36,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getChainName(
                            chainId: asset.chainId,
                            chainName: asset.chainName,
                            assetKey: asset.assetKey,
                          ) ??
                          '',
                      style: TextStyle(
                        color: context.colorScheme.primaryText,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _TipWidget extends StatelessWidget {
  const _TipWidget();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Material(
          color: const Color(0x4DFFF7AD),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  padding: const EdgeInsets.all(4),
                  child: Center(
                    child: SvgPicture.asset(R.resourcesIcNoticeSvg),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.chooseNetworkTip,
                    style: TextStyle(
                      color: context.colorScheme.primaryText,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
