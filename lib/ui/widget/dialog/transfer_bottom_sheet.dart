import 'package:flutter/material.dart';

import '../../../db/mixin_database.dart';
import '../../../util/constants.dart';
import '../../../util/extension/extension.dart';
import '../pin.dart';
import '../symbol.dart';

/// return: verified succeed pin code. null if canceled.
Future<bool?> showTransferVerifyBottomSheet(
  BuildContext context, {
  required Addresse address,
  required AssetResult asset,
  required AssetResult feeAsset,
  required String amount,
  required PinPostVerification postVerification,
}) =>
    showModalBottomSheet<bool>(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Material(
          color: context.colorScheme.background,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(topRadius),
          ),
          child: _TransferVerifyBottomSheet(
            address: address,
            asset: asset,
            feeAsset: feeAsset,
            amount: amount,
            postVerification: postVerification,
          ),
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(topRadius),
        ),
      ),
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
    );

class _TransferVerifyBottomSheet extends StatelessWidget {
  const _TransferVerifyBottomSheet({
    Key? key,
    required this.address,
    required this.amount,
    required this.asset,
    required this.feeAsset,
    required this.postVerification,
  }) : super(key: key);

  final Addresse address;
  final String amount;
  final AssetResult asset;
  final AssetResult feeAsset;
  final PinPostVerification postVerification;

  @override
  Widget build(BuildContext context) => PinVerifyDialogScaffold(
        header: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Text(
              context.l10n.withdrawalTo(address.label),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.colorScheme.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              address.displayAddress().formatAddress(),
              style: TextStyle(
                fontSize: 14,
                color: context.colorScheme.secondaryText,
              ),
            ),
            const SizedBox(height: 10),
            SymbolIconWithBorder(
              symbolUrl: asset.iconUrl,
              chainUrl: asset.chainIconUrl,
              size: 70,
              chainSize: 24,
            ),
            const SizedBox(height: 8),
            Text(
              '${amount.numberFormat()} ${asset.symbol}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.colorScheme.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            _FeeText(address: address, asset: asset, feeAsset: feeAsset),
          ],
        ),
        tip: Text(
          context.l10n.withdrawalWithPin,
          style: TextStyle(
            fontSize: 14,
            color: context.colorScheme.secondaryText,
          ),
        ),
        onVerified: postVerification,
        onErrorConfirmed: () {
          Navigator.of(context).pop();
        },
      );
}

class _FeeText extends StatelessWidget {
  const _FeeText({
    Key? key,
    required this.address,
    required this.asset,
    required this.feeAsset,
  }) : super(key: key);

  final Addresse address;
  final AssetResult asset;
  final AssetResult feeAsset;

  @override
  Widget build(BuildContext context) {
    final reserveVal = double.tryParse(address.reserve);
    final dustVal = double.tryParse(address.dust ?? '0');
    final showReserve = reserveVal != null && reserveVal > 0;
    final showDust = dustVal != null && dustVal > 0;
    return DefaultTextStyle.merge(
      style: TextStyle(
        fontSize: 14,
        color: context.colorScheme.secondaryText,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '${context.l10n.networkFee} ${address.fee} ${feeAsset.symbol}',
          ),
          if (showDust)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${context.l10n.minimumWithdrawal} ${address.dust} ${asset.symbol}',
              ),
            ),
          if (showReserve)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${context.l10n.minimumReserve} ${address.reserve} ${asset.symbol}',
              ),
            ),
        ],
      ),
    );
  }
}
