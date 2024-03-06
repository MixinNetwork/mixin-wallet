import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;
import 'package:uuid/uuid.dart';

import '../../../db/mixin_database.dart';
import '../../../service/profile/pin_session.dart';
import '../../../util/constants.dart';
import '../../../util/extension/extension.dart';
import '../../../util/pay/external_transfer_uri_parser.dart';
import '../pin.dart';
import '../symbol.dart';

Future<bool> showTransferToAddressBottomSheet(
  BuildContext context, {
  required Addresses address,
  required AssetResult asset,
  required AssetResult feeAsset,
  required String amount,
  String? memo,
}) async {
  final traceId = const Uuid().v4();

  return _showTransferBottomSheet(
      context,
      _TransferVerifyBottomSheetBody(
        displayAddress: address.displayAddress(),
        asset: asset,
        amount: amount,
        description: _FeeText(
          address: address,
          asset: asset,
          feeAsset: feeAsset,
        ),
        addressLabel: address.label,
        verification: (context, pin) async {
          try {
            final api = context.appServices.client.transferApi;
            final response = await api.withdrawal(
              sdk.WithdrawalRequest(
                addressId: address.addressId,
                amount: amount,
                pin: encryptPin(context, pin)!,
                traceId: traceId,
                memo: memo,
                fee: address.fee,
              ),
            );
            await context.appServices.mixinDatabase.snapshotDao
                .insertAll([response.data]);
            Navigator.of(context).pop(true);
          } on DioException catch (error) {
            final mixinError = error.optionMixinError;
            if (mixinError?.code == sdk.insufficientTransactionFee) {
              final message = context.l10n
                  .errorInsufficientTransactionFeeWithAmount(
                      '${address.fee} ${feeAsset.symbol}');
              throw ErrorWithFormattedMessage(message);
            } else {
              rethrow;
            }
          }
        },
      ));
}

Future<bool> showTransferToExternalUrlBottomSheet({
  required BuildContext context,
  required ExternalTransfer transfer,
  required String traceId,
  required AssetResult asset,
}) {
  final fee =
      transfer.fee?.toDecimal(scaleOnInfinitePrecision: 10).toString() ?? '0';
  return _showTransferBottomSheet(
    context,
    _TransferVerifyBottomSheetBody(
      amount: transfer.amount,
      asset: asset,
      showWithdrawalWithPinTip: false,
      verification: (context, pin) async {
        try {
          final api = context.appServices.client.transferApi;
          final response = await api.withdrawal(
            sdk.WithdrawalRequest(
              assetId: asset.assetId,
              amount: transfer.amount,
              pin: encryptPin(context, pin)!,
              traceId: traceId,
              memo: transfer.memo,
              fee: fee,
              destination: transfer.destination,
              tag: null,
            ),
          );
          await context.appServices.mixinDatabase.snapshotDao
              .insertAll([response.data]);
          Navigator.of(context).pop(true);
        } on DioException catch (error) {
          final mixinError = error.optionMixinError;
          if (mixinError?.code == sdk.insufficientTransactionFee) {
            final message = context.l10n
                .errorInsufficientTransactionFeeWithAmount(
                    '$fee ${asset.chainSymbol}');
            throw ErrorWithFormattedMessage(message);
          } else {
            rethrow;
          }
        }
      },
      description: Text('${context.l10n.fee} $fee ${asset.chainSymbol}'),
      displayAddress: transfer.destination,
    ),
  );
}

Future<bool> _showTransferBottomSheet(BuildContext context, Widget body) =>
    showModalBottomSheet<bool>(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Material(
          color: context.colorScheme.background,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(topRadius),
          ),
          child: body,
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
    ).then((value) => value ?? false);

class _TransferVerifyBottomSheetBody extends StatelessWidget {
  const _TransferVerifyBottomSheetBody({
    required this.amount,
    required this.asset,
    required this.verification,
    required this.description,
    required this.displayAddress,
    this.addressLabel,
    this.showWithdrawalWithPinTip = true,
  });

  final String amount;
  final AssetResult asset;
  final PinVerification verification;

  final String? addressLabel;

  final String displayAddress;

  final Widget description;

  final bool showWithdrawalWithPinTip;

  @override
  Widget build(BuildContext context) => PinVerifyDialogScaffold(
        header: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Text(
              addressLabel == null
                  ? context.l10n.withdrawal
                  : context.l10n.withdrawalTo(addressLabel!),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.colorScheme.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                displayAddress,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: context.colorScheme.secondaryText,
                ),
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
            DefaultTextStyle.merge(
              style: TextStyle(
                fontSize: 14,
                color: context.colorScheme.secondaryText,
              ),
              child: description,
            ),
          ],
        ),
        tip: showWithdrawalWithPinTip
            ? Text(
                context.l10n.withdrawalWithPin,
                style: TextStyle(
                  fontSize: 14,
                  color: context.colorScheme.secondaryText,
                ),
              )
            : null,
        verification: verification,
        onErrorConfirmed: () {
          Navigator.of(context).pop();
        },
        onVerified: (BuildContext context, String pin) async {
          // do nothing.
        },
      );
}

class _FeeText extends StatelessWidget {
  const _FeeText({
    required this.address,
    required this.asset,
    required this.feeAsset,
  });

  final Addresses address;
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
