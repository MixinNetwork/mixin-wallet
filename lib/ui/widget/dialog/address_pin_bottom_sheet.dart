import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;

import '../../../db/mixin_database.dart';
import '../../../service/account_provider.dart';
import '../../../service/profile/pin_session.dart';
import '../../../util/constants.dart';
import '../../../util/extension/extension.dart';
import '../../../util/hook.dart';
import '../pin.dart';
import '../symbol.dart';

Future<bool> showDeleteAddressByPinBottomSheet(
  BuildContext context, {
  required Addresses address,
}) async {
  final ret = await _showAddressPinBottomSheet(
    context,
    content: _AddressPinBottomSheetContent(
      assetId: address.assetId,
      type: _AddressModifyType.delete,
      address: address.destination,
      label: address.label,
      tag: address.tag,
      postVerification: (context, pin) async {
        final api = context.appServices.client.addressApi;
        await api.deleteAddressById(
            address.addressId, encryptPin(context, pin)!);
        Navigator.pop(context, true);
      },
    ),
  );
  return ret ?? false;
}

Future<bool> showAddAddressByPinBottomSheet(
  BuildContext context, {
  required String assetId,
  required String destination,
  required String label,
  required String? tag,
}) async {
  final api = context.appServices.client.addressApi;
  final ret = await _showAddressPinBottomSheet(
    context,
    content: _AddressPinBottomSheetContent(
      assetId: assetId,
      type: _AddressModifyType.add,
      address: destination,
      label: label,
      tag: tag,
      postVerification: (context, pin) async {
        final response = await api.addAddress(sdk.AddressRequest(
          assetId: assetId,
          pin: encryptPin(context, pin)!,
          destination: destination,
          tag: tag,
          label: label,
        ));
        await context.mixinDatabase.addressDao
            .insertAllOnConflictUpdate([response.data]);
        Navigator.pop(context, true);
      },
    ),
  );
  return ret ?? false;
}

enum _AddressModifyType {
  add,
  delete,
}

Future<bool?> _showAddressPinBottomSheet(
  BuildContext context, {
  required Widget content,
}) =>
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => SingleChildScrollView(
        child: Material(
          color: context.colorScheme.background,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(topRadius),
          ),
          child: content,
        ),
      ),
    );

class _AddressPinBottomSheetContent extends HookWidget {
  const _AddressPinBottomSheetContent({
    required this.assetId,
    required this.type,
    required this.address,
    required this.label,
    required this.tag,
    required this.postVerification,
  });

  final String assetId;
  final _AddressModifyType type;
  final String label;
  final String address;
  final String? tag;
  final PinPostVerification postVerification;

  @override
  Widget build(BuildContext context) {
    final faitCurrency = useAccountFaitCurrency();
    final asset = useMemoizedStream(
      () => context.appServices
          .assetResult(assetId, faitCurrency)
          .watchSingleOrNull(),
      keys: [assetId, faitCurrency],
    ).data;
    return PinVerifyDialogScaffold(
      title: Text(
        type == _AddressModifyType.add
            ? context.l10n.addWithdrawalAddress(asset?.symbol ?? '')
            : context.l10n.deleteWithdrawalAddress(asset?.symbol ?? ''),
      ),
      tip: Text(
        type == _AddressModifyType.add
            ? context.l10n.addAddressByPinTip
            : context.l10n.deleteAddressByPinTip,
        style: TextStyle(
          color: context.colorScheme.secondaryText,
          fontSize: 12,
        ),
      ),
      header: Column(
        children: [
          const SizedBox(height: 20),
          if (asset != null)
            SymbolIconWithBorder(
              symbolUrl: asset.iconUrl,
              chainUrl: asset.chainIconUrl,
              size: 70,
              chainSize: 24,
            )
          else
            const SizedBox(height: 70),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: context.colorScheme.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      onVerified: postVerification,
      onErrorConfirmed: () {
        Navigator.of(context).pop();
      },
    );
  }
}
