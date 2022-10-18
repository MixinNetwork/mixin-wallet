import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../db/mixin_database.dart';
import '../../../service/profile/pin_session.dart';
import '../../../util/constants.dart';
import '../../../util/extension/extension.dart';
import '../../../util/logger.dart';
import '../mixin_bottom_sheet.dart';
import '../pin.dart';
import '../symbol.dart';
import '../toast.dart';

/// return: verified succeed pin code. null if canceled.
Future<String?> showTransferVerifyBottomSheet(
  BuildContext context, {
  required Addresse address,
  required AssetResult asset,
  required AssetResult feeAsset,
  required String amount,
}) =>
    showModalBottomSheet<String>(
      context: context,
      builder: (context) => Column(
        children: [
          const Spacer(),
          Material(
            color: context.colorScheme.background,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(topRadius),
            ),
            child: _TransferVerifyBottomSheet(
              address: address,
              asset: asset,
              feeAsset: feeAsset,
              amount: amount,
            ),
          ),
        ],
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

class _TransferVerifyBottomSheet extends HookWidget {
  const _TransferVerifyBottomSheet({
    Key? key,
    required this.address,
    required this.amount,
    required this.asset,
    required this.feeAsset,
  }) : super(key: key);

  final Addresse address;
  final String amount;
  final AssetResult asset;
  final AssetResult feeAsset;

  @override
  Widget build(BuildContext context) {
    final controller = useMemoized(PinInputController.new);
    useEffect(() {
      void onPinInput() {
        if (!controller.isFull) {
          return;
        }
        computeWithLoading(() async {
          final pin = controller.value;
          try {
            await context.appServices.client.accountApi
                .verifyPin(encryptPin(pin)!);
            Navigator.pop(context, pin);
          } catch (error, stacktrace) {
            e('verify pin error $error, $stacktrace');
            controller.clear();
            showErrorToast(error.toDisplayString(context));
          }
        });
      }

      controller.addListener(onPinInput);
      return () => controller.removeListener(onPinInput);
    }, [controller]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const MixinBottomSheetTitle(title: SizedBox.shrink()),
        const SizedBox(height: 10),
        Text(
          context.l10n.sendTo(address.label),
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
        const SizedBox(height: 20),
        PinField(controller: controller),
        const SizedBox(height: 10),
        Text(
          context.l10n.withdrawalWithPin,
          style: TextStyle(
            fontSize: 14,
            color: context.colorScheme.secondaryText,
          ),
        ),
        const SizedBox(height: 20),
        PinInputNumPad(controller: controller),
      ],
    );
  }
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
            '${context.l10n.networkFee} ${feeAsset.balance.numberFormat()} ${feeAsset.symbol}',
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
